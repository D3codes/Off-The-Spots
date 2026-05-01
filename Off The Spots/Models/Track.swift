//
//  Track.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import Foundation
import SwiftData

@Model
final class Track {
    var id: UUID = UUID()
    var order: Int = 0
    var name: String = ""
    @Attribute(.externalStorage) var file: Data?
    var song: Song?
    var selectedBySong: Song?
    
    init(id: UUID = UUID(), name: String = "", order: Int = 0, file: Data? = nil) {
        self.id = id
        self.order = order
        self.name = name
        self.file = file
    }
}
