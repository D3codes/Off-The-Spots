//
//  WidgetSongPlayback.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/26.
//

import SwiftData
import Foundation

@MainActor
enum WidgetSongPlayback {
    enum Selection {
        case song(Song)
        case subscriptionRequired
        case missingSong
        case missingAudio
    }

    static func selection(songID: UUID, songs: [Song], isPro: Bool) -> Selection {
        guard let index = songs.firstIndex(where: { $0.id == songID }) else { return .missingSong }
        guard isPro || index < 3 else { return .subscriptionRequired }
        let song = songs[index]
        guard song.activeTrack?.file != nil else { return .missingAudio }
        return .song(song)
    }

    @discardableResult
    static func play(songID: UUID, songs: [Song], isPro: Bool, player: AudioHelper) -> Selection {
        let result = selection(songID: songID, songs: songs, isPro: isPro)
        if case .song(let song) = result {
            player.setSelectedSong(song: song, setList: nil)
            player.play()
        }
        return result
    }
}
