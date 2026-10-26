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
    var isSongPlaying: Bool = false
    
    var isSearchResult: Bool = false
    var deleteSong: () -> Void = {}
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(song.name)
                    .font(.title2)
                    .tint(.primary)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 4) {
                    if selectedSong != nil && selectedSong!.id == song.id {
                        AnimatedWaveformView(color: .accentColor, animate: isSongPlaying)
                            .scaleEffect(0.2)
                            .frame(maxWidth: 10, maxHeight: 10)
                            .padding(.trailing, 4)
                    }
                    
                    Text("\(Image(systemName: "music.note.square.stack.fill"))")
                        .tint(.accentColor)
                        .font(.subheadline)
                    Text("\(song.trackCount)")
                        .tint(.primary)
                        .font(.subheadline)
                    
                    if song.sheetMusic != nil {
                        Divider().padding(.horizontal, 4)
                        
                        Image(systemName: "music.pages.fill")
                            .font(.subheadline)
                            .tint(.accentColor)
                    }
                }
            }
            
            if !isSearchResult {
                Spacer()
                
                Menu(content: {
                    Button(
                        action: { },
                        label: { Label("Edit Song", systemImage: "pencil") }
                    )
                    Button(
                        action: { },
                        label: { Label("Add to Set List", systemImage: "music.note.list") }
                    )
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        deleteSong()
                    } label: {
                        Label("Delete Song", systemImage: "trash")
                    }
                }, label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.foreground)
                        .frame(width: 20, height: 20)
                })
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    List {
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")), isSongPlaying: false, deleteSong: {})
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")), isSongPlaying: false, deleteSong: {})
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")), isSongPlaying: false, deleteSong: {})
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")), isSongPlaying: false, deleteSong: {})
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")), isSongPlaying: false, deleteSong: {})
    }
}
