//
//  NowPlayingTemplate.swift
//  Off The Spots
//
//  Created by David Freeman on 11/17/25.
//

import CarPlay

@MainActor
extension CarPlayTemplateManager: @MainActor CPNowPlayingTemplateObserver {
    func nowPlayingTemplateUpNextButtonTapped(_ nowPlayingTemplate: CPNowPlayingTemplate) {
        if AudioHelper.sharedController.selectedSetList != nil {
            CPNowPlayingTemplate.shared.isUpNextButtonEnabled = true
            self.interfaceController.pushTemplate(self.upNextTemplate(setList: AudioHelper.sharedController.selectedSetList!), animated: true) { success, error in
                // optional completion handler once CarPlay UI is displayed
            }
        } else {
            CPNowPlayingTemplate.shared.isUpNextButtonEnabled = false
        }
    }
    
    func nowPlayingTemplateAlbumArtistButtonTapped(_ nowPlayingTemplate: CPNowPlayingTemplate) {
        Task { @MainActor in
            let isPro: Bool = await StoreHelper.hasActiveSubscription()
            
            self.interfaceController.pushTemplate(self.tracksListTemplate(song: AudioHelper.sharedController.selectedSong!, isPro: isPro), animated: true) { success, error in
                // optional completion handler once CarPlay UI is displayed
            }
        }
    }
    
    func setNowPlayingButtons() {
        let leftFillValue = AudioHelper.sharedController.panningValue <= 0 ? 1 : 1-AudioHelper.sharedController.panningValue
        let panLeftButton = CPNowPlayingImageButton(image: UIImage(systemName: "wave.3.left", variableValue: leftFillValue)!, handler: { _ in
            let currentPan = AudioHelper.sharedController.panningValue
            var newPan = currentPan - 0.33
            if newPan < -1 {
                newPan = -1
            }
            AudioHelper.sharedController.setPan(value: newPan)
            self.setNowPlayingButtons()
        })
        
        let rightFillValue = AudioHelper.sharedController.panningValue >= 0 ? 1 : AudioHelper.sharedController.panningValue.map(from: -1...0, to: 0...1)
        let panRightButton = CPNowPlayingImageButton(image: UIImage(systemName: "wave.3.right", variableValue: rightFillValue)!, handler: { _ in
            let currentPan = AudioHelper.sharedController.panningValue
            var newPan = currentPan + 0.33
            if newPan > 1 {
                newPan = 1
            }
            AudioHelper.sharedController.setPan(value: newPan)
            self.setNowPlayingButtons()
        })
        
        let decreaseRateButton = CPNowPlayingImageButton(image: UIImage(systemName: "tortoise.fill")!, handler: { _ in
            let currentRate = AudioHelper.sharedController.rateValue
            var newRate = currentRate - 0.1
            if newRate < 0.5 {
                newRate = 0.5
            }
            AudioHelper.sharedController.setRate(value: newRate)
        })
        
        let increaseRateButton = CPNowPlayingImageButton(image: UIImage(systemName: "hare.fill")!, handler: { _ in
            let currentRate = AudioHelper.sharedController.rateValue
            var newRate = currentRate + 0.1
            if newRate > 1.5 {
                newRate = 1.5
            }
            AudioHelper.sharedController.setRate(value: newRate)
        })
        
        let moreButton = CPNowPlayingMoreButton { [weak self] _ in
            self?.showNowPlayingOptions()
        }

        CPNowPlayingTemplate.shared.updateNowPlayingButtons([
            panLeftButton, panRightButton, decreaseRateButton, increaseRateButton, moreButton
        ])
    }

    private func showNowPlayingOptions() {
        guard interfaceController.presentedTemplate == nil else { return }

        func option(_ title: String, detail: String? = nil, symbol: String, action: @escaping () -> Void) -> CPListItem {
            let item = CPListItem(text: title, detailText: detail, image: UIImage(systemName: symbol))
            item.handler = { [weak self] _, completion in
                guard let self else {
                    completion()
                    return
                }
                action()
                self.interfaceController.popTemplate(animated: true) { _, error in
                    if let error {
                        NSLog("Could not return to CarPlay Now Playing: %@", error.localizedDescription)
                    }
                    completion()
                }
            }
            return item
        }

        let player = AudioHelper.sharedController
        let resetRate = option("Reset to 1×", symbol: "1.circle") {
            player.setRate(value: 1)
        }
        let centerPan = option("Center Pan", symbol: "waveform") {
            player.setPan(value: 0)
        }
        let repeatMode: String
        if player.repeatAll {
            repeatMode = "Set List"
        } else if player.repeatOne {
            repeatMode = "Song"
        } else {
            repeatMode = "Off"
        }
        let cycleRepeat = option("Repeat", detail: repeatMode, symbol: player.repeatOne ? "repeat.1" : "repeat") {
            player.incrementRepeat()
        }
        let options = CPListTemplate(
            title: "Playback",
            sections: [CPListSection(items: [resetRate, centerPan, cycleRepeat])]
        )
        interfaceController.pushTemplate(options, animated: true) { _, error in
            if let error {
                NSLog("Could not present CarPlay playback options: %@", error.localizedDescription)
            }
        }
    }
}
