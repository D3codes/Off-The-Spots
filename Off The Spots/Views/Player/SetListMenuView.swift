//
//  SetListMenuView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/31/25.
//

import SwiftUI
import SwiftData

struct SetListMenuView: View {
    @Query(sort: [SortDescriptor(\Song.order)]) private var songs: [Song]
    
    @State var setList: SetList?
    var currentSong: Song
    var setSelectedSong: (Song, SetList?) -> Void = {song, setList in }
    
    var body: some View {
        Menu("", systemImage: "music.note.list") {
            if setList != nil {
                Text(setList!.name)
                    .font(.title2)
                
                Divider()
                
                ForEach(setList!.songs, id: \.self) { songId in
                    if let song = songs.first(where: { $0.id == songId }) {
                        Button(action: { setSelectedSong(song, setList) }) {
                            Text(song.name)
                            
                            if songId == currentSong.id {
                                Image(systemName: "waveform")
                                    .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .repeat(.continuous))
                            }
                        }
                    }
                }
            }
        }
        .menuOrder(.fixed)
        .buttonStyle(.plain)
        .font(.title2)
        .disabled(setList == nil)
    }
}

#Preview {
    struct SetListMenuView_Preview: View {
        @State var currentSong = Song(name: "", tracks: [], selectedTrack: Track(name: ""))
        
        var body: some View {
            let setList: SetList = SetList(name: "Contest Set", songs: [])
            let container: ModelContainer = {
                let config = ModelConfiguration(isStoredInMemoryOnly: true)
                let container = try! ModelContainer(for: Song.self, configurations: config)
                for i in 1..<10 {
                    let track = Track(name: "Track 1", file: nil)
                    let song = Song(name: "Song \(i)", tracks: [track], selectedTrack: track, sheetMusic: nil)
                    currentSong = song
                    setList.songs.append(song.id)
                    container.mainContext.insert(song)
                }
                return container
            }()
            
            SetListMenuView(setList: setList, currentSong: currentSong)
                .modelContainer(container)
        }
    }
    
    return SetListMenuView_Preview()
}
