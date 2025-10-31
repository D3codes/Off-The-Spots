//
//  SongsView.swift
//  Off The Spots
//
//  Created by David Freeman on 7/15/25.
//

import SwiftUI
import SwiftData

struct SongsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Song.order)]) private var songs: [Song]
    @Query(sort: [SortDescriptor(\SetList.order)]) private var setLists: [SetList]
    
    @ObservedObject var player: AudioHelper
    @Binding var selectedSong: Song?
    @Binding var presentPlayerSheet: Bool
    var setSelectedSong: (_ song: Song) -> Void = {song in }
    @Binding var hideMiniPlayer: Bool
    
    @State private var selection = Set<Song.ID>()
    
    @State private var presentAddSongSheet = false
    @State private var addSongInitialTrackUrl: URL?
    
    @State var newSong: Song = Song(
        id: UUID(),
        name: "",
        tracks: [],
        selectedTrack: Track(name: "")
    )
    
    var body: some View {
        NavigationStack {
            Group {
                if songs.isEmpty {
                    SplashScreenView()
                } else {
                    List(selection: $selection) {
                        ForEach(songs) { song in
                            Button(action: {
                                setSelectedSong(song)
                                presentPlayerSheet = true
                            }, label: {
                                SongListItemView(song: song)
                            })
                        }
                        .onMove(perform: moveSongs)
                        .onDelete(perform: deleteSongs)
                    }
                    .scrollContentBackground(.hidden)
                    .listSectionSpacing(.compact)
                    .ignoresSafeArea(.keyboard)
                }
            }
            .navigationTitle("Songs")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SettingsView(hideMiniPlayer: $hideMiniPlayer), label: {Image(systemName: "gearshape") })
                }
                
                if(!songs.isEmpty) {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        newSong = Song(
                            id: UUID(),
                            name: "",
                            tracks: [],
                            selectedTrack: Track(name: "")
                        )
                        
                        presentAddSongSheet = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .accessibilityLabel("Add Song")
                    .sheet(isPresented: $presentAddSongSheet) {
                        EditSongView(song: $newSong)
                            .interactiveDismissDisabled(true)
                    }
                }
            }
            .onAppear { hideMiniPlayer = false }
        }
    }
    
    private func deleteSongs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let songId = songs[index].id
                
                // Stop playing deleted song, if it is playing
                if(selectedSong?.id == songId) {
                    presentPlayerSheet = false
                    
                    if(player.isPlaying) {
                        player.stop()
                    }
                    
                    selectedSong = nil
                }
                
                // Remove deleted song from any set lists
                setLists.forEach { setList in
                    if setList.songs.contains(songId) {
                        setList.songs.removeAll(where: { $0 == songId })
                    }
                }
                
                // Delete song
                modelContext.delete(songs[index])
                
                try? modelContext.save()
            }
        }
    }
    
    private func moveSongs(offsets: IndexSet, destination: Int) {
        withAnimation {
            var revisedSongs = songs
            revisedSongs.move(fromOffsets: offsets, toOffset: destination)
            for (newIndex, song) in revisedSongs.enumerated() {
                if song.order != newIndex {
                    song.order = newIndex
                }
            }

            try? modelContext.save()
        }
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

    SongsView(
        player: AudioHelper(),
        selectedSong: .constant(nil),
        presentPlayerSheet: .constant(false),
        hideMiniPlayer: .constant(false)
    )
    .modelContainer(container)
}
