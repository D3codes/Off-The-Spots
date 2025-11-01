//
//  SongListItemView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/30/25.
//

import SwiftUI

struct SongListItemView: View {
    var song: Song
    var selectedSong: Song? = nil
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(song.name)
                    .font(.title2)
                    .tint(.primary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("\(Image(systemName: "music.note.square.stack.fill")) \(song.tracks.count)")
                        .font(.footnote)
                        .tint(.primary)
                    
                    if song.sheetMusic != nil {
                        Divider()
                        
                        Image(systemName: "music.pages.fill")
                            .font(.footnote)
                            .tint(.primary)
                    }
                }
            }
            
            if selectedSong != nil && selectedSong!.id == song.id {
                Spacer()
                AudioVizualizerView(color: .accentColor)
                    .scaleEffect(0.4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    List {
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")))
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")))
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")))
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")))
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")))
    }
}
