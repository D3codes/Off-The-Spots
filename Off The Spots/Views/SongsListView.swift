//
//  SongsListView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI
import SwiftData

struct SongsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var songs: [Song]
    
    @State private var presentSongSheet: Bool = false
    @State var selectedSong: Song?
    
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
                        Button(action: { showSongSheet(song: song) }, label: {
                            Text(song.name)
                        })
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .safeAreaInset(edge: .top) {
            HeaderView(presentSettingsSheet: $presentSettingsSheet, songs: songs, addItem: addItem)
        }
        .safeAreaInset(edge: .bottom) {
            if(selectedSong != nil) {
                BottomBarView(presentSongSheet: $presentSongSheet, song: selectedSong!)
            }
        }
        .sheet(isPresented: $presentSongSheet) {
            SongView(song: Binding($selectedSong)!)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $presentSettingsSheet) {
            SettingsView()
                .presentationDragIndicator(.visible)
        }
    }

    private func addItem() {
        withAnimation {
            let tracks: [Track] = [
                Track(name: "Bass Left"),
                Track(name: "Bari Left"),
                Track(name: "Lead Left"),
                Track(name: "Tenor Left")
            ]
            
            let newSong = Song(
                name: "After You've Gone",
                tracks: tracks,
                selectedTrack: tracks[0]
            )
            
            modelContext.insert(newSong)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                if selectedSong?.id == songs[index].id {
                    selectedSong = nil
                }
                
                modelContext.delete(songs[index])
            }
        }
    }
    
    private func showSongSheet(song: Song) {
        selectedSong = song
        presentSongSheet = true
    }
}

#Preview {
    struct SongsListView_Preview: View {
        let tracks: [Track] = [
            Track(name: "Bass Left"),
            Track(name: "Bari Left"),
            Track(name: "Lead Left"),
            Track(name: "Tenor Left")
        ]
        
        var body: some View {
            SongsListView(selectedSong: Song(
                name: "After You've Gone",
                tracks: tracks,
                selectedTrack: tracks[0]
            ))
                .modelContainer(for: Song.self, inMemory: true)
        }
    }
    
    return SongsListView_Preview()
}
