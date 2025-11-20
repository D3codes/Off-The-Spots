//
//  ThanksView.swift
//  Off The Spots
//
//  Created by David Freeman on 11/7/25.
//

import SwiftUI
import Vortex

struct ThanksView: View {
    @Environment(\.dismiss) private var dismiss
    
    func createSnow() -> VortexSystem {
        let system = VortexSystem(tags: ["note"])
        system.position = [0.5, 0]
        system.speed = 0.1
        system.speedVariation = 0.05
        system.lifespan = 20
        system.shape = .box(width: 1, height: 0)
        system.angle = .degrees(180)
        system.angleRange = .degrees(20)
        system.size = 1
        system.sizeVariation = 0.75
        system.birthRate = 1
        system.colors = VortexSystem.ColorMode.random([.red, .yellow, .green, .blue, .white, .black, .orange, .pink, .purple, .teal])
        return system
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VortexView(createSnow()) {
                    Image(systemName: "music.note")
                        .frame(width: 32)
                        .tag("note")
                }
                .foregroundStyle(.white)
                .ignoresSafeArea(edges: .all)
                
                VStack {
                    Text("Thank You!")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    Image("david")
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .scaledToFit()
                        .frame(maxWidth: 200, maxHeight: 200)
                    
                    VStack(spacing: 16) {
                        Text("Hi! 👋")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("My name is David and I’m the developer of Off The Spots. I hope you enjoy using the app!")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("This is a one-person project, so your subscription directly supports my ability to keep adding new features.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Thank you for your support and keep the whole world singing!")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                    .padding()
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundGradient)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .cancel, action: { dismiss() })
                }
            }
        }
    }
}

#Preview {
    struct ThanksView_Preview: View {
        @State private var isPresented: Bool = true
        
        var body: some View {
            Button(action: { isPresented = true }) { Text("Show Sheet") }
                .sheet(isPresented: $isPresented) {
                    ThanksView()
                }
        }
    }

    return ThanksView_Preview()
}
