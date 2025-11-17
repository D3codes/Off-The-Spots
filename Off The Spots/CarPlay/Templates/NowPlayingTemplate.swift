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
}
