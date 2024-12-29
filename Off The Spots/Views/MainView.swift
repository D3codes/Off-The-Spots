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

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var songs: [Song]
    @State var selectedSong: Song?
    
    @StateObject private var player: AudioHelper = AudioHelper()
    @State private var isEditingProgress: Bool = false
    
    @State private var addSongInitialTrackUrl: URL?
    @State private var presentAddSongPopover: Bool = false
    
    @State private var presentSongSheet: Bool = false
    
    @State private var presentSettingsSheet: Bool = false

    var body: some View {
        Group {
            if(songs.isEmpty) {
                VStack(alignment: .trailing) {
                    VStack(alignment: .trailing) {
                        Image(systemName: "arrowshape.up.fill")
                            .font(.title)
                            .padding(.trailing, 13)
                            .symbolEffect(.wiggle.byLayer, options: .speed(0.5).repeat(.continuous))
                        Text("Add a song to get started")
                            .padding(.trailing, 20)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            } else {
                List {
                    ForEach(songs) { song in
                        Button(action: {
                            setSelectedSong(song: song)
                            presentSongSheet = true
                        }, label: {
                            Text(song.name)
                        })
                    }
                    .onDelete(perform: deleteSongs)
                }
            }
        }
        .safeAreaInset(edge: .top) {
            HeaderView(songs: songs, presentSettingsSheet: $presentSettingsSheet, presentAddSongPopover: $presentAddSongPopover)
        }
        .safeAreaInset(edge: .bottom) {
            if(selectedSong != nil) {
                BottomBarView(
                    presentSongSheet: $presentSongSheet,
                    song: selectedSong!,
                    player: player
                )
            }
        }
        .sheet(isPresented: $presentSongSheet) {
            SongView(
                song: Binding($selectedSong)!,
                isEditingProgress: $isEditingProgress,
                player: player
            )
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $presentSettingsSheet) {
            SettingsView()
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $presentAddSongPopover) {
            AddSongView(presentAddSongPopover: $presentAddSongPopover, addSong: { modelContext.insert($0) })
        }
        .onAppear() {
            setSelectedSong(song: selectedSong)
        }
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            updateProgress()
        }
    }

    private func deleteSongs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                if(selectedSong?.id == songs[index].id) {
                    selectedSong = nil
                    
                    if(player.isPlaying) {
                        player.stop()
                    }
                }
                
                modelContext.delete(songs[index])
            }
        }
    }
    
    private func setSelectedSong(song: Song?) {
        guard let song else { return }
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
