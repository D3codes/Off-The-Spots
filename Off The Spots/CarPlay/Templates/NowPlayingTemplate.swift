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
    
    func setNowPlayingButtons() -> Void {
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
        
//        let tracksButton = CPNowPlayingImageButton(image: UIImage(systemName: "music.note.square.stack.fill")!, handler: { _ in print("Tacks") })
        
        let decreaseRateButton = CPNowPlayingImageButton(image: UIImage(systemName: "tortoise.fill")!, handler: { _ in
            let currentRate = AudioHelper.sharedController.rateValue
            var newRate = currentRate - 0.1
            if newRate < 0.5 {
                newRate = 0.5
            }
            AudioHelper.sharedController.setRate(value: newRate)
        })
        
        let rate = CPNowPlayingPlaybackRateButton() { _ in
            
        }
        
        let increaseRateButton = CPNowPlayingImageButton(image: UIImage(systemName: "hare.fill")!, handler: { _ in
            let currentRate = AudioHelper.sharedController.rateValue
            var newRate = currentRate + 0.1
            if newRate > 1.5 {
                newRate = 1.5
            }
            AudioHelper.sharedController.setRate(value: newRate)
        })
        
        CPNowPlayingTemplate.shared.updateNowPlayingButtons([panLeftButton, panRightButton, decreaseRateButton, rate, increaseRateButton])
    }
}
