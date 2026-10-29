//
//  ThemeHelper.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/25.
//

import SwiftUI

struct ScreenBackground: View {
    var fadeHeight: CGFloat = 180

    var body: some View {
        Color(uiColor: .secondarySystemBackground)
            .overlay(alignment: .top) {
                LinearGradient(
                    stops: [
                        .init(color: .accentColor, location: 0),
                        .init(color: .accentColor.opacity(0.75), location: 0.30),
                        .init(color: .accentColor.opacity(0.25), location: 0.65),
                        .init(color: .accentColor.opacity(0.05), location: 0.85),
                        .init(color: .accentColor.opacity(0), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                // Keep the fade independent of list height and scrolling.
                .frame(height: fadeHeight)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

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

let secondaryBackground = LinearGradient(
    gradient: Gradient(
        colors: [
            Color(uiColor: UIColor.secondarySystemBackground)
        ]
    ),
    startPoint: .top,
    endPoint: .bottom
)

let listItemBackground = Color(.systemGroupedBackground).opacity(0)


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
