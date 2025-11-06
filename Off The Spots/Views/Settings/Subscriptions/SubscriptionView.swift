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
    let otsProGroupId: String = "21825638"
    
    var body: some View {
        SubscriptionStoreView(groupID: otsProGroupId) {
            ScrollView {
                Group {
                    Image("icon")
                        .resizable()
                        .frame(width: 100, height: 100)
                    
                    Text("Off The Spots Pro")
                        .font(.title)
                }
                
                SubscriptionBenefitsView()
            }
            .containerBackground(for: .subscriptionStoreFullHeight) { backgroundGradient }
            .scrollIndicators(.hidden)
        }
        .backgroundStyle(.clear)
        .subscriptionStoreControlStyle(.compactPicker)
        .subscriptionStorePickerItemBackground(.thinMaterial)
        .storeButton(.hidden, for: .cancellation)
        .onInAppPurchaseCompletion { (product: Product, result: Result<Product.PurchaseResult, Error>) in
            if case .success(.success(let transaction)) = result {
//                    await BirdBrain.shared.process(transaction: transaction)
                print(transaction)
                dismiss()
            }
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
