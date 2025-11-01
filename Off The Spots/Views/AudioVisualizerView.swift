//
//  AudioVisualizerView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/31/25.
//

import SwiftUI

struct AudioVizualizerView: View {
 
    var color: Color
    
    @State private var drawingHeight = true
 
    var animation: Animation {
        return .linear(duration: 0.5).repeatForever()
    }
 
    var body: some View {
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
        .frame(width: 60)
        .onAppear{
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
    AudioVizualizerView(color: .accentColor)
}
