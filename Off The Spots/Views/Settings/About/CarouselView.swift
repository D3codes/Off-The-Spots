//
//  CarouselView.swift
//  Off The Spots
//
//  Created by David Freeman on 11/10/25.
//

import SwiftUI

struct CarouselView: View {
    var images: [Image] = [Image("n4n"), Image("david"), Image("dad"), Image("brovertones")]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(0..<images.count, id: \.self) { index in
                    images[index]
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5, x: 5, y: 5)
//                        .containerRelativeFrame(.horizontal)
                        .frame(maxWidth: 300)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.5) // Apply opacity animation
                                .scaleEffect(y: phase.isIdentity ? 1 : 0.7) // Apply scale animation
                        }
                    
                }
            }
            .scrollTargetLayout() // Align content to the view
        }
        .contentMargins(.horizontal, 50, for: .scrollContent) // Add padding
        .scrollTargetBehavior(.viewAligned) // Align content behavior
        .scrollIndicators(.hidden)
    }
}

#Preview {
    CarouselView()
        .frame(maxHeight: 500)
}
