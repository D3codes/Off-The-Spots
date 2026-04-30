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
                description: "Store your entire repertoire"
            )
            
            SubscriptionBenefitItemView(
                image: Image(systemName: "music.note.square.stack.fill"),
                title: "Unlimited Tracks",
                description: "Attach all your learning media"
            )
            
            SubscriptionBenefitItemView(
                image: Image(systemName: "music.pages.fill"),
                title: "Sheet Music",
                description: "Follow along as you rehearse"
            )
            
            SubscriptionBenefitItemView(
                image: Image(systemName: "music.note.list"),
                title: "Set Lists",
                description: "Organize songs for practice & performance"
            )
            
            SubscriptionBenefitItemView(
                image: Image(systemName: "car.side.fill"),
                title: "CarPlay",
                description: "Control your music in the car"
            )
        }
    }
}

#Preview {
    NavigationStack {
        SubscriptionView(presentThanksSheet: .constant(false))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {}) { Image(systemName: "chevron.left") }
                }
            }
    }
}
