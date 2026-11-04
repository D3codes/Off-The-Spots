//
//  WidgetSetListPlayback.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/26.
//

import Foundation

@MainActor
enum WidgetSetListPlayback {
    enum Selection {
        case song(Song, SetList)
        case subscriptionRequired
        case missingSetList
        case emptySetList
        case missingSong
        case missingAudio
    }

    static func selection(setListID: UUID, setLists: [SetList], songs: [Song], isPro: Bool) -> Selection {
        guard let setList = setLists.first(where: { $0.id == setListID }) else { return .missingSetList }
        guard isPro else { return .subscriptionRequired }
        guard let firstID = setList.songs.first else { return .emptySetList }
        guard let firstSong = songs.first(where: { $0.id == firstID }) else { return .missingSong }
        guard firstSong.activeTrack?.file != nil else { return .missingAudio }
        return .song(firstSong, setList)
    }

    @discardableResult
    static func play(setListID: UUID, setLists: [SetList], songs: [Song], isPro: Bool, player: AudioHelper) -> Selection {
        let result = selection(setListID: setListID, setLists: setLists, songs: songs, isPro: isPro)
        if case .song(let song, let setList) = result {
            // A set-list play action always starts over, even if its first song
            // is already selected. Retaining the set list enables the normal queue.
            player.setSelectedSong(song: song, setList: setList, skipSameCheck: true)
            player.play()
        }
        return result
    }
}
