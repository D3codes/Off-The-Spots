//
//  SongListSectionView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/29/25.
//

import SwiftUI
import SwiftData

struct SongListSectionView: View {
    @Query(sort: [SortDescriptor(\Song.order)]) private var songs: [Song]

    @State var setList: SetList
    
    var body: some View {
        Section {
            ForEach(setList.songs, id: \.self) { songId in
                if let song = songs.first(where: { $0.id == songId }) {
                    Text(song.name)
//                        .listRowBackground(listItemBackground)
                }
            }
            .onMove(perform: moveSongs)
            .onDelete(perform: deleteSongs)
            .scrollContentBackground(.hidden)
        } header: {
            HStack {
                Image(systemName: "music.note")
                    .font(.subheadline)
                    .foregroundStyle(.accent)
                Text("Songs")
                    .font(.subheadline)
                
                Spacer()
                
                NavigationLink(destination: { SelectSongsView(setList: setList) }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundStyle(.foreground)
                        .frame(width: 10, height: 20)
                }
                .font(.subheadline)
                .buttonStyle(.bordered)
            }
        } footer: {
            if(setList.songs.isEmpty) {
                Text("No Songs")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
            }
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
        List {
            SongListSectionView(setList: setList)
                .modelContainer(container)
        }
    }
}
