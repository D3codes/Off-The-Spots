//
//  AudioHelper.swift
//  Off The Spots
//
//  Created by David Freeman on 12/29/24.
//

import AVFoundation
import MediaPlayer
import SwiftData

private final class AudioHelperRelay: @unchecked Sendable {
    weak var helper: AudioHelper?

    init(helper: AudioHelper) {
        self.helper = helper
    }
}

class AudioHelper: NSObject, ObservableObject {
    @MainActor static let sharedController: AudioHelper = AudioHelper()
    
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

    private let engine: AVAudioEngine = AVAudioEngine()
    private let speedAndPitchControl: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    private let audioPlayer: AVAudioPlayerNode = AVAudioPlayerNode()
    
    private var needsFileScheduled: Bool = true

    private var audioFile: AVAudioFile?
    var audioSampleRate: Double = 0

    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    private var scheduleGeneration: Int = 0

    private var currentFrame: AVAudioFramePosition {
      guard
        let lastRenderTime = audioPlayer.lastRenderTime,
        let playerTime = audioPlayer.playerTime(forNodeTime: lastRenderTime)
      else {
        return 0
      }

      return playerTime.sampleTime
    }
    
    private let container: ModelContainer
    private let modelContext: ModelContext
    
    override init() {
        container = OffTheSpotsPersistence.sharedModelContainer
        
        modelContext = ModelContext(container)
        
        super.init()
        
        engine.attach(audioPlayer)
        engine.attach(speedAndPitchControl)
        
        engine.connect(audioPlayer, to: speedAndPitchControl, format: nil)
        engine.connect(speedAndPitchControl, to: engine.mainMixerNode, format: nil)
        
        setupRemoteTransportControls()
    }
    
    func setSelectedTrack(track: Track) {
        guard let selectedSong else { return }
        if track.id == selectedSong.selectedTrack?.id || !(selectedSong.tracks ?? []).contains(where: { $0.id == track.id }) { return }

        stop()
        selectedSong.selectedTrack = track
        setSelectedSong(song: selectedSong, setList: selectedSetList, skipSameCheck: true)
    }
    
    func setSelectedSong(song: Song, setList: SetList?, skipSameCheck: Bool = false) {
        if !skipSameCheck && song.id == selectedSong?.id && setList?.id == selectedSetList?.id { return }

        selectedSong = song
        selectedSetList = setList
        
        resetScheduledAudio()
        setPan(value: 0.0)
        speedAndPitchControl.rate = 1.0
        rateValue = 1.0
        clearLoopStart()
        clearLoopEnd()
        
        do {
            if song.selectedTrack == nil {
                song.selectedTrack = song.sortedTracks.first
            }

            guard let data = song.activeTrack?.file else {
                print("Selected track has no data")
                return
            }

            let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let tempURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("m4a")
            do {
                try data.write(to: tempURL, options: [.atomic])
            } catch {
                print("Failed to write audio data to temp file: \(error)")
                return
            }

            audioFile = try AVAudioFile(forReading: tempURL)
            let format = audioFile!.processingFormat
            audioLengthSamples = audioFile!.length
            audioSampleRate = format.sampleRate
            duration = Double(audioLengthSamples) / audioSampleRate

            scheduleAudioFile()
        } catch {
            print("Failed to prepare audio engine/player with error: \(error)")
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set AVAudioSession category with error: \(error)")
        }

        setupNowPlaying()
    }
    
    func play() {
        guard audioFile != nil else {
            isPlaying = false
            updateNowPlaying()
            return
        }

        if !engine.isRunning {
            do { try engine.start() }
            catch { }
        }
        
        if needsFileScheduled {
          scheduleAudioFile()
        }
        
        audioPlayer.play()
        isPlaying = true
        updateNowPlaying()
    }
    
    func pause() {
        audioPlayer.pause()
        engine.pause()
        isPlaying = false
        updateNowPlaying()
    }
    
    func stop() {
        audioPlayer.stop()
        engine.stop()
        scheduleGeneration += 1
        needsFileScheduled = true
        seekFrame = 0
        progress = 0
        currentPosition = 0
        isPlaying = false
        updateNowPlaying()
    }
    
    func skip(seconds: Double) {
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        
        let offset = AVAudioFramePosition(seconds * audioSampleRate)
        seekFrame = currentPosition + offset
        setCurrentTime(value: seekFrame)
    }
    
    func setCurrentTime(value: AVAudioFramePosition) {
        guard let audioFile = audioFile else { return }

        seekFrame = value
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)
        currentPosition = seekFrame

        let wasPlaying = audioPlayer.isPlaying
        audioPlayer.stop()
        scheduleGeneration += 1

        if currentPosition < audioLengthSamples {
            updateProgress()
            needsFileScheduled = false

            let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
            let relay = AudioHelperRelay(helper: self)
            let generation = scheduleGeneration
            
            audioPlayer.scheduleSegment(
                audioFile,
                startingFrame: seekFrame,
                frameCount: frameCount,
                at: nil
            ) {
                Task { @MainActor in
                    guard let helper = relay.helper else { return }
                    guard helper.scheduleGeneration == generation else { return }
                    helper.needsFileScheduled = true

                    try? await Task.sleep(for: .seconds(2))
                    guard helper.scheduleGeneration == generation else { return }
                    helper.updateProgress()
                }
            }

            if wasPlaying {
              audioPlayer.play()
            }
        }
    }
    
    @objc func updateProgress() {
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        
        if currentPosition > 0 && currentPosition >= audioLengthSamples {
            stop()
            handlePlayerDidFinishPlaying()
        }
        
        if (isLooping && (currentPosition > AVAudioFramePosition(loopEnd! * audioSampleRate) || currentPosition < AVAudioFramePosition(loopStart! * audioSampleRate))) {
            setCurrentTime(value: AVAudioFramePosition(loopStart! * audioSampleRate))
        }

        if publishProgressChanges {
            progress = Double(currentPosition) / audioSampleRate
        }

        updateNowPlaying()
    }
    
    func setPan(value: Double) {
        audioPlayer.pan = Float(value)
        panningValue = value
    }
    
    func setRate(value: Float) {
        speedAndPitchControl.rate = value
        rateValue = value

        updateProgress()
    }
    
    func setLoopStart(value: Double) -> Bool {
        guard value < loopEnd ?? duration else { return false }
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
        setCurrentTime(value: AVAudioFramePosition(loopStart! * audioSampleRate))
    }
    
    func stopLoop() {
        isLooping = false
    }
    
    private func scheduleAudioFile() {
        guard let file = audioFile, needsFileScheduled
        else { return }

        needsFileScheduled = false
        seekFrame = 0
        let relay = AudioHelperRelay(helper: self)
        let generation = scheduleGeneration

        audioPlayer.scheduleFile(file, at: nil) {
            Task { @MainActor in
                guard let helper = relay.helper else { return }
                guard helper.scheduleGeneration == generation else { return }
                helper.needsFileScheduled = true

                try? await Task.sleep(for: .seconds(2))
                guard helper.scheduleGeneration == generation else { return }
                helper.updateProgress()
            }
        }
    }

    private func resetScheduledAudio() {
        audioPlayer.stop()
        scheduleGeneration += 1
        audioFile = nil
        audioSampleRate = 1
        audioLengthSamples = 0
        duration = 0
        needsFileScheduled = true
        seekFrame = 0
        currentPosition = 0
        isPlaying = false
        progress = 0
    }
    
    private func handlePlayerDidFinishPlaying() {
        isPlaying = false
        progress = 0
        
        let descriptor = FetchDescriptor<Song>(sortBy: [SortDescriptor(\.order, order: .forward)])
        let songs = (try? modelContext.fetch(descriptor)) ?? []
        
        if selectedSetList != nil {
            let currentSongIndex = selectedSetList!.songs.firstIndex(of: selectedSong!.id)!
            if currentSongIndex == selectedSetList!.songs.count - 1 { return }
            
            let nextSong: Song? = songs.first(where: { $0.id == selectedSetList!.songs[currentSongIndex + 1] })
            guard let nextSong else { return }
            
            setSelectedSong(song: nextSong, setList: selectedSetList)
            play()
        }
    }
    
    private func setupNowPlaying() {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = selectedSong?.name
//        nowPlayingInfo[MPMediaItemPropertyArtist] = selectedSong?.activeTrackName // required to show in control center
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = selectedSong?.activeTrackName // required to be selectable in CarPlay

        if let image = UIImage(named: "logo") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0

        MPNowPlayingInfoCenter.default().playbackState = .stopped
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateNowPlaying() {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Double(currentPosition) / audioSampleRate
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? speedAndPitchControl.rate : 0

        MPNowPlayingInfoCenter.default().playbackState = isPlaying ? .playing : .paused
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.changePlaybackRateCommand.isEnabled = true
        commandCenter.changePlaybackRateCommand.addTarget { event in
            guard let rateEvent = event as? MPChangePlaybackRateCommandEvent else { return .commandFailed }
            return .success
        }

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

            self.setCurrentTime(value: AVAudioFramePosition(e.positionTime * self.audioSampleRate))
            return .success
        }
    }
}
