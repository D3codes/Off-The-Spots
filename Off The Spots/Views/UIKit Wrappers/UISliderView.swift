//
//  UISliderView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/5/24.
//

import UIKit
import SwiftUI

struct UISliderView: UIViewRepresentable {
    @Binding var value: Double
    var handleTouchDown: () -> Void = { }
    var handleTouchUp: () -> Void = { }
    
    var minValue: Double = 0.0
    var maxValue: Double = 100.0
    var thumbImage: UIImage?
    var thumbColor: Color = .white
    var minTrackColor: Color = .primary
    var maxTrackColor: Color = .secondary
    
    class Coordinator: NSObject {
        var value: Binding<Double>
        var handleTouchDown: () -> Void
        var handleTouchUp: () -> Void
        
        init(
            value: Binding<Double>,
            handleTouchDown: @escaping () -> Void,
            handleTouchUp: @escaping () -> Void
        ) {
            self.value = value
            self.handleTouchDown = handleTouchDown
            self.handleTouchUp = handleTouchUp
        }
        
        @MainActor @objc func valueChanged(_ sender: UISlider) {
            self.value.wrappedValue = Double(sender.value)
        }
        
        @objc func touchDown(_ sender: UISlider) {
            handleTouchDown()
        }
        
        @objc func touchUp(_ sender: UISlider) {
            handleTouchUp()
        }
    }
    
    func makeCoordinator() -> UISliderView.Coordinator {
        Coordinator(
            value: $value,
            handleTouchDown: handleTouchDown,
            handleTouchUp: handleTouchUp)
    }
    
    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider(frame: .zero)
        slider.thumbTintColor = UIColor(thumbColor)
        slider.minimumTrackTintColor = UIColor(minTrackColor)
        slider.maximumTrackTintColor = UIColor(maxTrackColor)
        slider.minimumValue = Float(minValue)
        slider.maximumValue = Float(maxValue)
        slider.value = Float(value)
        if let thumbImage {
            slider.setThumbImage(thumbImage, for: .normal)
            slider.setThumbImage(thumbImage, for: .highlighted)
        }
        
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.touchDown(_:)),
            for: .touchDown
        )
        
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.touchUp(_:)),
            for: .touchUpInside
        )
        
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.touchUp(_:)),
            for: .touchUpOutside
        )
        
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.touchUp(_:)),
            for: .touchCancel
        )
        
        return slider
    }
    
    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.value = Float(value)
    }
}
