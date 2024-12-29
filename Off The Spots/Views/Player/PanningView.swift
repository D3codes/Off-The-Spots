//
//  PanningView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/4/24.
//

import SwiftUI
import AVFoundation

struct PanningView: View {
    @Binding var audioPlayer: AVAudioPlayer
    @State var panningValue: Double
    @State var isPanning: Bool = false
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
                        handleTouchDown: handleTouchDown,
                        handleTouchUp: handleTouchUp,
                        minValue: -1.0,
                        maxValue: 1.0,
                        thumbColor: UIColor(.white),
                        minTrackColor: UIColor(.secondary),
                        maxTrackColor: UIColor(.secondary)
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
                        
                        audioPlayer.pan = Float(panningValue)
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
    
    func handleTouchDown() {
        isPanning = true
    }
    
    func handleTouchUp() {
        isPanning = false
        audioPlayer.pan = Float(panningValue)
    }
}

#Preview {
    struct PanningView_Preview: View {
        @State var audioPlayer: AVAudioPlayer = AVAudioPlayer()
        
        var body: some View {
            PanningView(audioPlayer: $audioPlayer, panningValue: Double(audioPlayer.pan))
        }
    }
    
    return PanningView_Preview()
}
