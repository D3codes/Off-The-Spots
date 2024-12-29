//
//  MainView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI
import SwiftData
import AVFoundation
import MediaPlayer

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var songs: [Song]
    @State var selectedSong: Song?
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying: Bool = false
    @State private var progress: Double = 0.0
    @State private var isEditingProgress: Bool = false
    
    @State private var addSongInitialTrackUrl: URL?
    @State private var presentAddSongPopover: Bool = false
    
    @State private var presentSongSheet: Bool = false
    
    @State private var presentSettingsSheet: Bool = false

    var body: some View {
        Group {
            if(songs.isEmpty) {
                VStack(alignment: .trailing) {
                    VStack(alignment: .trailing) {
                        Image(systemName: "arrowshape.up.fill")
                            .font(.title)
                            .padding(.trailing, 13)
                            .symbolEffect(.wiggle.byLayer, options: .speed(0.5).repeat(.continuous))
                        Text("Add a song to get started")
                            .padding(.trailing, 20)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            } else {
                List {
                    ForEach(songs) { song in
                        Button(action: {
                            setSelectedSong(song: song)
                            presentSongSheet = true
                        }, label: {
                            Text(song.name)
                        })
                    }
                    .onDelete(perform: deleteSongs)
                }
            }
        }
        .safeAreaInset(edge: .top) {
            HeaderView(songs: songs, presentSettingsSheet: $presentSettingsSheet, presentAddSongPopover: $presentAddSongPopover)
        }
        .safeAreaInset(edge: .bottom) {
            if(selectedSong != nil) {
                BottomBarView(
                    presentSongSheet: $presentSongSheet,
                    song: selectedSong!,
                    audioPlayer: audioPlayer!,
                    isPlaying: $isPlaying
                )
            }
        }
        .sheet(isPresented: $presentSongSheet) {
            SongView(
                song: Binding($selectedSong)!,
                progress: $progress,
                isEditingProgress: $isEditingProgress,
                audioPlayer: Binding($audioPlayer)!,
                isPlaying: $isPlaying
            )
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $presentSettingsSheet) {
            SettingsView()
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $presentAddSongPopover) {
            AddSongView(presentAddSongPopover: $presentAddSongPopover, addSong: { modelContext.insert($0) })
        }
        .onAppear() {
            setSelectedSong(song: selectedSong)
            setupRemoteTransportControls()
        }
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            updateProgress()
        }
    }

    private func deleteSongs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                if(selectedSong?.id == songs[index].id) {
                    selectedSong = nil
                    
                    if(isPlaying) {
                        audioPlayer?.stop()
                        isPlaying = false
                    }
                }
                
                modelContext.delete(songs[index])
            }
        }
    }
    
    private func setSelectedSong(song: Song?) {
        if let song {
            selectedSong = song
            progress = 0
            isPlaying = false
            
            do {
                audioPlayer = try AVAudioPlayer(data: song.selectedTrack.file!)
                audioPlayer?.enableRate = true
            } catch {
                print("oops")
            }
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print(error)
            }
            
            setupNowPlaying()
        }
    }
    
    private func play() {
        guard let audioPlayer else { return }
        audioPlayer.play()
        isPlaying = true
        updateNowPlaying()
    }
    
    private func pause() {
        guard let audioPlayer else { return }
        audioPlayer.pause()
        isPlaying = false
        updateNowPlaying()
    }
    
    private func updateProgress() {
        guard let audioPlayer = audioPlayer, audioPlayer.isPlaying else { return }
        if isEditingProgress { return }
        
        progress = audioPlayer.currentTime
        updateNowPlaying()
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { _ in
            if !self.audioPlayer!.isPlaying {
                self.play()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { _ in
            if self.audioPlayer!.isPlaying {
                self.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    private func setupNowPlaying() {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = selectedSong!.name
        nowPlayingInfo[MPMediaItemPropertyArtist] = selectedSong!.selectedTrack.name

//        if let image = UIImage(named: "logo") {
//            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
//                return image
//            }
//        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer!.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer!.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer!.rate

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateNowPlaying() {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo!

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer!.currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1 : 0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

#Preview {
    struct MainView_Preview: View {
        var body: some View {
            MainView()
            .modelContainer(for: Song.self, inMemory: true)
        }
    }
    
    return MainView_Preview()
}
