//
//  BottomBarView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI
import AVFoundation

struct BottomBarView: View {
    var song: Song
    @ObservedObject var player: AudioHelper
    
    var namespace: Namespace.ID
    var sheetProgress: CGFloat = 0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(song.name)
                    .bold()
//                    .matchedGeometryEffect(id: "name", in: namespace)
                
                Text(song.selectedTrack.name)
//                    .matchedGeometryEffect(id: "track", in: namespace)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            Spacer()
            
            Button(action: {
                if(player.isPlaying) {
                    player.pause()
                } else {
                    player.play()
                }
            }, label: {
                if(player.isPlaying) {
                    Image(systemName: "pause.fill")
                        .font(.title)
                        .tint(.primary)
                } else {
                    Image(systemName: "play.fill")
                        .font(.title)
                        .tint(.primary)
                }
            })
            
            Button(action: { player.skip(seconds: -15) }, label: {
                Image(systemName: "15.arrow.trianglehead.counterclockwise")
                    .font(.title)
                    .tint(.primary)
            })
            .padding(.horizontal, 10)
        }
        .padding(20)
        .ignoresSafeArea(.keyboard)
        .opacity(1)
        .scaleEffect(1 - 0.05 * sheetProgress)
        .contentShape(Capsule())
    }
}

#Preview {
    struct BottomBarView_Preview: View {
        @State var song: Song = Song(
            name: "After You've Gone",
            tracks: [Track(name: "Bass Left")],
            selectedTrack: Track(name: "Bass Left")
        )
        @State var player: AudioHelper = AudioHelper()
        
        @Namespace private var ns
        
        var body: some View {
            BottomBarView(
                song: song,
                player: player,
                namespace: ns,
                sheetProgress: 0
            )
            .background(.gray)
        }
    }
    
    return BottomBarView_Preview()
}
