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
    @Query private var songs: [Song]
    @State var selectedSong: Song?
    @State var selectedSetList: SetList?
    
    @StateObject private var player: AudioHelper = AudioHelper()
    @State private var isEditingProgress: Bool = false
    
    @State private var presentPlayerSheet: Bool = false
    @State private var hideMiniPlayer: Bool = false
    @State var setListNavPath: NavigationPath = NavigationPath()
    
    @State var selectedTab: Tabs = .songs
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Songs", systemImage: "music.note", value: .songs) {
                SongsView(
                    player: player,
                    selectedSong: $selectedSong,
                    presentPlayerSheet: $presentPlayerSheet,
                    setSelectedSong: setSelectedSong,
                    hideMiniPlayer: $hideMiniPlayer,
                    selectedSetList: selectedSetList
                )
            }
            
            Tab("Set Lists", systemImage: "music.note.list", value: .setLists) {
                SetListsView(
                    setSelectedSong: setSelectedSong,
                    presentPlayerSheet: $presentPlayerSheet,
                    hideMiniPlayer: $hideMiniPlayer,
                    setListNavPath: $setListNavPath,
                    selectedSong: selectedSong,
                    selectedSetList: selectedSetList
                )
            }
            
            Tab(value: .search, role: .search) {
                SearchView(
                    presentPlayerSheet: $presentPlayerSheet,
                    setSelectedSong: setSelectedSong,
                    selectedTab: $selectedTab,
                    setListNavPath: $setListNavPath
                )
            }
        }
        .tabViewBottomAccessory {
            PlayerAccessoryView(
                selectedSong: $selectedSong,
                presentPlayerSheet: $presentPlayerSheet,
                hideMiniPlayer: $hideMiniPlayer,
                player: player
            )
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .sheet(isPresented: $presentPlayerSheet) {
            PlayerView(
                song: Binding($selectedSong)!,
                isEditingProgress: $isEditingProgress,
                player: player,
                setList: selectedSetList,
                setSelectedSong: setSelectedSong
            )
        }
        .onAppear { player.handlePlayerDidFinishPlaying = handlePlayerDidFinishPlaying }
        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
            updateProgress()
        }
    }
    
    private func handlePlayerDidFinishPlaying() {
        player.isPlaying = false
        player.progress = 0
        
        if selectedSetList != nil {
            let currentSongIndex = selectedSetList!.songs.firstIndex(of: selectedSong!.id)!
            if currentSongIndex == selectedSetList!.songs.count - 1 { return }
            
            let nextSong: Song? = songs.first(where: { $0.id == selectedSetList!.songs[currentSongIndex + 1] })
            guard let nextSong else { return }
            
            setSelectedSong(song: nextSong, setList: selectedSetList)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { player.play() }
        }
    }
    
    private func setSelectedSong(song: Song?, setList: SetList?) {
        selectedSetList = setList
        
        guard let song else { return }
        if selectedSong != nil && selectedSong!.id == song.id { return }
        selectedSong = song
        player.setSelectedSong(song: song)
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
