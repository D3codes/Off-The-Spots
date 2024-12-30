//
//  PanningView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/4/24.
//

import SwiftUI
import AVFoundation

struct PanningView: View {
    @ObservedObject var player: AudioHelper
    
    @Binding var panningValue: Double
    @State var vibrated: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.thinMaterial)
            
            VStack {
                Text("Panning")
                    .font(.subheadline)
                    .padding(.bottom)
                
                HStack {
                    Image(systemName: "wave.3.left", variableValue: panningValue <= 0 ? 1 : 1-panningValue)
                        .scaleEffect(1.5)
                    
                    UISliderView(
                        value: $panningValue,
                        handleTouchUp: handleTouchUp,
                        minValue: -1.0,
                        maxValue: 1.0,
                        thumbColor: .white,
                        minTrackColor: .secondary,
                        maxTrackColor: .secondary
                    )
                    .onChange(of: panningValue) { value,_ in
                        panningValue = value
                        
                        if (value > -0.1 && value < 0.1) {
                            if (!vibrated) {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                vibrated = true
                            }
                            panningValue = 0
                        } else {
                            vibrated = false
                        }
                        
                        player.setPan(value: panningValue)
                    }
                    
                    Image(systemName: "wave.3.right", variableValue: panningValue >= 0 ? 1 : panningValue.map(from: -1...0, to: 0...1))
                        .scaleEffect(1.5)
                }
                .frame(height: 40)
                .padding(.horizontal)
            }
            .padding()
        }
        .frame(maxHeight: 50)
    }
    
    func handleTouchUp() {
        vibrated = false
        player.setPan(value: panningValue)
    }
}

#Preview {
    struct PanningView_Preview: View {
        @StateObject var player: AudioHelper = AudioHelper()
        
        var body: some View {
            PanningView(player: player, panningValue: $player.panningValue)
        }
    }
    
    return PanningView_Preview()
}
