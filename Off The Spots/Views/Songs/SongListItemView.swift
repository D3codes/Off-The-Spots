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
    var removeSong: (() -> Void)? = nil
    var deleteSong: (() -> Void)? = nil
    
    var presentAddToSetListSheet: () -> Void = {}
    var presentEditSongSheet: () -> Void = {}
    
    var unlocked: Bool = false
    
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
                        action: { presentEditSongSheet() },
                        label: { Label("Edit Song", systemImage: "pencil") }
                    )
                    Button(
                        action: { presentAddToSetListSheet() },
                        label: { Label("Add to Set List", systemImage: "music.note.list") }
                    )
                    
                    Divider()
                    
                    if let removeSong {
                        Button(role: .destructive) {
                            removeSong()
                        } label: {
                            Label("Remove from Set List", systemImage: "minus.circle")
                        }
                    }
                    
                    if let deleteSong {
                        Button(role: .destructive) {
                            deleteSong()
                        } label: {
                            Label("Delete Song", systemImage: "trash")
                        }
                    }
                }, label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(unlocked ? Color.primary : Color.secondary)
                        .frame(width: 20, height: 20)
                })
                .disabled(!unlocked)
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    List {
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")), isSongPlaying: false, deleteSong: {}, unlocked: true)
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")), isSongPlaying: false, removeSong: {}, deleteSong: {}, unlocked: true)
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")), isSongPlaying: false, removeSong: {}, unlocked: true)
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")), isSongPlaying: false, deleteSong: {}, unlocked: false)
        SongListItemView(song: Song(name: "Song 1", tracks: [], selectedTrack: Track(name: "Track 1")), isSongPlaying: false, removeSong: {}, unlocked: false)
    }
}
