//
//  PlayerAccessoryView.swift
//  Off The Spots
//
//  Created by David Freeman on 7/15/25.
//

import SwiftUI
import MarqueeText

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
                        VStack(alignment: .leading, spacing: 0) {
                            MarqueeText(
                                text: selectedSong!.name,
                                font: UIFont.preferredFont(forTextStyle: .headline),
                                leftFade: 16,
                                rightFade: 16,
                                startDelay: 3
                            )
                            
                            MarqueeText(
                                text: selectedSong!.selectedTrack.name,
                                font: UIFont.preferredFont(forTextStyle: .subheadline),
                                leftFade: 16,
                                rightFade: 16,
                                startDelay: 3
                            )
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
                        VStack(alignment: .leading, spacing: 0) {
                            MarqueeText(
                                text: selectedSong!.name,
                                font: UIFont.preferredFont(forTextStyle: .headline),
                                leftFade: 16,
                                rightFade: 16,
                                startDelay: 3
                            )
                            
                            MarqueeText(
                                text: selectedSong!.selectedTrack.name,
                                font: UIFont.preferredFont(forTextStyle: .subheadline),
                                leftFade: 16,
                                rightFade: 16,
                                startDelay: 3
                            )
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

#Preview {
    struct PlayerAccessoryView_Preview: View {
        let track: Track = Track(name: "Bass Left")
        @State private var selectedSong: Song? = nil
        
        var body: some View {
            TabView {
                Tab("Tab 1", systemImage: "1.circle") {
                    List(0..<100) { i in
                        Text("Row \(i)")
                    }
                }
                
                Tab(role: .search) {
                    
                }
            }
            .tabViewBottomAccessory {
                PlayerAccessoryView(
                    selectedSong: $selectedSong,
                    presentPlayerSheet: .constant(false),
                    hideMiniPlayer: .constant(false),
                    player: AudioHelper()
                )
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .onAppear { selectedSong = Song(name: "After You've Gone", tracks: [track], selectedTrack: track) }
        }
    }
    
    return PlayerAccessoryView_Preview()
}
