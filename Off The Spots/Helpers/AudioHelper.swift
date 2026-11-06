//
//  AudioHelper.swift
//  Off The Spots
//
//  Created by David Freeman on 12/29/24.
//

import AVFoundation
import MediaPlayer
import Observation
import SwiftData

private final class AudioHelperRelay: @unchecked Sendable {
    weak var helper: AudioHelper?

    init(helper: AudioHelper) {
        self.helper = helper
    }
}

extension Notification.Name {
    static let audioHelperSelectedSongDidChange = Notification.Name("audioHelperSelectedSongDidChange")
}

@Observable
final class PlaybackProgress {
    var value: Double = 0
}

class AudioHelper: NSObject, ObservableObject {
    @MainActor static let sharedController: AudioHelper = AudioHelper()
    
    @Published var selectedSong: Song? = nil
    @Published var selectedSetList: SetList? = nil
    
    @Published var isPlaying: Bool = false
    @Published private(set) var isPreparingToPlay: Bool = false
    var isPlaybackRequested: Bool { isPlaying || isPreparingToPlay }
    // Progress updates notify only views that read this model, not every player observer.
    let playbackProgress = PlaybackProgress()
    @Published var duration: Double = 0
    @Published var panningValue: Double = 0
    @Published var rateValue: Float = 1.0
    @Published var isLooping: Bool = false
    @Published var loopStart: Double? = nil
    @Published var loopEnd: Double? = nil
    @Published var repeatOne: Bool = false
    @Published var repeatAll: Bool = false
    
    var publishProgressChanges: Bool = false

    private let engine: AVAudioEngine = AVAudioEngine()
    private let speedAndPitchControl: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    private let audioPlayer: AVAudioPlayerNode = AVAudioPlayerNode()
    
    private var needsFileScheduled: Bool = true

    private var audioFile: AVAudioFile?
    private var temporaryAudioURL: URL?
    private var playbackRequestGeneration: Int = 0
    var audioSampleRate: Double = 0

    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    private var scheduleGeneration: Int = 0

    private var renderedFileFrames: AVAudioFramePosition {
        guard let lastRenderTime = audioPlayer.lastRenderTime,
              let playerTime = audioPlayer.playerTime(forNodeTime: lastRenderTime),
              playerTime.isSampleTimeValid,
              playerTime.sampleRate > 0 else { return 0 }

        // The node's clock can run at a different sample rate than the file.
        return AVAudioFramePosition(Double(playerTime.sampleTime) / playerTime.sampleRate * audioSampleRate)
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
    
    func setSelectedSong(song: Song, setList: SetList?, skipSameCheck: Bool = false, skipRepeatReset: Bool = false) {
        if !skipSameCheck && song.id == selectedSong?.id && setList?.id == selectedSetList?.id { return }

        selectedSong = song
        selectedSetList = setList
        
        resetScheduledAudio()
        setPan(value: 0.0)
        speedAndPitchControl.rate = 1.0
        rateValue = 1.0
        clearLoopStart()
        clearLoopEnd()
        if !skipRepeatReset {
            clearRepeats()
        }
        
        do {
            if song.selectedTrack == nil {
                song.selectedTrack = song.sortedTracks.first
            }

            guard let track = song.activeTrack, let data = track.file else {
                print("Selected track has no data")
                return
            }

            let tempURL = try AudioTrackFile.writeTemporaryFile(data: data, fileExtension: track.fileExtension)
            temporaryAudioURL = tempURL

            audioFile = try AVAudioFile(forReading: tempURL, commonFormat: .pcmFormatFloat32, interleaved: false)
            let format = audioFile!.processingFormat
            audioLengthSamples = audioFile!.length
            audioSampleRate = format.sampleRate
            duration = Double(audioLengthSamples) / audioSampleRate

            scheduleAudioFile()
        } catch {
            removeTemporaryAudioFile()
            print("Failed to prepare audio engine/player with error: \(error)")
        }

        setupNowPlaying()
        NotificationCenter.default.post(name: .audioHelperSelectedSongDidChange, object: self)
    }
    
    func play() {
        guard audioLengthSamples > 0 else {
            isPlaying = false
            updateNowPlaying()
            return
        }

        guard !isPlaying, !isPreparingToPlay else { return }
        playbackRequestGeneration += 1
        let request = playbackRequestGeneration
        isPreparingToPlay = true
        let relay = AudioHelperRelay(helper: self)

        PlaybackAudioSession.activate { result in
            Task { @MainActor in
                guard let helper = relay.helper,
                      helper.playbackRequestGeneration == request else { return }
                helper.isPreparingToPlay = false
                switch result {
                case .success:
                    helper.startPlayback()
                case .failure(let error):
                    helper.isPlaying = false
                    helper.updateNowPlaying()
                    print("Failed to activate playback audio session: \(error)")
                }
            }
        }
    }

    private func startPlayback() {
        guard audioFile != nil else { return }

        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                isPlaying = false
                updateNowPlaying()
                print("Failed to start audio engine: \(error)")
                return
            }
        }
        
        if needsFileScheduled {
            if seekFrame == audioLengthSamples {
                seekFrame = 0
                currentPosition = 0
            }
            scheduleAudioFile()
        }
        
        audioPlayer.play()
        isPlaying = true
        updateNowPlaying()
    }
    
    func pause() {
        cancelPendingPlayback()
        audioPlayer.pause()
        engine.pause()
        isPlaying = false
        updateNowPlaying()
    }
    
    func stop() {
        cancelPendingPlayback()
        scheduleGeneration += 1
        audioPlayer.stop()
        engine.stop()
        needsFileScheduled = true
        seekFrame = 0
        playbackProgress.value = 0
        currentPosition = 0
        isPlaying = false
        updateNowPlaying()
    }
    
    func skip(seconds: Double) {
        currentPosition = renderedFileFrames + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        
        let offset = AVAudioFramePosition(seconds * audioSampleRate)
        seekFrame = currentPosition + offset
        setCurrentTime(value: seekFrame)
    }
    
    func setCurrentTime(value: AVAudioFramePosition) {
        guard audioFile != nil else { return }

        let requestedFrame = min(max(value, 0), audioLengthSamples)
        seekFrame = loopRestartFrame(at: requestedFrame) ?? requestedFrame
        currentPosition = seekFrame

        let wasPlaying = audioPlayer.isPlaying
        scheduleGeneration += 1
        audioPlayer.stop()
        needsFileScheduled = true

        if currentPosition == audioLengthSamples {
            if wasPlaying {
                finishPlayback()
            } else {
                publishCurrentPosition()
            }
            return
        }

        scheduleAudioFile()
        if wasPlaying {
            audioPlayer.play()
        }
        publishCurrentPosition()
    }
    
    @objc func updateProgress() {
        currentPosition = renderedFileFrames + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        
        // The completion callback handles EOF after the output finishes playing.
        if currentPosition < audioLengthSamples, let restartFrame = loopRestartFrame(at: currentPosition) {
            setCurrentTime(value: restartFrame)
            return
        }

        publishCurrentPosition()
    }

    private func publishCurrentPosition() {
        if publishProgressChanges {
            playbackProgress.value = Double(currentPosition) / audioSampleRate
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

        if let restartFrame = loopRestartFrame(at: currentPosition) {
            setCurrentTime(value: restartFrame)
        }
    }

    private func loopRestartFrame(at position: AVAudioFramePosition) -> AVAudioFramePosition? {
        guard isLooping, let loopStart, let loopEnd else { return nil }
        let startFrame = AVAudioFramePosition(loopStart * audioSampleRate)
        guard startFrame < audioLengthSamples else { return nil }
        let endFrame = loopEnd == duration ? audioLengthSamples : AVAudioFramePosition(loopEnd * audioSampleRate)
        // The end frame is outside the loop, including when it is the end of the file.
        return position < startFrame || position >= max(startFrame + 1, endFrame) ? startFrame : nil
    }
    
    func stopLoop() {
        isLooping = false
    }
    
    func incrementRepeat() {
        if selectedSetList != nil {
            if repeatAll {
                repeatAll = false
                repeatOne = true
            } else if repeatOne {
                repeatOne = false
                repeatAll = false
            } else {
                repeatAll = true
                repeatOne = false
            }
        } else {
            if repeatOne {
                repeatOne = false
                repeatAll = false
            } else {
                repeatOne = true
                repeatAll = false
            }
        }
    }
    
    func clearRepeats() {
        repeatOne = false
        repeatAll = false
    }
    
    private func scheduleAudioFile() {
        guard let file = audioFile, needsFileScheduled, seekFrame < audioLengthSamples else { return }

        needsFileScheduled = false
        let relay = AudioHelperRelay(helper: self)
        let generation = scheduleGeneration

        let completion: @Sendable (AVAudioPlayerNodeCompletionCallbackType) -> Void = { _ in
            Task { @MainActor in
                guard let helper = relay.helper, helper.scheduleGeneration == generation else { return }

                if let restartFrame = helper.loopRestartFrame(at: helper.audioLengthSamples) {
                    helper.setCurrentTime(value: restartFrame)
                } else {
                    helper.finishPlayback()
                }
            }
        }

        if seekFrame == 0 {
            audioPlayer.scheduleFile(file, at: nil, completionCallbackType: .dataPlayedBack, completionHandler: completion)
        } else {
            audioPlayer.scheduleSegment(
                file,
                startingFrame: seekFrame,
                frameCount: AVAudioFrameCount(audioLengthSamples - seekFrame),
                at: nil,
                completionCallbackType: .dataPlayedBack,
                completionHandler: completion
            )
        }
    }

    private func resetScheduledAudio() {
        cancelPendingPlayback()
        scheduleGeneration += 1
        audioPlayer.stop()
        audioFile = nil
        removeTemporaryAudioFile()
        audioSampleRate = 1
        audioLengthSamples = 0
        duration = 0
        needsFileScheduled = true
        seekFrame = 0
        currentPosition = 0
        isPlaying = false
        playbackProgress.value = 0
    }

    private func cancelPendingPlayback() {
        playbackRequestGeneration += 1
        isPreparingToPlay = false
    }

    private func removeTemporaryAudioFile() {
        if let temporaryAudioURL {
            try? FileManager.default.removeItem(at: temporaryAudioURL)
            self.temporaryAudioURL = nil
        }
    }
    
    private func finishPlayback() {
        let wasPlaying = isPlaying
        stop()
        guard wasPlaying else { return }
        
        let descriptor = FetchDescriptor<Song>(sortBy: [SortDescriptor(\.order, order: .forward)])
        let songs = (try? modelContext.fetch(descriptor)) ?? []
        
        if repeatOne {
            play()
            return
        }
        
        if selectedSetList != nil {
            var currentSongIndex = selectedSetList!.songs.firstIndex(of: selectedSong!.id)!
            if currentSongIndex == selectedSetList!.songs.count - 1 {
                if repeatAll {
                    currentSongIndex = -1
                } else {
                    return
                }
            }
            
            let nextSong: Song? = songs.first(where: { $0.id == selectedSetList!.songs[currentSongIndex + 1] })
            guard let nextSong else { return }
            
            setSelectedSong(song: nextSong, setList: selectedSetList, skipRepeatReset: true)
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

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateNowPlaying() {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Double(currentPosition) / audioSampleRate
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? speedAndPitchControl.rate : 0

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
            if !self.audioPlayer.isPlaying && !self.isPreparingToPlay {
                self.play()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { _ in
            if self.audioPlayer.isPlaying || self.isPreparingToPlay {
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
