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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.thinMaterial)
            
            VStack {
                Text("Panning")
                    .font(.subheadline)
                    .padding(.bottom)
                
                HStack {
                    Image(systemName: "wave.3.left", variableValue: panningValue <= 0 ? 1 : 1-(Double(panningValue)))
                        .scaleEffect(1.5)
                    
                    UISliderView(
                        value: $panningValue,
                        minValue: -1.0,
                        maxValue: 1.0,
                        minTrackColor: .lightGray,
                        maxTrackColor: .lightGray
                    )
                    .onChange(of: panningValue) { value,_ in
                        audioPlayer.pan = Float(value)
                    }
                    
                    Image(systemName: "wave.3.right", variableValue: panningValue >= 0 ? 1 : (Double(panningValue)).map(from: -1...0, to: 0...1))
                        .scaleEffect(1.5)
                }
                .frame(height: 40)
                .padding(.horizontal)
            }
            .padding()
        }
        .frame(maxHeight: 50)
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
