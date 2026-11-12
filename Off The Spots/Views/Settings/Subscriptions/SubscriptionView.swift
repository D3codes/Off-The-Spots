//
//  SubscriptionView.swift
//  Off The Spots
//
//  Created by David Freeman on 11/5/25.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.otsProGroupId) var otsProGroupId
    
    @State private var hasVerifiedPro = false
    @State private var awaitingProActivation = false
    @State private var presentThanksSheet = false

    var inSheet: Bool = false
    
    var body: some View {
        SubscriptionStoreView(groupID: otsProGroupId) {
            ScrollView {
                Group {
                    Image("icon")
                        .resizable()
                        .frame(width: 80, height: 80)
                    
                    HStack(spacing: 0) {
                        Text("Off The Spots ")
                            .font(.title)
                        Text("Pro")
                            .font(.title)
                            .bold()
                            .gradientForeground(colors: [.teal, Color.otsBlue])
                    }
                    
                    Text("Advanced tools to master your music")
                        .font(.footnote)
                }
                
                SubscriptionBenefitsView()
                
                Text("Everything you need to stay in tune 🎵")
            }
            .containerBackground(for: .subscriptionStoreFullHeight) { backgroundGradient }
            .scrollIndicators(.hidden)
            .padding(.top, inSheet ? 16 : 0)
        }
        .backgroundStyle(.clear)
        .subscriptionStoreControlStyle(.compactPicker, placement: .bottomBar)
        .subscriptionStorePickerItemBackground(.thinMaterial)
        .storeButton(.hidden, for: .cancellation)
        .onInAppPurchaseStart { _ in
            awaitingProActivation = !hasVerifiedPro
        }
        .subscriptionStatusTask(for: otsProGroupId) { taskState in
            guard case .success(let statuses) = taskState else { return }
            hasVerifiedPro = StoreHelper.checkForActiveSubscription(in: statuses)
            if awaitingProActivation && hasVerifiedPro {
                awaitingProActivation = false
                presentThanksSheet = true
            }
        }
        .sheet(isPresented: $presentThanksSheet, onDismiss: { dismiss() }) { ThanksView() }
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
