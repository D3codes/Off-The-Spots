import Foundation
import SwiftData
import Testing
@testable import Off_The_Spots

struct SetListWidgetTests {
    @Test func widgetLibrariesKeepIndependentSnapshotsAndPages() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let songs = LibraryWidgetStore(library: .songs, directoryURL: directory)
        let setLists = LibraryWidgetStore(library: .setLists, directoryURL: directory)
        let songItems = (0..<13).map { LibraryWidgetRecord(id: UUID(), name: "Song \($0)") }
        let listItems = (0..<9).map { LibraryWidgetRecord(id: UUID(), name: "Set List \($0)") }
        try songs.saveItems(songItems)
        try setLists.saveItems(listItems)
        try songs.setPageIndex(3, pageSize: 3)
        try setLists.setPageIndex(1, pageSize: 3)
        #expect(songs.loadItems() == songItems)
        #expect(setLists.loadItems() == listItems)
        #expect(songs.pageIndex(pageSize: 3) == 3)
        #expect(setLists.pageIndex(pageSize: 3) == 1)
        try setLists.saveItems([])
        #expect(songs.loadItems() == songItems)
        #expect(songs.pageIndex(pageSize: 3) == 3)
    }

    @Test func existingSongsWidgetSnapshotAndPageStillLoad() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let id = UUID()
        try Data("[{\"id\":\"\(id.uuidString)\",\"name\":\"Existing song\"}]".utf8)
            .write(to: directory.appendingPathComponent("songs.json"))
        try Data("2".utf8).write(to: directory.appendingPathComponent("page-3.json"))
        let store = LibraryWidgetStore(directoryURL: directory)
        #expect(store.loadItems() == [LibraryWidgetRecord(id: id, name: "Existing song")])
        #expect(store.pageIndex(pageSize: 3) == 2)
        #expect(WidgetLibrary.songs.kind == "OffTheSpotsSongs")
    }

    @Test func setListLinksCannotBeConfusedWithSongLinks() throws {
        let id = UUID()
        let setListURL = WidgetLibrary.setLists.playURL(for: id)
        let songURL = WidgetLibrary.songs.playURL(for: id)
        #expect(SetListWidgetLink.setListID(from: setListURL) == id)
        #expect(SongWidgetLink.songID(from: setListURL) == nil)
        #expect(SetListWidgetLink.setListID(from: songURL) == nil)
        #expect(WidgetLibrary.setLists.libraryURL != WidgetLibrary.songs.libraryURL)
        for value in ["offthespots://play-set-list/not-an-id",
                      "offthespots://play-set-list/\(id)/extra",
                      "offthespots://play-set-list/\(id)?action=delete",
                      "https://play-set-list/\(id)"] {
            #expect(SetListWidgetLink.setListID(from: try #require(URL(string: value))) == nil)
        }
    }

    @MainActor
    @Test func setListPlaybackStartsSavedFirstSongAndRestartsFromBeginning() async throws {
        let fixture = try #require(Bundle(for: SetListWidgetTestBundle.self)
            .url(forResource: "PaddedMP3", withExtension: "mp3"))
        let track = Track(name: "Lead", file: try Data(contentsOf: fixture), fileExtension: "mp3")
        let firstSong = Song(name: "First in set list", tracks: [track])
        let laterSong = Song(name: "First in library")
        let setList = SetList(name: "Contest", songs: [firstSong.id, laterSong.id])
        let player = AudioHelper()
        player.publishProgressChanges = true
        defer { player.stop() }

        WidgetSetListPlayback.play(setListID: setList.id, setLists: [setList],
                                   songs: [laterSong, firstSong], isPro: true, player: player)
        #expect(player.selectedSong?.id == firstSong.id)
        #expect(player.selectedSetList?.id == setList.id)
        #expect(player.selectedSetList?.songs == [firstSong.id, laterSong.id])
        #expect(player.duration > 0)
        for _ in 0..<100 where !player.isPlaying {
            try await Task.sleep(for: .milliseconds(20))
        }
        #expect(player.isPlaying)
        player.pause()
        player.setCurrentTime(value: 441)
        #expect(player.playbackProgress.value > 0)
        player.repeatOne = true
        WidgetSetListPlayback.play(setListID: setList.id, setLists: [setList],
                                   songs: [laterSong, firstSong], isPro: true, player: player)
        #expect(player.playbackProgress.value == 0)
        #expect(!player.repeatOne)
        #expect(player.isPlaybackRequested)

        let nextSetList = SetList(name: "New widget selection", songs: [firstSong.id])
        WidgetSetListPlayback.play(setListID: nextSetList.id, setLists: [setList, nextSetList],
                                   songs: [laterSong, firstSong], isPro: true, player: player)
        #expect(player.selectedSong?.id == firstSong.id)
        #expect(player.selectedSetList?.id == nextSetList.id)
        #expect(player.selectedSetList?.songs == [firstSong.id])
    }

    @MainActor
    @Test func missingEmptyAndLockedSetListsDoNotStartAnotherSong() {
        let song = Song(name: "Later", tracks: [Track(name: "Lead", file: Data([1]))])
        let setList = SetList(name: "Rehearsal", songs: [])
        if case .missingSetList = WidgetSetListPlayback.selection(setListID: UUID(), setLists: [setList], songs: [song], isPro: true) {
        } else { Issue.record("An old widget must not open a different set list") }
        if case .subscriptionRequired = WidgetSetListPlayback.selection(setListID: setList.id, setLists: [setList], songs: [song], isPro: false) {
        } else { Issue.record("Set lists must retain the app's Pro requirement") }
        if case .emptySetList = WidgetSetListPlayback.selection(setListID: setList.id, setLists: [setList], songs: [song], isPro: true) {
        } else { Issue.record("An empty list should be handled safely") }
        setList.songs = [UUID(), song.id]
        if case .missingSong = WidgetSetListPlayback.selection(setListID: setList.id, setLists: [setList], songs: [song], isPro: true) {
        } else { Issue.record("Do not silently skip the missing first song") }
        setList.songs = [song.id]
        song.activeTrack?.file = nil
        if case .missingAudio = WidgetSetListPlayback.selection(setListID: setList.id, setLists: [setList], songs: [song], isPro: true) {
        } else { Issue.record("Missing audio should be handled before playback") }
    }
}

private final class SetListWidgetTestBundle: NSObject {}
