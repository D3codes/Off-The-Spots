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
    var templateManager: CarPlayTemplateManager?

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        
        self.interfaceController = interfaceController
        self.templateManager = CarPlayTemplateManager(interfaceController: interfaceController)
        templateManager!.connect()
        
        var tabTemplates: [CPTemplate] = []
        tabTemplates.append(templateManager!.songsListTemplate())
        tabTemplates.append(templateManager!.setListsListTemplate())

        let carPlayUI = CPTabBarTemplate(templates: tabTemplates)

        interfaceController.setRootTemplate(carPlayUI, animated: true) { success, error in
             // optional completion handler once CarPlay UI is displayed
        }
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnect interfaceController: CPInterfaceController,
                                  from window: CPWindow) {
        self.templateManager!.disconnect()
        self.interfaceController = nil
    }
}
