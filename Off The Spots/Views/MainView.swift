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
    
    @State private var presentSongSheet: Bool = false
    @State private var isAddSongSheetPresented = false

    var body: some View {
        VStack {
            if(songs.isEmpty) {
                SplashScreenView(isSheetPresented: $isAddSongSheetPresented)
                    .toolbar(.hidden)
            } else {
                List {
                    ForEach(songs) { song in
                        Button(action: {
                            setSelectedSong(song: song)
                            presentSongSheet = true
                        }, label: {
                            Text(song.name)
                                .tint(.primary)
                        })
                    }
                    .onDelete(perform: deleteSongs)
                }
                .navigationTitle(Text("Songs"))
                .toolbar {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    // Try to wrap in a VStack
                    Button(action: { isAddSongSheetPresented.toggle() }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Song")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    
                    if(selectedSong != nil) {
                        BottomBarView(
                            presentSongSheet: $presentSongSheet,
                            song: selectedSong!,
                            player: player
                        )
                    }
                }
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
        .sheet(isPresented: $isAddSongSheetPresented) {
            NavigationView {
                @State var newSong: Song = Song(
                    id: UUID(),
                    name: "",
                    tracks: [],
                    selectedTrack: Track(name: "")
                )
                
                EditSongView(song: $newSong)
            }
            .interactiveDismissDisabled(true)
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
