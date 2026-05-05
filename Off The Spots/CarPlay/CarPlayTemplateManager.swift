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
    private var selectedSongObserver: NSObjectProtocol?

    init(interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        
        container = OffTheSpotsPersistence.sharedModelContainer
        
        modelContext = ModelContext(container)
    }
    
    func connect() -> Void {
        interfaceController.delegate = self
        CPNowPlayingTemplate.shared.isAlbumArtistButtonEnabled = true
        CPNowPlayingTemplate.shared.add(self)
        self.setNowPlayingButtons()
        if let selectedSongObserver {
            NotificationCenter.default.removeObserver(selectedSongObserver)
        }
        selectedSongObserver = NotificationCenter.default.addObserver(
            forName: .audioHelperSelectedSongDidChange,
            object: AudioHelper.sharedController,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refreshNowPlayingForSelectedSong()
            }
        }
    }
    
    func disconnect() -> Void {
        if let selectedSongObserver {
            NotificationCenter.default.removeObserver(selectedSongObserver)
        }
        selectedSongObserver = nil
        AudioHelper.sharedController.pause()
    }

    private func refreshNowPlayingForSelectedSong() {
        CPNowPlayingTemplate.shared.isAlbumArtistButtonEnabled = true
        CPNowPlayingTemplate.shared.isUpNextButtonEnabled = AudioHelper.sharedController.selectedSetList != nil
        setNowPlayingButtons()
    }
}
