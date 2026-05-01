//
//  CarPlayTemplateManager.swift
//  Off The Spots
//
//  Created by David Freeman on 11/16/25.
//

import CarPlay
import SwiftData

@MainActor
final class CarPlayTemplateManager: NSObject {
    let container: ModelContainer
    let modelContext: ModelContext
    let interfaceController: CPInterfaceController

    init(interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        
        container = OffTheSpotsPersistence.makeModelContainer()
        
        modelContext = ModelContext(container)
    }
    
    func connect() -> Void {
        interfaceController.delegate = self
        CPNowPlayingTemplate.shared.isAlbumArtistButtonEnabled = true
        CPNowPlayingTemplate.shared.add(self)
        self.setNowPlayingButtons()
    }
    
    func disconnect() -> Void {
        AudioHelper.sharedController.pause()
    }
}
