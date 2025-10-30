//
//  SetList.swift
//  Off The Spots
//
//  Created by David Freeman on 10/29/25.
//

import Foundation
import SwiftData

@Model
final class SetList {
    var id: UUID
    var order: Int
    var name: String
    var songs: [Song]
    
    init(id: UUID = UUID(), order: Int = 0, name: String, songs: [Song]) {
        self.id = id
        self.order = order
        self.name = name
        self.songs = songs
    }
}

