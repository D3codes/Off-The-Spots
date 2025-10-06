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
    var id: UUID
    var order: Int = 0
    var name: String
    var tracks: [Track]
    var selectedTrack: Track
    
    init(id: UUID = UUID(), name: String, tracks: [Track], selectedTrack: Track, order: Int = 0) {
        self.id = id
        self.order = order
        self.name = name
        self.tracks = tracks
        self.selectedTrack = selectedTrack
    }
}

