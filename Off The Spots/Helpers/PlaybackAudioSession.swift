//
//  PlaybackAudioSession.swift
//  Off The Spots
//
//  Created by David Freeman on 10/27/26.
//

import AVFoundation

enum PlaybackAudioSession {
    private static let queue = DispatchQueue(label: "codes.d3.Off-The-Spots.audio-session", qos: .userInitiated)

    static func activate(completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        queue.async {
            do {
                let session = AVAudioSession.sharedInstance()
                // Playback already supports AirPlay. Explicit .allowAirPlay is
                // only valid with .playAndRecord and causes a parameter error here.
                try session.setCategory(.playback, mode: .default)
                try session.setActive(true)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
