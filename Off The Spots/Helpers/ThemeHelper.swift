//
//  ThemeHelper.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/25.
//

import SwiftUI

let backgroundGradient = LinearGradient(
    gradient: Gradient(
        colors: [
            .accentColor,
            Color(uiColor: UIColor.systemBackground),
            Color(uiColor: UIColor.systemBackground),
            Color(uiColor: UIColor.systemBackground),
            Color(uiColor: UIColor.systemBackground),
            Color(uiColor: UIColor.systemBackground)
        ]
    ),
    startPoint: .top,
    endPoint: .bottom
)

//let listItemBackground = Color(uiColor: UIColor.systemBackground).opacity(0.3)
let listItemBackground = Color(.systemGroupedBackground).opacity(0.5)
