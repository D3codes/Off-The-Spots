//
//  FlyingNotesView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/28/26.
//

import SwiftUI
import Vortex

struct FlyingNotesView: View {
    
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
        VortexView(createSnow()) {
            Image(systemName: "music.note")
                .frame(width: 32)
                .tag("note")
        }
        .foregroundStyle(.white)
        .ignoresSafeArea(edges: .all)
    }
}

#Preview {
    FlyingNotesView()
}
