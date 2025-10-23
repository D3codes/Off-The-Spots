//
//  PlayerView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI
import AVFoundation

struct PlayerView: View {
    @Binding var song: Song
    @Binding var isEditingProgress: Bool
    @ObservedObject var player: AudioHelper
    
    @State private var loopStartLocked: Bool = false
    @State private var loopEndLocked: Bool = false
    @State private var isAddSongSheetPresented: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text(song.name)
                    .font(.largeTitle)
                Spacer()
                Menu(content: {
                    Button(
                        action: { },
                        label: { Label("Add to Set List", systemImage: "music.note.list") }
                    )
                    Button(
                        action: { isAddSongSheetPresented = true },
                        label: { Label("Edit Song", systemImage: "pencil") }
                    )
                }, label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.foreground)
                })
                .glassEffect()
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
            .tint(.primary)
            .glassEffect()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            Spacer()
            
            GlassEffectContainer(spacing: 20.0) {
                VStack(spacing: 20.0) {
                    PanningView(player: player, panningValue: $player.panningValue)
                        .frame(maxWidth: .infinity, maxHeight: 80)
                        .padding()
                        .glassEffect()

                    RateView(player: player, rateValue: $player.rateValue)
                        .frame(maxWidth: .infinity, maxHeight: 80)
                        .padding()
                        .glassEffect()
                    
                    LoopView(
                        player: player,
                        loopStart: $player.loopStart,
                        loopStartLocked: $loopStartLocked,
                        loopEnd: $player.loopEnd,
                        loopEndLocked: $loopEndLocked,
                        isLooping: $player.isLooping)
                    .frame(maxWidth: .infinity, maxHeight: 80)
                    .padding()
                    .glassEffect()
                }
            }
            
            Spacer()
            
            PlaybackProgressView(
                player: player,
                duration: $player.duration,
                progress: $player.progress,
                isEditingProgress: $isEditingProgress,
                loopStart: $player.loopStart,
                loopStartLocked: $loopStartLocked,
                loopEnd: $player.loopEnd,
                loopEndLocked: $loopEndLocked)
            
            HStack {
                Rectangle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.clear)
                
                Spacer()
                
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
                
                Spacer()
                
                AirPlayButton()
                    .frame(width: 40, height: 40)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard)
        .padding(20)
        .sheet(isPresented: $isAddSongSheetPresented) {
            EditSongView(song: $song)
//                .presentationBackground(.ultraThinMaterial)
                .interactiveDismissDisabled(true)
        }
        .onAppear() {
            loopStartLocked = player.loopStart != nil
            loopEndLocked = player.loopEnd != nil
        }
        .presentationDragIndicator(.visible)
//        .presentationBackground(LinearGradient(gradient: Gradient(colors: [.clear, .blue, .blue, .blue, .blue]/*[.otsblue, .clear, .clear, .clear, .clear]*/), startPoint: .top, endPoint: .bottom))
//        .opacity(sheetProgress)
//        .scaleEffect(0.85 + 0.15 * sheetProgress)
    }
}

#Preview {
    struct PlayerView_Preview: View {
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
        
        @State var showSheet: Bool = true
        
        @Namespace private var ns
        
        var body: some View {
            VStack {
                Text("Test")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: $showSheet) {
                PlayerView(
                    song: $song,
                    isEditingProgress: $isEditingProgress,
                    player: player,
//                    namespace: ns,
//                    sheetProgress: 1
                )
                .presentationBackground(.ultraThinMaterial)
            }
        }
    }
    
    return PlayerView_Preview()
}
