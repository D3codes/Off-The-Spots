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
    @Binding var presentPlayerSheet: Bool
    @Binding var hideMiniPlayer: Bool
    
    @State private var addButtonFrame: CGRect?
    @State private var selection = Set<Song.ID>()
    @State private var songToAddToSetList: Song?
    @State private var songToEdit: Song?
    @State private var songToDelete: Song?
    
    @State private var presentAddSongSheet = false
    @State private var addSongInitialTrackUrl: URL?
    
    @Environment(\.otsProGroupId) var otsProGroupId
    @State private var isPro: Bool = false
    @State private var presentSubscription: Bool = false
    @State private var presentThanksSheet: Bool = false
    
    @State var newSong: Song = Song(
        id: UUID(),
        name: "",
        tracks: [],
        selectedTrack: Track(name: "")
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                if songs.isEmpty {
                    SplashScreenView(targetFrame: addButtonFrame, placeholderText: "Add a Song to Get Started")
                } else {
                    List(selection: $selection) {
                        ForEach(songs.enumerated(), id: \.offset) { index, song in
                            let unlockSong: Bool = isPro || index < 3
                            
                            Button(action: {
                                if unlockSong {
                                    player.setSelectedSong(song: song, setList: nil)
                                    presentPlayerSheet = true
                                } else  {
                                    presentSubscription = true
                                }
                            }, label: {
                                SongListItemView(
                                    song: song,
                                    selectedSong: player.selectedSetList == nil ? player.selectedSong : nil,
                                    isSongPlaying: player.isPlaying,
                                    deleteSong: { songToDelete = song },
                                    presentAddToSetListSheet: {
                                        if isPro {
                                            songToAddToSetList = song
                                        } else {
                                            presentSubscription = true
                                        }
                                    },
                                    presentEditSongSheet: { songToEdit = song },
                                    unlocked: unlockSong
                                )
                                .foregroundStyle(unlockSong ? .primary : .secondary)
                            })
                            .listRowBackground(listItemBackground)
                        }
                        .onDelete(perform: deleteSongs)
                        .if(isPro) { view in
                            view.onMove(perform: moveSongs)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listSectionSpacing(.compact)
                    .ignoresSafeArea(.keyboard)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Songs")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SettingsView(hideMiniPlayer: $hideMiniPlayer), label: {Image(systemName: "gearshape") })
                }
                
                if(!songs.isEmpty && isPro) {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if isPro || songs.count < 3 {
                            newSong = Song(
                                id: UUID(),
                                name: "",
                                tracks: [],
                                selectedTrack: Track(name: "")
                            )
                            
                            presentAddSongSheet = true
                        } else {
                            presentSubscription = true
                        }
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .accessibilityLabel("Add Song")
                    .onGeometryChange(for: CGRect.self) { proxy in
                        proxy.frame(in: .global)
                    } action: { frame in
                        addButtonFrame = frame.isEmpty ? nil : frame
                    }
                    .onDisappear {
                        addButtonFrame = nil
                    }
                    .sheet(isPresented: $presentAddSongSheet) {
                        EditSongView(song: $newSong, isNewSong: true)
                            .interactiveDismissDisabled(true)
                    }
                }
            }
            .onAppear { hideMiniPlayer = false }
            .sheet(item: $songToAddToSetList) { song in
                AddToSetListView(song: song)
            }
            .sheet(item: $songToEdit) { song in
                EditSongView(song: .constant(song))
                    .interactiveDismissDisabled(true)
            }
            .sheet(isPresented: $presentSubscription) {
                NavigationStack {
                    SubscriptionView(presentThanksSheet: $presentThanksSheet, inSheet: true)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button(role: .close) { presentSubscription  = false }
                            }
                        }
                }
            }
            .sheet(isPresented: $presentThanksSheet) { ThanksView() }
            .subscriptionStatusTask(for: otsProGroupId) { taskState in
                isPro = StoreHelper.checkForActiveSubscription(in: taskState)
            }
            .alert(item: $songToDelete) { song in
                Alert(
                    title: Text("Delete \(song.name)?"),
                    message: Text("All tracks and sheet music will be deleted. It will also be removed from all Set Lists."),
                    primaryButton: .destructive(Text("Delete"), action: {
                        guard let index = songs.firstIndex(where: { $0.id == song.id }) else {
                            return
                        }

                        deleteSongs(offsets: IndexSet(integer: index))
                    }),
                    secondaryButton: .cancel(Text("Cancel"), action: {  })
                )
            }
        }
    }
    
    private func deleteSongs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let songId = songs[index].id
                
                // Stop playing deleted song, if it is playing
                if(player.selectedSong?.id == songId) {
                    presentPlayerSheet = false
                    
                    if(player.isPlaying) {
                        player.stop()
                    }
                    
                    player.selectedSong = nil
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
        presentPlayerSheet: .constant(false),
        hideMiniPlayer: .constant(false)
    )
    .modelContainer(container)
}
