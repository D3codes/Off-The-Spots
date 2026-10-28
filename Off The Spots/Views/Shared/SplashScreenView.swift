//
//  SplashScreenView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/29/24.
//

import SwiftUI

struct SplashScreenView: View {
    let targetFrame: CGRect?
    var placeholderText: String = ""
    
    var body: some View {
        ZStack {
            FlyingNotesView()
            
            VStack {
                VStack {
                    GeometryReader { proxy in
                        if let targetFrame {
                            // Both measurements use global coordinates because the
                            // toolbar and splash content have different containers.
                            let containerFrame = proxy.frame(in: .global)
                            let arrowCenter = CGPoint(
                                x: targetFrame.midX - containerFrame.minX,
                                y: targetFrame.maxY - containerFrame.minY + 8 + 22
                            )
                            
                            Image(systemName: "arrowshape.up.fill")
                                .font(.title)
                                .symbolEffect(
                                    .wiggle.byLayer,
                                    options: .speed(0.5).repeat(.continuous)
                                )
                                .frame(width: 44, height: 44)
                                .position(arrowCenter)
                        }
                    }
                    .frame(height: 44)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                    
                    Text(placeholderText)
                }
                .frame(maxWidth: .infinity, maxHeight: 100, alignment: .top)
                .padding(.horizontal, 16)
                
                Spacer()
                
                Image("spot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    @Previewable @State var addButtonFrame: CGRect?

    NavigationStack {
        SplashScreenView(targetFrame: addButtonFrame, placeholderText: "Add a Song to Get Started")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SplashScreenView(targetFrame: addButtonFrame), label: {Image(systemName: "gearshape") })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .accessibilityLabel("Add Song")
                    .onGeometryChange(for: CGRect.self) { proxy in
                        proxy.frame(in: .global)
                    } action: { frame in
                        addButtonFrame = frame.isEmpty ? nil : frame
                    }
                    .onDisappear {
                        addButtonFrame = nil
                    }
                }
            }
    }
}
