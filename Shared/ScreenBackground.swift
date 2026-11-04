//
//  ScreenBackground.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/26.
//


import SwiftUI

struct ScreenBackground: View {
    var fadeHeight: CGFloat = 180

    // Widget hosts can supply their own accent tint. Resolve the app's named
    // color directly so this background keeps the same blue in both targets.
    private let backgroundBlue = Color("AccentColor")

    var body: some View {
        Color(uiColor: .secondarySystemBackground)
            .overlay(alignment: .top) {
                LinearGradient(
                    stops: [
                        .init(color: backgroundBlue, location: 0),
                        .init(color: backgroundBlue.opacity(0.75), location: 0.30),
                        .init(color: backgroundBlue.opacity(0.25), location: 0.65),
                        .init(color: backgroundBlue.opacity(0.05), location: 0.85),
                        .init(color: backgroundBlue.opacity(0), location: 1)
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
