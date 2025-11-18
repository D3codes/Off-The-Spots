//
//  AudioHelper.swift
//  Off The Spots
//
//  Created by David Freeman on 12/29/24.
//

import AVFoundation
import MediaPlayer
import SwiftUI

class AudioHelper: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @MainActor static let sharedController = AudioHelper()
    
    private var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    @Published var selectedSong: Song? = nil
    @Published var selectedSetList: SetList? = nil
    
    @Published var isPlaying: Bool = false
    @Published var progress: Double = 0
    @Published var duration: Double = 0
    @Published var panningValue: Double = 0
    @Published var rateValue: Float = 1.0
    @Published var isLooping: Bool = false
    @Published var loopStart: Double? = nil
    @Published var loopEnd: Double? = nil
    
    var publishProgressChanges: Bool = false
    
    var handlePlayerDidFinishPlaying: () -> Void = {}
    
    override init() {
        super.init()
        setupRemoteTransportControls()
    }
    
    func play() {
        audioPlayer.play()
        isPlaying = true
        updateNowPlaying()
    }
    
    func pause() {
        audioPlayer.pause()
        isPlaying = false
        updateNowPlaying()
    }
    
    func stop() {
        audioPlayer.stop()
        isPlaying = false
        progress = 0
        updateNowPlaying()
    }
    
    func skip(seconds: Double) {
        if progress + seconds >= duration {
            audioPlayer.currentTime = duration - 0.5
        } else {
            audioPlayer.currentTime += seconds
        }
        
        updateProgress()
    }
    
    func setCurrentTime(value: Double) {
        audioPlayer.currentTime = value
        progress = value
    }
    
    func updateProgress() {
        if (isLooping && (audioPlayer.currentTime > loopEnd! || audioPlayer.currentTime < loopStart!)) {
            audioPlayer.currentTime = loopStart!
        }
        
        if publishProgressChanges {
            progress = audioPlayer.currentTime
        }
        
        updateNowPlaying()
    }
    
    func setPan(value: Double) {
        audioPlayer.pan = Float(value)
        panningValue = value
    }
    
    func setRate(value: Float) {
        audioPlayer.enableRate = true
        audioPlayer.rate = value
        rateValue = value
        
        updateNowPlaying()
    }
    
    func setLoopStart(value: Double) -> Bool {
        guard value < loopEnd ?? 9999999999 else { return false }
        loopStart = value
        return true
    }
    
    func clearLoopStart() {
        loopStart = nil
        stopLoop()
    }
    
    func setLoopEnd(value: Double) -> Bool {
        guard value > loopStart ?? 0 else { return false }
        loopEnd = value
        return true
    }
    
    func clearLoopEnd() {
        loopEnd = nil
        stopLoop()
    }
    
    func startLoop() {
        guard loopStart != nil, loopEnd != nil else { return }
        isLooping = true
        setCurrentTime(value: loopStart!)
    }
    
    func stopLoop() {
        isLooping = false
    }
    
    func setSelectedTrack(track: Track) {
        if track.id == selectedSong?.selectedTrack.id { return }
        
        stop()
        selectedSong!.selectedTrack = track
        setSelectedSong(song: selectedSong!, setList: selectedSetList)
    }
    
    func setSelectedSong(song: Song, setList: SetList?) {
        selectedSetList = setList
        
        isPlaying = false
        progress = 0
        setPan(value: 0.0)
        setRate(value: 1.0)
        clearLoopStart()
        clearLoopEnd()
        
        do {
            audioPlayer = try AVAudioPlayer(data: song.selectedTrack.file!)
            audioPlayer.enableRate = true
            audioPlayer.delegate = self
        } catch {
            print("Failed to create AVAudioPlayer with error: \(error)")
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set AVAudioSession category with error: \(error)")
        }
        
        duration = audioPlayer.duration
        selectedSong = song
        setupNowPlaying()
    }
    
    private func setupNowPlaying() {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = selectedSong?.name
//        nowPlayingInfo[MPMediaItemPropertyArtist] = selectedSong?.selectedTrack.name // required to show in control center
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = selectedSong?.selectedTrack.name // required to be selectable in CarPlay
        
        if let image = UIImage(named: "logo") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer.rate

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateNowPlaying() {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? audioPlayer.rate : 0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { _ in
            if !self.audioPlayer.isPlaying {
                self.play()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { _ in
            if self.audioPlayer.isPlaying {
                self.pause()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.stopCommand.addTarget { _ in
            self.stop()
            return .success
        }
        
        commandCenter.skipBackwardCommand.addTarget { _ in
            self.skip(seconds: -10)
            return .success
        }
        
        commandCenter.skipForwardCommand.addTarget { _ in
            self.skip(seconds: 10)
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            guard let e = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            
            self.setCurrentTime(value: e.positionTime)
            return .success
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (flag) {
            handlePlayerDidFinishPlaying()
        }
    }
}

