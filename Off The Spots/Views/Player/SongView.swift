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
    @Binding var progress: Double
    @Binding var isEditingProgress: Bool
    
    @Binding var audioPlayer: AVAudioPlayer
    @Binding var isPlaying: Bool
    
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
                if(isPlaying) {
                    audioPlayer.stop()
                    isPlaying = false
                }
                
                do {
                    audioPlayer = try AVAudioPlayer(data: song.selectedTrack.file!)
                } catch {
                    print("OOPS")
                }
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            PanningView(audioPlayer: $audioPlayer, panningValue: Double(audioPlayer.pan))
                .padding()
            
            Spacer()
            
            RateView(audioPlayer: $audioPlayer, rateValue: audioPlayer.rate)
                .padding()
            
            Spacer()
            
            PlaybackProgressView(
                audioPlayer: $audioPlayer,
                progress: $progress,
                isEditingProgress: $isEditingProgress)
            
            HStack {
                Button(action: { audioPlayer.currentTime -= 15 }, label: {
                    Image(systemName: "15.arrow.trianglehead.counterclockwise")
                        .font(.largeTitle)
                })
                .padding()
                
                Button(action: {
                    if(isPlaying) {
                        audioPlayer.pause()
                        isPlaying = false
                    } else {
                        audioPlayer.play()
                        isPlaying = true
                    }
                }, label: {
                    if(isPlaying) {
                        Image(systemName: "pause.fill")
                            .font(.largeTitle)
                    } else {
                        Image(systemName: "play.fill")
                            .font(.largeTitle)
                    }
                })
                .padding()
                
                Button(action: { audioPlayer.currentTime += 15 }, label: {
                    Image(systemName: "15.arrow.trianglehead.clockwise")
                        .font(.largeTitle)
                })
                .padding()
            }
            .frame(maxWidth: .infinity)
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
        @State var audioPlayer: AVAudioPlayer = AVAudioPlayer()
        @State var isPlaying: Bool = false
        @State var progress: Double = 0.0
        @State var isEditingProgress: Bool = false
        
        var body: some View {
            SongView(
                song: $song,
                progress: $progress,
                isEditingProgress: $isEditingProgress,
                audioPlayer: $audioPlayer,
                isPlaying: $isPlaying
            )
        }
    }
    
    return SongView_Preview()
}
