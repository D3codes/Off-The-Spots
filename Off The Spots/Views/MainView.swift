//
//  MainView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI
import SwiftData
import AVFoundation

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var songs: [Song]
    @State var selectedSong: Song?
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying: Bool = false
    
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
                            audioPlayer: audioPlayer!,
                            isPlaying: $isPlaying
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $presentSongSheet) {
            SongView(
                song: Binding($selectedSong)!,
                audioPlayer: Binding($audioPlayer)!,
                isPlaying: $isPlaying
            )
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isAddSongSheetPresented) {
            NavigationView {
                AddSongView()
            }
            .interactiveDismissDisabled(true)
        }
        .onAppear() { setSelectedSong(song: selectedSong) }
    }

    private func deleteSongs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                if(selectedSong?.id == songs[index].id) {
                    selectedSong = nil
                    
                    if(isPlaying) {
                        audioPlayer?.stop()
                        isPlaying = false
                    }
                }
                
                modelContext.delete(songs[index])
            }
        }
    }
    
    private func setSelectedSong(song: Song?) {
        if let song {
            selectedSong = song
            
            do {
                audioPlayer = try AVAudioPlayer(data: song.selectedTrack.file!)
                audioPlayer?.enableRate = true
            } catch {
                print("oops")
            }
        }
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
