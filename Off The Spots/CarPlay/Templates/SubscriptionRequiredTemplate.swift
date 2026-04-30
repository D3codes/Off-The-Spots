//
//  SubscriptionRequiredTemplate.swift
//  Off The Spots
//
//  Created by Codex on 11/24/25.
//

import CarPlay
import UIKit

extension CarPlayTemplateManager {
    @MainActor
    func subscriptionRequiredTemplate() -> CPListTemplate {
        let iconImage = UIImage(named: "icon")

        var messageItems: [any CPListTemplateItem] = []

        if let iconImage {
            let iconElement = CPListImageRowItemGridElement(image: iconImage)
            let iconRow = CPListImageRowItem(
                text: nil,
                gridElements: [iconElement],
                allowsMultipleLines: false
            )
            messageItems.append(iconRow)
        }

        let titleItem = CPListItem(
            text: "Off The Spots Pro Required",
            detailText: "Subscribe to Pro to unlock CarPlay features."
        )
        messageItems.append(titleItem)

        let section = CPListSection(
            items: messageItems,
            header: "",
            headerSubtitle: nil,
            headerImage: nil,
            headerButton: nil,
            sectionIndexTitle: nil
        )

        return CPListTemplate(title: "Off The Spots Pro", sections: [section])
    }
}
