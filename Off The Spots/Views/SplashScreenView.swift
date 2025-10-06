//
//  SplashScreenView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/29/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var noteOffsets = [
        Double.random(in: 200...300),
        Double.random(in: 200...300),
        Double.random(in: 200...300),
        Double.random(in: 200...300),
        Double.random(in: 200...300),
        Double.random(in: 200...300),
        Double.random(in: 200...300),
        Double.random(in: 200...300),
        Double.random(in: 200...300),
        Double.random(in: 200...300)
    ]

    //used to start floating notes animation
    @State private var appeared = false
    func flipOffsets() {
        if appeared {
            return
        }
        
        for i in 0...9 {
            noteOffsets[i] = -noteOffsets[i]
        }
        
        appeared = true
    }
    
    func getRandomColor() -> Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: 1
        )
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .trailing) {
                 Image(systemName: "arrowshape.up.fill")
                     .font(.title)
                     .symbolEffect(.wiggle.byLayer, options: .speed(0.5).repeat(.continuous))
                 Text("Add a song to get started")
             }
             .frame(maxWidth: .infinity, maxHeight: 100, alignment: .topTrailing)
             .padding(.trailing, 21)
            
            Spacer()
            
            ZStack {
                VStack {
                    ForEach(0..<10) { i in
                        Image(systemName: "music.note")
                            .font(.title)
                            .foregroundStyle(getRandomColor())
                            .scaleEffect(Double.random(in: 0.4...1.5))
                            .offset(x: noteOffsets[i])
                            .animation(
                                .linear(duration: Double.random(in: 5...10))
                                .repeatForever(autoreverses: false),
                                value: noteOffsets[i]
                            )
                    }
                }
                
                Image("spot")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .frame(width: 350, height: 350)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .glassEffect(in: .rect(cornerRadius: 16.0))
            .padding(.bottom, 50)
        }
        .ignoresSafeArea(.keyboard)
        .task { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { flipOffsets() } }
    }
}

#Preview {
    SplashScreenView()
}
