//
//  Off_The_SpotsTests.swift
//  Off The SpotsTests
//
//  Created by David Freeman on 12/3/24.
//

import AVFoundation
import AudioToolbox
import Foundation
import SwiftData
import Testing
@testable import Off_The_Spots

struct Off_The_SpotsTests {

    @MainActor
    @Test func extensionSurvivesDraftingAndPersistence() throws {
        let schema = OffTheSpotsPersistence.schema
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        let track = Track(name: "Bass", fileExtension: "MP3")
        context.insert(track)

        var draft = TrackDraft(track: track)
        draft.name = "Bass Left"
        #expect(draft.fileExtension == "MP3")
        track.name = draft.name
        track.fileExtension = draft.fileExtension
        try context.save()

        let reloadedContext = ModelContext(container)
        let reloaded = try #require(reloadedContext.fetch(FetchDescriptor<Track>()).first)
        #expect(reloaded.name == "Bass Left")
        #expect(reloaded.fileExtension == "MP3")
        #expect(Track(name: "Legacy").fileExtension == nil)
    }

    @Test(arguments: ["mp3", "MP3", "wav", "aiff", "m4a"])
    func temporaryFilePreservesImportedExtension(fileExtension: String) throws {
        let data = Data([1, 2, 3, 4])
        let url = try AudioTrackFile.writeTemporaryFile(data: data, fileExtension: fileExtension)
        defer { try? FileManager.default.removeItem(at: url) }
        #expect(url.pathExtension == fileExtension)
        #expect(try Data(contentsOf: url) == data)
    }

    @Test(arguments: ["wav", "aiff"])
    func legacyPCMTracksRecoverTheirContainerExtension(fileExtension: String) throws {
        let sourceURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).appendingPathExtension(fileExtension)
        defer { try? FileManager.default.removeItem(at: sourceURL) }
        // Explicit container types avoid AVAudioFile's writer choosing AIFC
        // even when its output URL ends in .aiff.
        var format = AudioStreamBasicDescription(
            mSampleRate: 44100, mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked |
                (fileExtension == "aiff" ? kAudioFormatFlagIsBigEndian : 0),
            mBytesPerPacket: 4, mFramesPerPacket: 1, mBytesPerFrame: 4,
            mChannelsPerFrame: 2, mBitsPerChannel: 16, mReserved: 0
        )
        do {
            var reference: AudioFileID?
            let type = fileExtension == "aiff" ? kAudioFileAIFFType : kAudioFileWAVEType
            #expect(AudioFileCreateWithURL(sourceURL as CFURL, type, &format, .eraseFile, &reference) == noErr)
            let file = try #require(reference)
            defer { AudioFileClose(file) }
            let silence = Data(repeating: 0, count: 1024 * 4)
            var byteCount = UInt32(silence.count)
            let status = silence.withUnsafeBytes {
                AudioFileWriteBytes(file, false, 0, &byteCount, $0.baseAddress!)
            }
            #expect(status == noErr)
        }
        let data = try Data(contentsOf: sourceURL)
        let url = try AudioTrackFile.writeTemporaryFile(data: data, fileExtension: nil)
        defer { try? FileManager.default.removeItem(at: url) }
        #expect(url.pathExtension == fileExtension)
        #expect(try Data(contentsOf: url) == data)
        let audio = try AVAudioFile(forReading: url, commonFormat: .pcmFormatFloat32, interleaved: false)
        #expect(audio.processingFormat.sampleRate == 44100)
        #expect(audio.length == 1024)
    }

    @Test(arguments: [nil, "", "mp3"] as [String?])
    func paddedMP3OpensForNewAndLegacyTracks(fileExtension: String?) throws {
        // Generated silence with the same 626-byte padding as the reported file.
        let fixture = try #require(Bundle(for: AudioTestBundle.self).url(forResource: "PaddedMP3", withExtension: "mp3"))
        let data = try Data(contentsOf: fixture)
        let url = try AudioTrackFile.writeTemporaryFile(data: data, fileExtension: fileExtension)
        defer { try? FileManager.default.removeItem(at: url) }
        #expect(url.pathExtension == "mp3")
        #expect(try Data(contentsOf: url) == data)
        let audio = try AVAudioFile(forReading: url, commonFormat: .pcmFormatFloat32, interleaved: false)
        let buffer = try #require(AVAudioPCMBuffer(pcmFormat: audio.processingFormat, frameCapacity: 1024))
        try audio.read(into: buffer)
        #expect(buffer.frameLength > 0)
    }

    @Test func unknownLegacyDataIsNotMislabeledAsM4A() throws {
        let url = try AudioTrackFile.writeTemporaryFile(data: Data([0, 1, 2]), fileExtension: nil)
        defer { try? FileManager.default.removeItem(at: url) }
        #expect(url.pathExtension.isEmpty)
    }

    @MainActor
    @Test func playbackUsesFileTimeAndFinishesWithoutProgressPolling() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).appendingPathExtension("wav")
        defer { try? FileManager.default.removeItem(at: url) }
        let format = try #require(AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 32_000, channels: 2, interleaved: true))
        let buffer = try #require(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 128_000))
        buffer.frameLength = buffer.frameCapacity
        let samples = try #require(buffer.floatChannelData)[0]
        samples.update(repeating: 0, count: Int(buffer.frameLength) * Int(format.channelCount))
        do {
            let file = try AVAudioFile(forWriting: url, settings: format.settings, commonFormat: .pcmFormatFloat32, interleaved: true)
            try file.write(from: buffer)
        }

        let track = Track(name: "32 kHz", file: try Data(contentsOf: url), fileExtension: "wav")
        let player = AudioHelper()
        defer { player.stop() }
        player.publishProgressChanges = true
        player.setSelectedSong(song: Song(name: "Timing Test", tracks: [track]), setList: nil)
        try #require(player.duration == 4)
        player.play()

        let clock = ContinuousClock()
        let activationDeadline = clock.now + .seconds(5)
        while player.isPreparingToPlay && clock.now < activationDeadline {
            try await Task.sleep(for: .milliseconds(20))
        }
        try #require(player.isPlaying)
        let firstSampleAt = clock.now
        player.updateProgress()
        let firstPosition = player.playbackProgress.value

        try await Task.sleep(for: .milliseconds(1500))
        let elapsed = firstSampleAt.duration(to: clock.now)
        player.updateProgress()
        let reported = Duration.seconds(player.playbackProgress.value - firstPosition)
        #expect(reported > elapsed - .milliseconds(300))
        #expect(reported < elapsed + .milliseconds(300))

        while player.isPlaying && clock.now < firstSampleAt + .seconds(6) {
            try await Task.sleep(for: .milliseconds(20))
        }
        #expect(!player.isPlaying)
        let remaining = Duration.seconds(player.duration - firstPosition)
        #expect(clock.now >= firstSampleAt + remaining - .milliseconds(200))
        #expect(player.playbackProgress.value == 0)
    }

    @MainActor
    @Test func sectionLoopWrapsAtEndOfTrack() throws {
        let fixture = try #require(Bundle(for: AudioTestBundle.self).url(forResource: "PaddedMP3", withExtension: "mp3"))
        let track = Track(name: "Practice", file: try Data(contentsOf: fixture), fileExtension: "mp3")
        let player = AudioHelper()
        defer { player.stop() }
        player.publishProgressChanges = true
        player.setSelectedSong(song: Song(name: "Loop Test", tracks: [track]), setList: nil)
        try #require(player.duration > 0)

        let lastFrame = AVAudioFramePosition((player.duration * player.audioSampleRate).rounded())
        let start = Double(lastFrame / 2) / player.audioSampleRate
        try #require(player.setLoopStart(value: start))
        try #require(player.setLoopEnd(value: player.duration))

        // Enabling the loop while parked at EOF and seeking to EOF with the loop active both wrap.
        player.setCurrentTime(value: lastFrame)
        player.startLoop()
        #expect(abs(player.playbackProgress.value - start) <= 1 / player.audioSampleRate)

        player.setCurrentTime(value: lastFrame)
        #expect(abs(player.playbackProgress.value - start) <= 1 / player.audioSampleRate)
    }

    @MainActor
    @Test func audioSessionActivatesOffMainThread() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PlaybackAudioSession.activate { result in
                #expect(!Thread.isMainThread)
                if case .success = result {
                    #expect(AVAudioSession.sharedInstance().category == .playback)
                    #expect(!AVAudioSession.sharedInstance().categoryOptions.contains(.allowAirPlay))
                }
                continuation.resume(with: result)
            }
        }
    }

}

private final class AudioTestBundle: NSObject {}
