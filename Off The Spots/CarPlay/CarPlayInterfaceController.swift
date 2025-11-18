//
//  CarPlayInterfaceController.swift
//  Off The Spots
//
//  Created by David Freeman on 11/17/25.
//

import CarPlay

extension CarPlayTemplateManager: CPInterfaceControllerDelegate {
    func templateWillAppear(_ aTemplate: CPTemplate, animated: Bool) {
//        print("Template \(aTemplate.classForCoder) will appear.")
        
        if aTemplate is CPNowPlayingTemplate {
            CPNowPlayingTemplate.shared.isAlbumArtistButtonEnabled = true
            CPNowPlayingTemplate.shared.isUpNextButtonEnabled = AudioHelper.sharedController.selectedSetList != nil
            self.setNowPlayingButtons()
        }
        
        if let list = aTemplate as? CPListTemplate {
            if aTemplate.tabTitle == "Songs" {
                list.updateSections(self.getSongsListSections())
            } else if aTemplate.tabTitle == "Set Lists" {
                list.updateSections(self.getSetListsListSections())
            }
        }
    }

    func templateDidAppear(_ aTemplate: CPTemplate, animated: Bool) {
//        print("Template \(aTemplate.classForCoder) did appear.")
        
        if aTemplate is CPNowPlayingTemplate {
            CPNowPlayingTemplate.shared.isAlbumArtistButtonEnabled = true
            CPNowPlayingTemplate.shared.isUpNextButtonEnabled = AudioHelper.sharedController.selectedSetList != nil
            self.setNowPlayingButtons()
        }
    }

    func templateWillDisappear(_ aTemplate: CPTemplate, animated: Bool) {
//        print("Template \(aTemplate.classForCoder) will disappear.")
    }

    func templateDidDisappear(_ aTemplate: CPTemplate, animated: Bool) {
//        print("Template \(aTemplate.classForCoder) did disappear.")
    }
}
