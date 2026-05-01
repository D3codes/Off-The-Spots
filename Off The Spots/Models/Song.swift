//
//  Song.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import Foundation
import SwiftData

@Model
final class Song {
    var id: UUID = UUID()
    var order: Int = 0
    var name: String = ""
    @Relationship(deleteRule: .cascade, inverse: \Track.song)
    var tracks: [Track]? = []
    @Relationship(inverse: \Track.selectedBySong)
    var selectedTrack: Track?
    @Relationship(deleteRule: .cascade, inverse: \SheetMusic.song)
    var sheetMusic: SheetMusic?

    var sortedTracks: [Track] {
        (tracks ?? []).sorted {
            if $0.order == $1.order {
                return $0.id.uuidString < $1.id.uuidString
            }

            return $0.order < $1.order
        }
    }

    var activeTrack: Track? {
        selectedTrack ?? sortedTracks.first
    }

    var trackCount: Int {
        tracks?.count ?? 0
    }

    var hasTracks: Bool {
        trackCount > 0
    }

    var activeTrackName: String {
        activeTrack?.name ?? ""
    }
    
    init(id: UUID = UUID(), name: String = "", tracks: [Track] = [], selectedTrack: Track? = nil, order: Int = 0, sheetMusic: SheetMusic? = nil) {
        self.id = id
        self.order = order
        self.name = name
        self.tracks = tracks
        tracks.enumerated().forEach { index, track in
            track.order = index
        }
        self.selectedTrack = selectedTrack ?? tracks.first
        self.sheetMusic = sheetMusic
    }
}
