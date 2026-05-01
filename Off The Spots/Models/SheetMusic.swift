//
//  SheetMusic.swift
//  Off The Spots
//
//  Created by David Freeman on 10/24/25.
//

import Foundation
import SwiftData

@Model
final class SheetMusic {
    var id: UUID = UUID()
    var name: String = ""
    @Attribute(.externalStorage) var file: Data?
    var song: Song?
    
    init(id: UUID = UUID(), name: String = "", file: Data? = nil) {
        self.id = id
        self.name = name
        self.file = file
    }
}
