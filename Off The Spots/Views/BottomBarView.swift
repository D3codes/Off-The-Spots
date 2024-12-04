//
//  BottomBarView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI

struct BottomBarView: View {
    @Binding var presentSongSheet: Bool
    var song: Song
    
    var body: some View {
        HStack {
            Button(action: { presentSongSheet = true }, label: {
                Image(systemName: "chevron.up")
                    .font(.title)
            })
            .padding(.horizontal, 10)
            
            VStack(alignment: .leading) {
                Text(song.name)
                Text(song.selectedTrack.name)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button(action: {}, label: {
                Image(systemName: "play.fill")
                    .font(.title)
            })
            
            Button(action: {}, label: {
                Image(systemName: "15.arrow.trianglehead.counterclockwise")
                    .font(.title)
            })
            .padding(.horizontal, 10)
        }
        .onTapGesture { presentSongSheet = true }
        .padding(20)
        .background(.thickMaterial)
        .frame(maxWidth: .infinity, maxHeight: 50)
    }
}

#Preview {
    struct BottomBarView_Preview: View {
        @State var presentSongSheet: Bool = false
        @State var song: Song = Song(
            name: "After You've Gone",
            tracks: [Track(name: "Bass Left")],
            selectedTrack: Track(name: "Bass Left")
        )
        
        var body: some View {
            BottomBarView(presentSongSheet: $presentSongSheet, song: song)
        }
    }
    
    return BottomBarView_Preview()
}
