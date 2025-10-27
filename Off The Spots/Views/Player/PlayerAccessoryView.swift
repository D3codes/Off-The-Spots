//
//  PlayerAccessoryView.swift
//  Off The Spots
//
//  Created by David Freeman on 7/15/25.
//

import SwiftUI

struct PlayerAccessoryView: View {
    @Environment(\.tabViewBottomAccessoryPlacement) var tabViewBottomAccessoryPlacement
    
    @Binding var selectedSong: Song?
    @Binding var presentPlayerSheet: Bool
    @Binding var hideMiniPlayer: Bool
    
    @ObservedObject var player: AudioHelper

    var body: some View {
        if selectedSong != nil && !hideMiniPlayer {
            Group {
                switch tabViewBottomAccessoryPlacement {
                case .expanded:
                    HStack {
                        VStack(alignment: .leading) {
                            Text(selectedSong!.name)
                                .font(.headline)
                            
                            Text(selectedSong!.selectedTrack.name)
                                .font(.subheadline)
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
                                    .font(.title2)
                                    .tint(.primary)
                            } else {
                                Image(systemName: "play.fill")
                                    .font(.title2)
                                    .tint(.primary)
                            }
                        })

                        Button(action: { player.skip(seconds: -15) }, label: {
                            Image(systemName: "15.arrow.trianglehead.counterclockwise")
                                .font(.title2)
                                .tint(.primary)
                        })
                        .padding(.leading, 10)
                    }
                default:
                    HStack {
                        VStack(alignment: .leading) {
                            Text(selectedSong!.name)
                                .font(.headline)
                            
                            Text(selectedSong!.selectedTrack.name)
                                .font(.subheadline)
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
                                    .font(.title2)
                                    .tint(.primary)
                            } else {
                                Image(systemName: "play.fill")
                                    .font(.title2)
                                    .tint(.primary)
                            }
                        })
                    }
                }
            }
            .padding(.horizontal)
            .contentShape(Capsule())
            .onTapGesture { presentPlayerSheet = true }
            .id(player.isPlaying)
        }
    }
}
