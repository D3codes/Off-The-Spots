//
//  AnimatedWaveformView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/31/25.
//

import SwiftUI

struct AnimatedWaveformView: View {
 
    var color: Color
    var animate: Bool
    
    @State private var drawingHeight = true
 
    var animation: Animation {
        return .linear(duration: 0.5).repeatForever()
    }
 
    var body: some View {
        Group {
            if animate {
                HStack {
                    bar(color: color, low: 0.4)
                        .animation(animation.speed(1.5), value: drawingHeight)
                    bar(color: color, low: 0.3)
                        .animation(animation.speed(1.2), value: drawingHeight)
                    bar(color: color, low: 0.5)
                        .animation(animation.speed(1.0), value: drawingHeight)
                    bar(color: color, low: 0.3)
                        .animation(animation.speed(1.7), value: drawingHeight)
                    bar(color: color, low: 0.5)
                        .animation(animation.speed(1.0), value: drawingHeight)
                }
            } else {
                HStack {
                    bar(color: color, low: 0.1, high: 0.1)
                    bar(color: color, low: 0.1, high: 0.1)
                    bar(color: color, low: 0.1, high: 0.1)
                    bar(color: color, low: 0.1, high: 0.1)
                    bar(color: color, low: 0.1, high: 0.1)
                }
            }
        }
        .frame(width: 60)
        .onAppear{
            drawingHeight.toggle()
        }
        .onChange(of: animate) {
            drawingHeight.toggle()
        }
    }
 
    func bar(color: Color, low: CGFloat = 0.0, high: CGFloat = 1.0) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color.gradient)
            .frame(height: (drawingHeight ? high : low) * 64)
            .frame(height: 64, alignment: .center)
    }
}

#Preview {
    @Previewable @State var animate: Bool = true
    
    VStack {
        AnimatedWaveformView(color: .accentColor, animate: animate)
        
        Button(action: { animate.toggle() }) { Text("Toggle Animation") }
            .buttonStyle(.glass)
    }
}
