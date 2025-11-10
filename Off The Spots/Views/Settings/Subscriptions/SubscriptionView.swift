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
    
    @Binding var presentThanksSheet: Bool
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
        .onInAppPurchaseCompletion { (product: Product, result: Result<Product.PurchaseResult, Error>) in
            if case .success(.success(let transaction)) = result {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: { presentThanksSheet = true })
                dismiss()
            }
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
