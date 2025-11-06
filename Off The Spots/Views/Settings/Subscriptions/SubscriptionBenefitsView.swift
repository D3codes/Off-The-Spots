//
//  SubscriptionBenefitsView.swift
//  Off The Spots
//
//  Created by David Freeman on 11/5/25.
//

import SwiftUI

struct SubscriptionBenefitsView: View {
    
    var body: some View {
        VStack {
            SubscriptionBenefitItemView(
                image: Image(systemName: "music.note"),
                title: "Unlimited Songs",
                description: "Add all the songs you want"
            )
            
            SubscriptionBenefitItemView(
                image: Image(systemName: "music.note.square.stack.fill"),
                title: "Unlimited Tracks",
                description: "Add all the tracks you want"
            )
            
            SubscriptionBenefitItemView(
                image: Image(systemName: "music.pages.fill"),
                title: "Sheet Music",
                description: "Add sheet music to songs"
            )
            
            SubscriptionBenefitItemView(
                image: Image(systemName: "music.note.list"),
                title: "Set Lists",
                description: "Create set lists"
            )
            
            SubscriptionBenefitItemView(
                image: Image(systemName: "square"),
                title: "Custom Icons",
                description: "Custom app icons"
            )
        }
    }
}

#Preview {
    NavigationStack {
        SubscriptionView()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {}) { Image(systemName: "chevron.left") }
                }
            }
    }
}
