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

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        self.templateManager = CarPlayTemplateManager(interfaceController: interfaceController)
        templateManager!.connect()

        Task { @MainActor in
            let rootTemplate: CPTemplate
            let isPro: Bool = await StoreHelper.hasActiveSubscription()

            let tabTemplates: [CPTemplate] = [
                self.templateManager!.songsListTemplate(isPro: isPro),
                self.templateManager!.setListsListTemplate(isPro: isPro)
            ]
            rootTemplate = CPTabBarTemplate(templates: tabTemplates)

            interfaceController.setRootTemplate(rootTemplate, animated: true) { success, error in
                // optional completion handler once CarPlay UI is displayed
            }
        }
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController, from window: CPWindow) {
        self.templateManager!.disconnect()
        self.interfaceController = nil
    }
}
