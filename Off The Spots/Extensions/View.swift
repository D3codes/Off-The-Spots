//
//  View.swift
//  Off The Spots
//
//  Created by David Freeman on 11/7/25.
//

import SwiftUI

extension View {
    /// Shakes when the trigger becomes true and resets it after the animation.
    func shake(trigger: Binding<Bool>) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }

    public func gradientForeground(colors: [Color]) -> some View {
        self.overlay(
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
        )
            .mask(self)
    }
    
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

private struct ShakeModifier: ViewModifier {
    @Binding var trigger: Bool
    @State private var animationTrigger = false

    func body(content: Content) -> some View {
        content.keyframeAnimator(initialValue: CGFloat.zero, trigger: animationTrigger) { view, offset in
            view.offset(x: offset)
        } keyframes: { _ in
            shakeKeyframes
        }
        .task(id: trigger) {
            guard trigger else { return }

            animationTrigger.toggle()
            let timeline = KeyframeTimeline(initialValue: CGFloat.zero) { shakeKeyframes }
            do {
                try await Task.sleep(for: .seconds(timeline.duration))
                try Task.checkCancellation()
            } catch {
                return
            }
            trigger = false
        }
    }

    @KeyframesBuilder<CGFloat> private var shakeKeyframes: some Keyframes<CGFloat> {
        LinearKeyframe(-7, duration: 0.06)
        LinearKeyframe(7, duration: 0.08)
        LinearKeyframe(-4, duration: 0.07)
        LinearKeyframe(4, duration: 0.06)
        LinearKeyframe(0, duration: 0.05)
    }
}
