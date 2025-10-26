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
    @ObservedObject var player: AudioHelper
    @Query(sort: [SortDescriptor(\Song.order)]) private var songs: [Song]
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
                                Text(song.name)
                                    .font(.title2)
                                    .tint(.primary)
                            })
                        }
                        .onMove(perform: moveSongs)
                        .onDelete(perform: deleteSongs)
//                        Section {
//                            Spacer()
//                                .listRowBackground(
//                                    RoundedRectangle(cornerRadius: 20)
//                                        .opacity(0)
//                                )
//                        }
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
                    .popover(isPresented: $presentAddSongSheet) {
                        EditSongView(song: $newSong)
                            .interactiveDismissDisabled(true)
                            .presentationCompactAdaptation(.sheet)
                    }
                }
            }
            .onAppear { hideMiniPlayer = false }
        }
    }
    
    private func deleteSongs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                if(selectedSong?.id == songs[index].id) {
                    presentPlayerSheet = false
                    
                    if(player.isPlaying) {
                        player.stop()
                    }
                    
                    selectedSong = nil
                }
                
                modelContext.delete(songs[index])
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
    struct SongsView_Preview: View {
        @StateObject private var player: AudioHelper = AudioHelper()
        @State private var selectedSong: Song? = nil
        @State private var presentPlayerSheet: Bool = false
        @State private var hideMiniPlayer: Bool = false
        
        var body: some View {
            NavigationStack {
                SongsView(player: player, selectedSong: $selectedSong, presentPlayerSheet: $presentPlayerSheet, hideMiniPlayer: $hideMiniPlayer)
                    .modelContainer(for: Song.self, inMemory: true)
            }
        }
    }
    
    return SongsView_Preview()
}

