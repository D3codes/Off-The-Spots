//
//  SongView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI
import AVFoundation

struct SongView: View {
    @Binding var song: Song
    @Binding var isEditingProgress: Bool
    
    @ObservedObject var player: AudioHelper
    
    var body: some View {
        VStack {
            HStack {
                Text(song.name)
                    .font(.largeTitle)
                Spacer()
                Menu(content: {
                    Button(action: {}, label: { Label("Edit Song", systemImage: "pencil") })
                }, label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(.primary)
                })
            }
            .padding(.top)
            
            Picker("Select a Track", selection: $song.selectedTrack) {
                ForEach(song.tracks, id: \.self) { track in
                    Text(track.name).tag(track.id)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: song.selectedTrack, {
                if(player.isPlaying) {
                    player.stop()
                }
                
                player.setSelectedSong(song: song)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            Spacer()
            
            PanningView(player: player, panningValue: $player.panningValue)
                .frame(maxHeight: 50)
            
            Spacer()
            
            HStack {
                RateView(player: player, rateValue: $player.rateValue)
                
                Spacer()
                
                LoopView(
                    player: player,
                    loopStart: $player.loopStart,
                    loopEnd: $player.loopEnd,
                    isLooping: $player.isLooping)
            }
            .frame(maxHeight: 50)
            
            Spacer()
            
            PlaybackProgressView(
                player: player,
                duration: $player.duration,
                progress: $player.progress,
                isEditingProgress: $isEditingProgress,
                loopStart: $player.loopStart,
                loopEnd: $player.loopEnd)
            
            HStack {
                Button(action: { player.skip(seconds: -15) }, label: {
                    Image(systemName: "15.arrow.trianglehead.counterclockwise")
                        .font(.largeTitle)
                        .tint(.primary)
                })
                .padding(.horizontal)
                
                Button(action: {
                    if(player.isPlaying) {
                        player.pause()
                    } else {
                        player.play()
                    }
                }, label: {
                    if(player.isPlaying) {
                        Image(systemName: "pause.fill")
                            .font(.largeTitle)
                            .tint(.primary)
                    } else {
                        Image(systemName: "play.fill")
                            .font(.largeTitle)
                            .tint(.primary)
                    }
                })
                .padding(.horizontal)
                
                Button(action: { player.skip(seconds: 15) }, label: {
                    Image(systemName: "15.arrow.trianglehead.clockwise")
                        .font(.largeTitle)
                        .tint(.primary)
                })
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom)
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
        @State var isEditingProgress: Bool = false
        @StateObject var player: AudioHelper = AudioHelper()
        
        var body: some View {
            SongView(
                song: $song,
                isEditingProgress: $isEditingProgress,
                player: player
            )
        }
    }
    
    return SongView_Preview()
}
