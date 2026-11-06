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

        func option(_ title: String, image: UIImage?, action: @escaping () -> Void) -> CPListItem {
            let item = CPListItem(text: title, detailText: nil, image: image)
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

        let carTraits = interfaceController.carTraitCollection
        let format = UIGraphicsImageRendererFormat()
        format.scale = max(carTraits.displayScale, 1)

        let rateGlyph: NSString = "1×"
        let rateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor.label.resolvedColor(with: carTraits)
        ]
        let rateIconSize = CGSize(width: 24, height: 24)
        let glyphSize = rateGlyph.size(withAttributes: rateAttributes)
        let rateIcon = UIGraphicsImageRenderer(size: rateIconSize, format: format).image { _ in
            rateGlyph.draw(at: CGPoint(
                x: (rateIconSize.width - glyphSize.width) / 2,
                y: (rateIconSize.height - glyphSize.height) / 2
            ), withAttributes: rateAttributes)
        }.withRenderingMode(.alwaysOriginal)

        let player = AudioHelper.sharedController
        let resetRate = option("Reset Playback Speed", image: rateIcon) {
            player.setRate(value: 1)
        }
        let centerPan = option("Center Pan", image: UIImage(systemName: "waveform")) {
            player.setPan(value: 0)
        }

        let repeatTint = UIColor.accent.resolvedColor(with: carTraits)

        func tintedRepeatIcon(_ symbol: String) -> UIImage? {
            guard let icon = UIImage(systemName: symbol)?.withTintColor(repeatTint, renderingMode: .alwaysOriginal) else {
                return nil
            }
            return UIGraphicsImageRenderer(size: icon.size, format: format).image { _ in
                icon.draw(at: .zero)
            }.withRenderingMode(.alwaysOriginal)
        }

        let repeatSetListIcon = tintedRepeatIcon("repeat")
        let repeatSongIcon = tintedRepeatIcon("repeat.1")
        let repeatOffIcon = UIImage(systemName: "repeat")

        func refreshOptions(_ options: CPListTemplate) {
            let mode: String
            let icon: UIImage?
            if player.repeatAll {
                mode = "Set List"
                icon = repeatSetListIcon
            } else if player.repeatOne {
                mode = "Song"
                icon = repeatSongIcon
            } else {
                mode = "Off"
                icon = repeatOffIcon
            }

            let cycleRepeat = CPListItem(text: "Repeat", detailText: mode, image: icon)
            cycleRepeat.handler = { [weak options] _, completion in
                player.incrementRepeat()
                // Finish the selection before replacing the selected row.
                completion()
                if let options {
                    refreshOptions(options)
                }
            }
            options.updateSections([CPListSection(items: [resetRate, centerPan, cycleRepeat])])
        }

        let options = CPListTemplate(title: "Playback", sections: [CPListSection(items: [resetRate, centerPan])])
        refreshOptions(options)
        interfaceController.pushTemplate(options, animated: true) { _, error in
            if let error {
                NSLog("Could not present CarPlay playback options: %@", error.localizedDescription)
            }
        }
    }
}
