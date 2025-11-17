//
//  PlayerView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI
import AVFoundation

struct PlayerView: View {
    @Binding var isEditingProgress: Bool
    @ObservedObject var player: AudioHelper
    
    @State private var loopStartLocked: Bool = false
    @State private var loopEndLocked: Bool = false
    @State private var isEditSongSheetPresented: Bool = false
    @State private var isAddToSetListSheetPresented: Bool = false
    
    @Namespace var animation
    @State private var presentSheetMusic: Bool = false
    
    @State private var showPlaybackProgress: Bool = true
    
    @Environment(\.otsProGroupId) var otsProGroupId
    @State private var isPro: Bool = false
    @State private var presentSubscription: Bool = false
    @State private var presentThanksSheet: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text(player.selectedSong!.name)
                    .font(.largeTitle)
                Spacer()
                Menu(content: {
                    Button(
                        action: {
                            if isPro {
                                isAddToSetListSheetPresented = true
                            } else {
                                presentSubscription = true
                            }
                        },
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
                Picker("Select a Track", selection: Binding(
                    get: { player.selectedSong!.selectedTrack.id },
                    set: { newId in
                        if let newTrack = player.selectedSong!.tracks.first(where: { $0.id == newId }) {
                            player.setSelectedTrack(track: newTrack)
                        }
                    }
                )) {
                    ForEach(player.selectedSong!.tracks, id: \.id) { track in
                        Text(track.name).tag(track.id)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primary)
//                .glassEffect()
                
                Spacer()
                
                Button(action: { presentSheetMusic = true }) {
                    Image(systemName: "music.pages.fill")
                    Text("Sheet Music")
                }
                .tint(.primary)
                .disabled(player.selectedSong!.sheetMusic?.file == nil || !isPro)
                .matchedTransitionSource(id: "sheetmusic", in: animation)
                .fullScreenCover(isPresented: $presentSheetMusic) {
                    SheetMusicView(
                        sheetMusicFile: player.selectedSong!.sheetMusic!.file!,
                        dismissSheetMusicView: { presentSheetMusic = false },
                        player: player
                    )
                    .navigationTransition(.zoom(sourceID: "sheetmusic", in: animation))
                }
                .onTapGesture {
                    if !isPro {
                        presentSubscription = true
                    }
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
                    setList: player.selectedSetList,
                    currentSong: player.selectedSong!,
                    setSelectedSong: player.setSelectedSong
                )
                .frame(width: 40, height: 40)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard)
        .padding(20)
        .sheet(isPresented: $isAddToSetListSheetPresented) { AddToSetListView(song: player.selectedSong!) }
        .sheet(isPresented: $isEditSongSheetPresented) {
            EditSongView(
                    song: Binding(
                        get: { player.selectedSong! },
                        set: { newValue in player.selectedSong = newValue }
                    )
                )
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
        .onChange(of: player.selectedSong!) {
            showPlaybackProgress = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { showPlaybackProgress = true }
        }
        .ignoresSafeArea(.keyboard)
        .background(backgroundGradient)
        .sheet(isPresented: $presentSubscription) { SubscriptionView(presentThanksSheet: $presentThanksSheet, inSheet: true) }
        .sheet(isPresented: $presentThanksSheet) { ThanksView() }
        .subscriptionStatusTask(for: otsProGroupId) { taskState in
            if let statuses = taskState.value {
                isPro = StoreHelper().checkForActiveSubscription(in: statuses)
            } else {
                isPro = false
            }
        }
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
                if player.selectedSong != nil {
                    PlayerView(
                        isEditingProgress: $isEditingProgress,
                        player: player
                    )
                }
            }
            .onAppear { player.setSelectedSong(song: song, setList: nil) }
        }
    }
    
    return PlayerView_Preview()
}
