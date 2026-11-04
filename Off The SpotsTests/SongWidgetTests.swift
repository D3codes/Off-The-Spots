import Foundation
import SwiftData
import Testing
@testable import Off_The_Spots

struct SongWidgetTests {
    @Test func appGroupDoesNotRelocateExistingLibrary() {
        let configuration = OffTheSpotsPersistence.modelConfiguration(cloudKitDatabase: .none)
        let originalLocation = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("default.store")
        #expect(configuration.groupAppContainerIdentifier == nil)
        #expect(configuration.url.standardizedFileURL == originalLocation.standardizedFileURL)
    }

    @MainActor
    @Test func widgetPlaybackStartsSelectedTrackAndResumesSameSong() async throws {
        let fixture = try #require(Bundle(for: WidgetTestBundle.self).url(forResource: "PaddedMP3", withExtension: "mp3"))
        let track = Track(name: "Lead", file: try Data(contentsOf: fixture), fileExtension: "mp3")
        let song = Song(name: "Widget playback", tracks: [Track(name: "Empty"), track], selectedTrack: track)
        let player = AudioHelper()
        defer { player.stop() }
        let id = try #require(SongWidgetLink.songID(from: SongWidgetLink.playURL(for: song.id)))
        WidgetSongPlayback.play(songID: id, songs: [song], isPro: false, player: player)
        #expect(player.selectedSong?.id == song.id)
        #expect(player.selectedSong?.activeTrack?.id == track.id)
        #expect(player.selectedSetList == nil)
        #expect(player.duration > 0)
        #expect(player.isPlaybackRequested)
        for _ in 0..<100 where !player.isPlaying {
            try await Task.sleep(for: .milliseconds(20))
        }
        #expect(player.isPlaying)
        player.pause()
        #expect(!player.isPlaybackRequested)
        WidgetSongPlayback.play(songID: id, songs: [song], isPro: false, player: player)
        #expect(player.isPlaybackRequested)
    }

    @Test(arguments: [WidgetLibrary.songs, .setLists])
    func sharedSnapshotReflectsRenamesReorderingAndDeletion(library: WidgetLibrary) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let appStore = LibraryWidgetStore(library: library, directoryURL: directory)
        let widgetStore = LibraryWidgetStore(library: library, directoryURL: directory)
        let first = LibraryWidgetRecord(id: UUID(), name: "First")
        let second = LibraryWidgetRecord(id: UUID(), name: "Second")

        #expect(widgetStore.loadItems().isEmpty)
        #expect(try appStore.saveItems([first, second]))
        #expect(widgetStore.loadItems() == [first, second])
        #expect(try !appStore.saveItems([first, second]))
        let renamed = LibraryWidgetRecord(id: first.id, name: "Renamed")
        #expect(try appStore.saveItems([second, renamed]))
        #expect(widgetStore.loadItems() == [second, renamed])
        #expect(try appStore.saveItems([renamed]))
        #expect(widgetStore.loadItems() == [renamed])
        #expect(try appStore.saveItems([]))
        #expect(widgetStore.loadItems().isEmpty)
    }

    @Test(arguments: [3, 7, 10], [WidgetLibrary.songs, .setLists])
    func paginationReachesEveryItemAndClampsAfterDeletion(pageSize: Int, library: WidgetLibrary) throws {
        let songs = (0..<23).map { LibraryWidgetRecord(id: UUID(), name: "Song \($0)") }
        let pageCount = LibraryWidgetPage(items: songs, requestedIndex: 0, pageSize: pageSize).count
        let visited = (0..<pageCount).flatMap {
            LibraryWidgetPage(items: songs, requestedIndex: $0, pageSize: pageSize).items
        }
        #expect(visited == songs)
        #expect(LibraryWidgetPage(items: songs, requestedIndex: -1, pageSize: pageSize).index == 0)
        let shortened = LibraryWidgetPage(items: Array(songs.prefix(2)), requestedIndex: 100, pageSize: pageSize)
        #expect(shortened.index == 0)
        #expect(shortened.items == Array(songs.prefix(2)))
        let empty = LibraryWidgetPage(items: [], requestedIndex: 100, pageSize: pageSize)
        #expect(empty.index == 0 && empty.count == 1 && empty.items.isEmpty)

        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = LibraryWidgetStore(library: library, directoryURL: directory)
        try store.saveItems(songs)
        try store.setPageIndex(1, pageSize: pageSize)
        #expect(LibraryWidgetStore(library: library, directoryURL: directory).pageIndex(pageSize: pageSize) == 1)
        try store.saveItems(Array(songs.prefix(2)))
        try store.setPageIndex(100, pageSize: pageSize)
        #expect(store.pageIndex(pageSize: pageSize) == 0)
    }

    @Test func playbackLinksUseStableIDsAndRejectOtherRoutes() throws {
        let id = UUID()
        #expect(SongWidgetLink.songID(from: SongWidgetLink.playURL(for: id)) == id)
        for value in [
            "offthespots://songs", "https://play/\(id)",
            "offthespots://play/not-a-song", "offthespots://play/\(id)/extra",
            "offthespots://play/\(id)?action=delete", "offthespots://other/\(id)"
        ] {
            #expect(SongWidgetLink.songID(from: try #require(URL(string: value))) == nil)
        }
    }

    @MainActor
    @Test func playbackResolvesCurrentLibraryAndPreservesAccessRules() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: OffTheSpotsPersistence.schema, configurations: [config])
        let context = container.mainContext
        let songs = (0..<4).map { index in
            let track = Track(name: "Tenor", file: Data([1, 2, 3]), fileExtension: "mp3")
            let song = Song(name: "Song \(index)", tracks: [track], order: index)
            context.insert(song)
            return song
        }
        try context.save()

        if case .song(let selected) = WidgetSongPlayback.selection(songID: songs[0].id, songs: songs, isPro: false) {
            #expect(selected.id == songs[0].id)
            #expect(selected.activeTrack?.name == "Tenor")
        } else { Issue.record("The first song should be playable without Pro") }

        if case .subscriptionRequired = WidgetSongPlayback.selection(songID: songs[3].id, songs: songs, isPro: false) {
        } else { Issue.record("Widget playback must preserve the free-song limit") }
        if case .song(let selected) = WidgetSongPlayback.selection(songID: songs[3].id, songs: songs, isPro: true) {
            #expect(selected.id == songs[3].id)
        } else { Issue.record("Pro should allow all songs") }

        songs[0].activeTrack?.file = nil
        if case .missingAudio = WidgetSongPlayback.selection(songID: songs[0].id, songs: songs, isPro: false) {
        } else { Issue.record("Missing audio should be handled before playback") }
        if case .missingSong = WidgetSongPlayback.selection(songID: songs[0].id, songs: Array(songs.dropFirst()), isPro: true) {
        } else { Issue.record("An old widget entry must not resolve to a different song") }
    }
}

private final class WidgetTestBundle: NSObject {}
