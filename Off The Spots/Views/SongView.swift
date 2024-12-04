//
//  SongView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI

struct SongView: View {
    @Binding var song: Song
    
    var body: some View {
        VStack {
            HStack {
                Text(song.name)
                    .font(.title)
                Spacer()
                Menu(content: {
                    Button(action: {}, label: { Label("Edit Song", systemImage: "pencil") })
                    Button(action: {}, label: { Label("Edit Tracks", systemImage: "list.bullet.circle") })
                }, label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(.primary)
                })
            }
            
            Picker("Select a Track", selection: $song.selectedTrack) {
                ForEach(song.tracks, id: \.self) { track in
                    Text(track.name).tag(track.id)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }
}

#Preview {
    struct SongView_Preview: View {
        @State var song: Song = Song(
            name: "After You've Gone",
            tracks: [
                Track(name: "Bass Left"),
                Track(name: "Bari Left"),
                Track(name: "Lead Left"),
                Track(name: "Tenor Left")
            ],
            selectedTrack: Track(name: "Bass Left")
        )
        
        var body: some View {
            SongView(song: $song)
        }
    }
    
    return SongView_Preview()
}
