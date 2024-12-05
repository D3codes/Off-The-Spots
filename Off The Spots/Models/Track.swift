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
    var id: UUID
    var name: String
    @Attribute(.externalStorage) var file: Data?
    
    init(name: String, file: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.file = file
    }
}
