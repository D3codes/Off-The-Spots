//
//  MainView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI
import SwiftData
import AVFoundation
import MediaPlayer

enum Tabs {
    case songs, setLists, search
}

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: [SortDescriptor(\Song.order)]) private var songs: [Song]
    @Query(sort: [SortDescriptor(\SetList.order)]) private var setLists: [SetList]
    
    @StateObject private var player: AudioHelper = AudioHelper.sharedController
    @State private var isEditingProgress: Bool = false
    
    @State private var presentPlayerSheet: Bool = false
    @State private var hideMiniPlayer: Bool = false
    @State var setListNavPath: NavigationPath = NavigationPath()
    
    @State var selectedTab: Tabs = .songs
    @State private var widgetPlaybackTask: Task<Void, Never>?
    @State private var widgetPlaybackError: String?
    @State private var presentWidgetSubscription = false
    @State private var presentWidgetThanks = false

    private var widgetSongs: [LibraryWidgetRecord] {
        songs.map { LibraryWidgetRecord(id: $0.id, name: $0.name) }
    }

    private var widgetSetLists: [LibraryWidgetRecord] {
        setLists.map { LibraryWidgetRecord(id: $0.id, name: $0.name) }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Songs", systemImage: "music.note", value: .songs) {
                SongsView(
                    player: player,
                    presentPlayerSheet: $presentPlayerSheet,
                    hideMiniPlayer: $hideMiniPlayer
                )
            }
            
            Tab("Set Lists", systemImage: "music.note.list", value: .setLists) {
                SetListsView(
                    setSelectedSong: player.setSelectedSong,
                    presentPlayerSheet: $presentPlayerSheet,
                    hideMiniPlayer: $hideMiniPlayer,
                    setListNavPath: $setListNavPath,
                    selectedSong: player.selectedSong,
                    selectedSetList: player.selectedSetList,
                    isSongPlaying: player.isPlaying
                )
            }
            
            Tab(value: .search, role: .search) {
                SearchView(
                    presentPlayerSheet: $presentPlayerSheet,
                    setSelectedSong: player.setSelectedSong,
                    selectedTab: $selectedTab,
                    setListNavPath: $setListNavPath
                )
            }
        }
        .tabViewBottomAccessory(isEnabled: player.selectedSong != nil && !hideMiniPlayer) {
            PlayerAccessoryView(
                presentPlayerSheet: $presentPlayerSheet,
                player: player
            )
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .sheet(isPresented: $presentPlayerSheet) {
            PlayerView(
                isEditingProgress: $isEditingProgress,
                player: player
            )
        }
        .sheet(isPresented: $presentWidgetSubscription) {
            NavigationStack {
                SubscriptionView(presentThanksSheet: $presentWidgetThanks, inSheet: true)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(role: .close) { presentWidgetSubscription = false }
                        }
                    }
            }
        }
        .sheet(isPresented: $presentWidgetThanks) { ThanksView() }
        .alert("Unable to Play", isPresented: Binding(
            get: { widgetPlaybackError != nil },
            set: { if !$0 { widgetPlaybackError = nil } }
        )) {
            Button("OK", role: .cancel) { widgetPlaybackError = nil }
        } message: {
            Text(widgetPlaybackError ?? "")
        }
        .onChange(of: widgetSongs, initial: true) { _, songs in
            LibraryWidgetPublisher.publish(songs)
        }
        .onChange(of: widgetSetLists, initial: true) { _, setLists in
            LibraryWidgetPublisher.publish(setLists, library: .setLists)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active || phase == .background {
                LibraryWidgetPublisher.publish(widgetSongs)
                LibraryWidgetPublisher.publish(widgetSetLists, library: .setLists)
            }
        }
        .onOpenURL(perform: openWidgetURL)
        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
            updateProgress()
        }
    }

    private func openWidgetURL(_ url: URL) {
        if url == SetListWidgetLink.libraryURL || SetListWidgetLink.setListID(from: url) != nil {
            openSetListWidgetURL(url)
            return
        }
        guard url == SongWidgetLink.libraryURL || SongWidgetLink.songID(from: url) != nil else { return }
        widgetPlaybackTask?.cancel()
        selectedTab = .songs
        hideMiniPlayer = false
        guard let songID = SongWidgetLink.songID(from: url) else { return }

        widgetPlaybackTask = Task { @MainActor in
            // Read from the live store, rather than trusting a potentially old widget snapshot.
            do {
                let descriptor = FetchDescriptor<Song>(sortBy: [SortDescriptor(\.order)])
                var currentSongs = try modelContext.fetch(descriptor)
                let needsPro = currentSongs.firstIndex(where: { $0.id == songID }).map { $0 >= 3 } ?? false
                var isPro = false
                if needsPro {
                    isPro = await StoreHelper.hasActiveSubscription()
                }
                guard !Task.isCancelled else { return }
                currentSongs = try modelContext.fetch(descriptor)
                switch WidgetSongPlayback.play(songID: songID, songs: currentSongs, isPro: isPro, player: player) {
                case .song:
                    presentPlayerSheet = true
                case .subscriptionRequired:
                    presentPlayerSheet = false
                    presentWidgetSubscription = true
                case .missingSong:
                    widgetPlaybackError = "This song is no longer in your library."
                case .missingAudio:
                    widgetPlaybackError = "This song’s selected track has no audio yet. Open the song to add or download its audio."
                }
                LibraryWidgetPublisher.publish(currentSongs.map { LibraryWidgetRecord(id: $0.id, name: $0.name) })
            } catch {
                widgetPlaybackError = "Your song library could not be opened. Please try again."
            }
        }
    }

    private func openSetListWidgetURL(_ url: URL) {
        widgetPlaybackTask?.cancel()
        selectedTab = .setLists
        hideMiniPlayer = false
        guard let setListID = SetListWidgetLink.setListID(from: url) else {
            setListNavPath = NavigationPath()
            return
        }

        widgetPlaybackTask = Task { @MainActor in
            do {
                let descriptor = FetchDescriptor<SetList>(sortBy: [SortDescriptor(\.order)])
                var currentSetLists = try modelContext.fetch(descriptor)
                var isPro = false
                if currentSetLists.contains(where: { $0.id == setListID }) {
                    isPro = await StoreHelper.hasActiveSubscription()
                }
                guard !Task.isCancelled else { return }
                currentSetLists = try modelContext.fetch(descriptor)
                let currentSongs = try modelContext.fetch(FetchDescriptor<Song>())
                switch WidgetSetListPlayback.play(setListID: setListID, setLists: currentSetLists,
                                                 songs: currentSongs, isPro: isPro, player: player) {
                case .song(_, let setList):
                    setListNavPath = NavigationPath([setList])
                    presentPlayerSheet = true
                case .subscriptionRequired:
                    presentPlayerSheet = false
                    presentWidgetSubscription = true
                case .missingSetList:
                    widgetPlaybackError = "This set list is no longer in your library."
                case .emptySetList:
                    widgetPlaybackError = "This set list has no songs yet. Add songs to it in Off The Spots."
                case .missingSong:
                    widgetPlaybackError = "The first song in this set list is no longer in your library. Open the set list to update it."
                case .missingAudio:
                    widgetPlaybackError = "The first song’s selected track has no audio yet. Open the song to add or download its audio."
                }
                LibraryWidgetPublisher.publish(currentSetLists.map { LibraryWidgetRecord(id: $0.id, name: $0.name) },
                                               library: .setLists)
            } catch {
                widgetPlaybackError = "Your set lists could not be opened. Please try again."
            }
        }
    }
    
    private func updateProgress() {
        guard player.isPlaying, !isEditingProgress else { return }
        player.updateProgress()
    }
}

#Preview {
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Song.self, configurations: config)
        for i in 1..<10 {
            let track = Track(name: "Track 1", file: nil)
            let song = Song(name: "Song \(i)", tracks: [track], selectedTrack: track, sheetMusic: nil)
            container.mainContext.insert(song)
        }
        return container
    }()

    MainView()
        .modelContainer(container)
}
