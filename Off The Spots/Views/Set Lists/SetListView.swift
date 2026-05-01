//
//  SetListView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/30/25.
//

import SwiftUI
import SwiftData

struct SetListView: View {
    @Query(sort: [SortDescriptor(\Song.order)]) private var songs: [Song]
    
    @State var setList: SetList
    @Binding var presentPlayerSheet: Bool
    var setSelectedSong: (Song, SetList?, Bool) -> Void = {song, setList, skip in }
    
    var selectedSong: Song?
    var selectedSetList: SetList?
    var isSongPlaying: Bool
    
    @State private var selection = Set<Song.ID>()
    @State private var presentEditSetListSheet: Bool = false
    
    var body: some View {
        Group {
            List(selection: $selection) {
                ForEach(setList.songs, id: \.self) { songId in
                    if let song = songs.first(where: { $0.id == songId }) {
                        Button(action: {
                            setSelectedSong(song, setList, false)
                            presentPlayerSheet = true
                        }) {
                            SongListItemView(
                                song: song,
                                selectedSong: selectedSetList?.id == setList.id ? selectedSong : nil,
                                isSongPlaying: isSongPlaying
                            )
                        }
//                        .listRowBackground(Color.clear)
                        .listRowBackground(listItemBackground)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listSectionSpacing(.compact)
            .ignoresSafeArea(.keyboard)
        }
        .navigationTitle(setList.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { presentEditSetListSheet = true }, label: { Image(systemName: "pencil") })
            }
        }
        .sheet(isPresented: $presentEditSetListSheet) {
            EditSetListView(setList: $setList)
                .interactiveDismissDisabled(true)
        }
        .background(backgroundGradient)
    }
}

#Preview {
    let setList = SetList(name: "Set List Name", songs: [])
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Song.self, configurations: config)
        for i in 1..<10 {
            let track = Track(name: "Track 1", file: nil)
            let song = Song(name: "Song \(i)", tracks: [track], selectedTrack: track, sheetMusic: nil)
            setList.songs.append(song.id)
            container.mainContext.insert(song)
        }
        return container
    }()

    NavigationStack {
        SetListView(setList: setList, presentPlayerSheet: .constant(false), isSongPlaying: false)
            .modelContainer(container)
    }
}
