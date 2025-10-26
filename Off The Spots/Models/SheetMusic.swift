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
    var id: UUID
    var name: String
    @Attribute(.externalStorage) var file: Data?
    
    init(name: String, file: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.file = file
    }
}
