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
    var setSelectedSong: (Song, SetList?) -> Void = {song, setList in }
    
    @State private var selection = Set<Song.ID>()
    @State private var presentEditSetListSheet: Bool = false
    
    var body: some View {
        Group {
            List(selection: $selection) {
                ForEach(setList.songs, id: \.self) { songId in
                    if let song = songs.first(where: { $0.id == songId }) {
                        Button(action: {
                            setSelectedSong(song, setList)
                            presentPlayerSheet = true
                        }) {
                            SongListItemView(song: song)
                        }
                    }
                }
                .onMove(perform: moveSongs)
                .onDelete(perform: deleteSongs)
            }
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
    }
    
    private func deleteSongs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                setList.songs.remove(at: index)
            }
        }
    }

    private func moveSongs(offsets: IndexSet, destination: Int) {
        withAnimation {
            setList.songs.move(fromOffsets: offsets, toOffset: destination)
        }
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
        SetListView(setList: setList, presentPlayerSheet: .constant(false))
            .modelContainer(container)
    }
}
