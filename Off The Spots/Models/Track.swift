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
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
