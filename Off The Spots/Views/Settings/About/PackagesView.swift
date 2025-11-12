//
//  PackagesView.swift
//  Off The Spots
//
//  Created by David Freeman on 11/11/25.
//

import SwiftUI

struct PackageItemView: View {
    var name: String
    var creator: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text(name)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("by \(creator)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PackagesView: View {
    
    var body: some View {
        VStack() {
            Text("Packages")
                .font(.headline)
                .padding(.bottom, 2)
            
            PackageItemView(name: "MarqueeText", creator: "Joe Kennedy")
            PackageItemView(name: "Vortex", creator: "Paul Hudson")
            
            Spacer()
        }
        .padding()
        .glassEffect(in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    AboutView()
}
