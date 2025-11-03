//
//  SelectSongsView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/29/25.
//

import SwiftUI
import SwiftData

struct SelectSongsView: View {
    @Query(sort: [SortDescriptor(\Song.order)]) private var songs: [Song]
    @Environment(\.dismiss) private var dismiss
    
    @State var setList: SetList
    
    @State private var songSelection = Set<Song.ID>()
    
    @State private var searchText: String = ""
    var filteredSongs: [Song] {
        if searchText.isEmpty {
            return songs
        } else {
            return songs.filter { $0.name.contains(searchText) }
        }
    }
    
    var body: some View {
        List(selection: $songSelection) {
            ForEach(filteredSongs) { song in
                Text(song.name)
//                    .listRowBackground(listItemBackground)
            }
        }
        .scrollContentBackground(.hidden)
        .listSectionSpacing(.compact)
        .environment(\.editMode, .constant(EditMode.active))
        .searchable(text: $searchText)
        .navigationTitle("Songs")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    setList.songs = Array(songSelection)
                    dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                }
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                songSelection = Set<Song.ID>(setList.songs)
            }
        }
//        .background(backgroundGradient)
    }
}

#Preview {
    let setList = SetList(name: "Test", songs: [])
    
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Song.self, configurations: config)
        for i in 1..<10 {
            let track = Track(name: "Track 1", file: nil)
            let song = Song(name: "Song \(i)", tracks: [track], selectedTrack: track, sheetMusic: nil)
            container.mainContext.insert(song)
            setList.songs.append(song.id)
        }
        return container
    }()
    
    NavigationStack {
        SelectSongsView(setList: setList)
            .modelContainer(container)
    }
}
