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
    var sheetMusic: SheetMusic?
    
    init(id: UUID = UUID(), name: String, tracks: [Track], selectedTrack: Track, order: Int = 0, sheetMusic: SheetMusic? = nil) {
        self.id = id
        self.order = order
        self.name = name
        self.tracks = tracks
        self.selectedTrack = selectedTrack
        self.sheetMusic = sheetMusic
    }
}

