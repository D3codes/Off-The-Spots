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
    var setSelectedSong: (_ song: Song) -> Void = {song in }
    @Binding var selectedTab: Tabs
    @Binding var setListNavPath: NavigationPath
    
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
                    ForEach(filteredSongs) { song in
                        Button(action: {
                            selectedTab = .songs
                            setSelectedSong(song)
                            presentPlayerSheet = true
                        }, label: {
                            SongListItemView(song: song)
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
                
                Section {
                    ForEach(filteredSetLists) { setList in
                        Button(action: {
                            setListNavPath = NavigationPath()
                            setListNavPath.append(setList)
                            selectedTab = .setLists
                        }, label: {
                            SetListItemView(setList: setList)
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
            }
            .searchable(text: $searchText)
            .scrollContentBackground(.hidden)
            .listSectionSpacing(.compact)
            .ignoresSafeArea(.keyboard)
            .navigationTitle("Search")
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
