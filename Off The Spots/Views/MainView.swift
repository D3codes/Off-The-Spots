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
    
    @StateObject private var player: AudioHelper = AudioHelper()
    @State private var isEditingProgress: Bool = false
    
    @State private var presentPlayerSheet: Bool = false
    @State private var hideMiniPlayer: Bool = false
    
    @State var selectedTab: Tabs = .songs
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Songs", systemImage: "music.note", value: .songs) {
                SongsView(
                    player: player,
                    selectedSong: $selectedSong,
                    presentPlayerSheet: $presentPlayerSheet,
                    setSelectedSong: setSelectedSong,
                    hideMiniPlayer: $hideMiniPlayer
                )
            }
            
            Tab("Set Lists", systemImage: "music.note.list", value: .setLists) {
                SetListsView(
                    player: player,
                    presentPlayerSheet: $presentPlayerSheet,
                    hideMiniPlayer: $hideMiniPlayer
                )
            }
            
            Tab(value: .search, role: .search) { SearchView(presentPlayerSheet: $presentPlayerSheet, setSelectedSong: setSelectedSong) }
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
            PlayerView(song: Binding($selectedSong)!, isEditingProgress: $isEditingProgress, player: player)
        }
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            updateProgress()
        }
    }
    
    private func setSelectedSong(song: Song?) {
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
    struct MainView_Preview: View {
        var body: some View {
            MainView()
            .modelContainer(for: Song.self, inMemory: true)
        }
    }
    
    return MainView_Preview()
}
