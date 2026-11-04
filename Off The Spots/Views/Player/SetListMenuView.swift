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
    
    let setList: SetList?
    var currentSong: Song
    var setSelectedSong: (Song, SetList?, Bool, Bool) -> Void = {song, setList, skip, skipRepeatReset in }
    
    var body: some View {
        Menu("", systemImage: "music.note.list") {
            if setList != nil {
                Text(setList!.name)
                    .font(.title2)
                
                Divider()
                
                ForEach(setList!.songs, id: \.self) { songId in
                    if let song = songs.first(where: { $0.id == songId }) {
                        Button(action: { setSelectedSong(song, setList, false, false) }) {
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
        .accessibilityLabel("Set List")
        .accessibilityValue(setList?.name ?? "None")
        .accessibilityIdentifier("playerSetListMenu")
    }
}

#Preview("Switch Set Lists") {
    struct SetListMenuPreview: View {
        @State private var useSecondSetList = false
        private let container: ModelContainer
        private let song: Song
        private let first: SetList
        private let second: SetList

        init() {
            let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            container = try! ModelContainer(for: OffTheSpotsPersistence.schema, configurations: [config])
            song = Song(name: "Shared First Song")
            let nextSong = Song(name: "Second Set List Encore")
            first = SetList(name: "Contest Set", songs: [song.id])
            second = SetList(name: "Rehearsal Set", songs: [song.id, nextSong.id])
            container.mainContext.insert(song)
            container.mainContext.insert(nextSong)
            container.mainContext.insert(first)
            container.mainContext.insert(second)
        }

        var body: some View {
            VStack(spacing: 24) {
                Toggle("Use Rehearsal Set", isOn: $useSecondSetList)
                SetListMenuView(setList: useSecondSetList ? second : first, currentSong: song)
            }
            .padding()
            .modelContainer(container)
        }
    }

    return SetListMenuPreview()
}
