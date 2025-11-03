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
            Color(uiColor: UIColor.secondarySystemBackground),
            Color(uiColor: UIColor.secondarySystemBackground),
            Color(uiColor: UIColor.secondarySystemBackground),
            Color(uiColor: UIColor.secondarySystemBackground),
            Color(uiColor: UIColor.secondarySystemBackground),
            Color(uiColor: UIColor.secondarySystemBackground)
        ]
    ),
    startPoint: .top,
    endPoint: .bottom
)

let listItemBackground = Color(.systemGroupedBackground).opacity(0.4)


#Preview {
    NavigationStack {
        List {
            Text("Test")
                .listRowBackground(listItemBackground)
            Text("Test")
                .listRowBackground(listItemBackground)
            Text("Test")
                .listRowBackground(listItemBackground)
            Text("Test")
                .listRowBackground(listItemBackground)
            Text("Test")
                .listRowBackground(listItemBackground)
            Text("Test")
                .listRowBackground(listItemBackground)
        }
        .scrollContentBackground(.hidden)
        .background(backgroundGradient)
        .navigationTitle(Text("TEST"))
    }
}
