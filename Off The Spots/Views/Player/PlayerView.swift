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
    @State var setList: SetList?
    var setSelectedSong: (Song, SetList?) -> Void = {song, setList in }
    
    @State private var loopStartLocked: Bool = false
    @State private var loopEndLocked: Bool = false
    @State private var isEditSongSheetPresented: Bool = false
    @State private var isAddToSetListSheetPresented: Bool = false
    
    @State private var presentSheetMusic: Bool = false
    
    @State private var showPlaybackProgress: Bool = true
    
    var body: some View {
        VStack {
            HStack {
                Text(song.name)
                    .font(.largeTitle)
                Spacer()
                Menu(content: {
                    Button(
                        action: { isAddToSetListSheetPresented = true },
                        label: { Label("Add to Set List", systemImage: "music.note.list") }
                    )
                    Button(
                        action: { isEditSongSheetPresented = true },
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
            
            HStack {
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
//                .glassEffect()
                
                Spacer()
                
                Button(action: { presentSheetMusic = true }) {
                    Image(systemName: "music.pages.fill")
                    Text("Sheet Music")
                }
                .tint(.primary)
                .disabled(song.sheetMusic?.file == nil)
                .fullScreenCover(isPresented: $presentSheetMusic) {
                    SheetMusicView(
                        sheetMusicFile: song.sheetMusic!.file!,
                        dismissSheetMusicView: { presentSheetMusic = false },
                        player: player
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            Spacer()
            
            GlassEffectContainer(spacing: 10.0) {
                VStack(spacing: 10.0) {
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
            
            // Necessary to force rerender when song changes
            if showPlaybackProgress {
                PlaybackProgressView(
                    player: player,
                    duration: $player.duration,
                    progress: $player.progress,
                    isEditingProgress: $isEditingProgress,
                    loopStart: $player.loopStart,
                    loopStartLocked: $loopStartLocked,
                    loopEnd: $player.loopEnd,
                    loopEndLocked: $loopEndLocked)
            } else {
                PlaybackProgressView(
                    player: player,
                    duration: $player.duration,
                    progress: $player.progress,
                    isEditingProgress: $isEditingProgress,
                    loopStart: $player.loopStart,
                    loopStartLocked: $loopStartLocked,
                    loopEnd: $player.loopEnd,
                    loopEndLocked: $loopEndLocked)
            }
            
            HStack {
                AirPlayButton()
                    .frame(width: 40, height: 40)
                
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
                
                SetListMenuView(
                    setList: setList,
                    currentSong: song,
                    setSelectedSong: setSelectedSong
                )
                .frame(width: 40, height: 40)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard)
        .padding(20)
        .sheet(isPresented: $isAddToSetListSheetPresented) {
            AddToSetListView(song: song)
        }
        .sheet(isPresented: $isEditSongSheetPresented) {
            EditSongView(song: $song)
                .interactiveDismissDisabled(true)
        }
        .onAppear() {
            loopStartLocked = player.loopStart != nil
            loopEndLocked = player.loopEnd != nil
            player.publishProgressChanges = true
        }
        .onDisappear {
            player.publishProgressChanges = false
        }
        .presentationDragIndicator(.visible)
        .onChange(of: song) {
            showPlaybackProgress = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { showPlaybackProgress = true }
        }
        .presentationBackground(backgroundGradient)
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
                Button(action: { showSheet = true }) {
                    Text("Show Player Sheet")
                }
                .buttonStyle(.glass)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: $showSheet) {
                PlayerView(
                    song: $song,
                    isEditingProgress: $isEditingProgress,
                    player: player
                )
            }
        }
    }
    
    return PlayerView_Preview()
}
