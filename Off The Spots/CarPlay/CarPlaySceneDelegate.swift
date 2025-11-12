//
//  CarPlaySceneDelegate.swift
//  Off The Spots
//
//  Created by David Freeman on 11/11/25.
//

import CarPlay
import UIKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        
        self.interfaceController = interfaceController
        
        var tabTemplates: [CPTemplate] = []
        tabTemplates.append(songsListTemplate())
        tabTemplates.append(setListsListTemplate())

        let carPlayUI = CPTabBarTemplate(templates: tabTemplates)

        interfaceController.setRootTemplate(carPlayUI, animated: true) { success, error in
//             optional completion handler once CarPlay UI is displayed
        }
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnect interfaceController: CPInterfaceController,
                                  from window: CPWindow) {
        self.interfaceController = nil
    }
}
