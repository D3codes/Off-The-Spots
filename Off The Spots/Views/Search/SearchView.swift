//
//  SearchView.swift
//  Off The Spots
//
//  Created by David Freeman on 7/15/25.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Query(sort: [SortDescriptor(\Song.order)]) private var songs: [Song]
    @Query(sort: [SortDescriptor(\SetList.order)]) private var setLists: [SetList]
    
    @Binding var presentPlayerSheet: Bool
    var setSelectedSong: (Song, SetList?, Bool) -> Void = {song, setList, skip in }
    @Binding var selectedTab: Tabs
    @Binding var setListNavPath: NavigationPath
    
    @Environment(\.otsProGroupId) var otsProGroupId
    @State private var isPro: Bool = false
    @State private var presentSubscription: Bool = false
    @State private var presentThanksSheet: Bool = false
    
    @State private var searchText: String = ""
    
    var filteredSongs: [Song] {
        if searchText.isEmpty {
            return songs
        } else {
            return songs.filter { $0.name.contains(searchText) }
        }
    }
    
    var filteredSetLists: [SetList] {
        if searchText.isEmpty {
            return setLists
        } else {
            return setLists.filter { $0.name.contains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List() {
                Section {
                    ForEach(filteredSongs.enumerated(), id: \.offset) { index, song in
                        let unlockSong: Bool = isPro || songs.prefix(3).contains(where: { $0.id == song.id })
                        
                        Button(action: {
                            if unlockSong {
                                selectedTab = .songs
                                setSelectedSong(song, nil, false)
                                presentPlayerSheet = true
                            } else {
                                presentSubscription = true
                            }
                        }, label: {
                            SongListItemView(song: song)
                                .foregroundStyle(unlockSong ? .primary : .secondary)
                        })
                    }
                }
                header: {
                    HStack {
                        Image(systemName: "music.note")
                        Text("Songs")
                    }
                }
                footer: {
                    if filteredSongs.isEmpty {
                        Text("No Songs")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                    }
                }
                .listRowBackground(listItemBackground)
                
                Section {
                    ForEach(filteredSetLists) { setList in
                        Button(action: {
                            if isPro {
                                setListNavPath = NavigationPath()
                                selectedTab = .setLists
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { setListNavPath.append(setList) }
                            } else {
                                presentSubscription = true
                            }
                        }, label: {
                            SetListItemView(setList: setList)
                                .foregroundStyle(isPro ? .primary : .secondary)
                        })
                    }
                }
                header: {
                    HStack {
                        Image(systemName: "music.note.list")
                        Text("Set Lists")
                    }
                }
                footer: {
                    if filteredSetLists.isEmpty  {
                        Text("No Set Lists")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                    }
                }
                .listRowBackground(listItemBackground)
            }
            .searchable(text: $searchText)
            .scrollContentBackground(.hidden)
            .listSectionSpacing(.compact)
            .navigationTitle("Search")
            .background(backgroundGradient)
            .sheet(isPresented: $presentSubscription) { SubscriptionView(presentThanksSheet: $presentThanksSheet, inSheet: true) }
            .sheet(isPresented: $presentThanksSheet) { ThanksView() }
            .subscriptionStatusTask(for: otsProGroupId) { taskState in
                if let statuses = taskState.value {
                    isPro = StoreHelper.checkForActiveSubscription(in: statuses)
                } else {
                    isPro = false
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    
    let container: ModelContainer = {
        let schema = Schema([
            Song.self,
            SetList.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)
        for i in 1..<10 {
            let track = Track(name: "Track 1", file: nil)
            let song = Song(name: "Song \(i)", tracks: [track], selectedTrack: track, sheetMusic: nil)
            container.mainContext.insert(song)
        }
        for i in 1..<10 {
            let setList = SetList(name: "Set List \(i)", songs: [])
            container.mainContext.insert(setList)
        }
        return container
    }()
    
    SearchView(
        presentPlayerSheet: .constant(false),
        selectedTab: .constant(.search),
        setListNavPath: $path
    )
    .modelContainer(container)
}
