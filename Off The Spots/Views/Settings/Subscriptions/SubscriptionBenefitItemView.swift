//
//  SubscriptionBenefitItemView.swift
//  Off The Spots
//
//  Created by David Freeman on 11/5/25.
//

import SwiftUI

struct SubscriptionBenefitItemView: View {
    let image: Image
    let title: String
    let description: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.secondary.opacity(0.1))
            
            HStack {
                image
                    .foregroundStyle(.accent)
                    .font(.title)
                    .padding(.horizontal)
                
                VStack {
                    Text(title)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(description)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
        }
        .frame(maxWidth: 500)
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
