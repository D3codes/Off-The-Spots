//
//  PlaybackProgressView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/5/24.
//

import SwiftUI
import AVFoundation

struct PlaybackProgressView: View {
    @ObservedObject var player: AudioHelper
    @Binding var isEditingProgress: Bool

    @GestureState private var isTouchingTimeline = false
    @State private var drag: TimelineDrag?

    private enum Target {
        case start, playhead, end
    }

    private struct TimelineDrag {
        let target: Target
        let anchor: Double
        var time: Double
    }

    private let rowHeight: CGFloat = 44
    private var inset: CGFloat { rowHeight / 2 }
    private var duration: Double { player.duration }
    private var start: Double? { drag?.target == .start ? drag?.time : player.loopStart }
    private var end: Double? { drag?.target == .end ? drag?.time : player.loopEnd }
    private var playhead: Double {
        drag?.target == .playhead ? drag?.time ?? 0 : player.playbackProgress.value
    }

    private var playheadY: CGFloat { rowHeight + inset }
    private var timelineHeight: CGFloat { rowHeight * 3 }

    var body: some View {
        VStack(spacing: -6) {
            Color.clear
                .frame(height: rowHeight)
                .overlay {
                    GeometryReader { geometry in
                        let width = max(1, geometry.size.width - 2 * inset)
                        ZStack {
                            timeline(width: width)
                                .allowsHitTesting(false)
                            Color.clear
                                .contentShape(timelineHitRegion(width: width))
                                .gesture(timelineGesture(width: width), isEnabled: duration > 0)
                                .allowsHitTesting(duration > 0)
                                .accessibilityHidden(true)
                        }
                        .frame(width: geometry.size.width, height: timelineHeight)
                    }
                    .frame(height: timelineHeight)
                }
                .zIndex(2)

            HStack {
                Text(clockTime(playhead))
                Spacer()
                Text("-\(clockTime(duration - playhead))")
            }
            .monospacedDigit()
            .accessibilityHidden(true)
            .zIndex(1)
        }
        .onChange(of: isTouchingTimeline) { _, isTouching in
            // Gesture state resets on cancellation as well as on a normal lift.
            if !isTouching {
                cancelDrag()
            }
        }
        .onDisappear(perform: cancelDrag)
    }

    private func timelineHitRegion(width: CGFloat) -> Path {
        // Empty space in the overhang belongs to the surrounding player controls.
        var path = Path(CGRect(x: 0, y: rowHeight, width: width + 2 * inset, height: rowHeight))
        if let start {
            path.addRect(CGRect(x: xPosition(for: start, width: width) - inset, y: 0, width: rowHeight, height: rowHeight))
        }
        if let end {
            path.addRect(CGRect(x: xPosition(for: end, width: width) - inset, y: 2 * rowHeight, width: rowHeight, height: rowHeight))
        }
        return path
    }

    private func timeline(width: CGFloat) -> some View {
        let progressWidth = xPosition(for: playhead, width: width) - inset
        return ZStack(alignment: .topLeading) {
            Capsule()
                .fill(.secondary.opacity(0.3))
                .frame(width: width, height: 4)
                .position(x: inset + width / 2, y: playheadY)

            Capsule()
                .fill(.primary.opacity(0.65))
                .frame(width: progressWidth, height: 4)
                .position(x: inset + progressWidth / 2, y: playheadY)

            if let start, let end {
                let startX = xPosition(for: start, width: width)
                let endX = xPosition(for: end, width: width)
                Capsule()
                    .fill(Color.accentColor.opacity(player.isLooping ? 1 : 0.5))
                    .frame(width: max(0, endX - startX), height: 4)
                    .position(x: (startX + endX) / 2, y: playheadY)
            }

            if let start {
                marker(systemName: "chevron.right.to.line", target: .start, time: start, y: playheadY - rowHeight, width: width)
            }
            if let end {
                marker(systemName: "chevron.left.to.line", target: .end, time: end, y: playheadY + rowHeight, width: width)
            }

            adjustable(
                Circle()
                    .frame(width: 14, height: 14)
                    .glassEffect(drag?.target == .playhead ? .clear : .regular),
                label: "Playback Position",
                target: .playhead,
                time: playhead
            )
            .accessibilityHidden(duration <= 0)
            .position(x: xPosition(for: playhead, width: width), y: playheadY)
        }
    }

    private func marker(systemName: String, target: Target, time: Double, y: CGFloat, width: CGFloat) -> some View {
        let x = xPosition(for: time, width: width)
        let isActive = drag?.target == target
        return ZStack {
            Rectangle()
                .fill(Color.accentColor)
                .frame(width: 2, height: rowHeight)
                .position(x: x, y: (y + playheadY) / 2)

            adjustable(
                Image(systemName: systemName)
                    .font(.subheadline)
                    .foregroundStyle(isActive ? Color.white : Color.primary)
                    .padding(8)
                    .background(isActive ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.regularMaterial), in: Circle()),
                label: target == .start ? "Loop Start" : "Loop End",
                target: target,
                time: time
            )
            .position(x: x, y: y)
        }
    }

    private func timelineGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($isTouchingTimeline) { _, isTouching, _ in isTouching = true }
            .onChanged { value in
                if drag == nil {
                    guard let target = target(at: value.startLocation, width: width) else { return }
                    let touchTime = time(at: value.startLocation.x, width: width)
                    let isOnPlayhead = abs(value.startLocation.x - xPosition(for: playhead, width: width)) <= inset
                    let anchor: Double
                    switch target {
                    case .start: anchor = start ?? 0
                    case .playhead: anchor = isOnPlayhead ? playhead : touchTime
                    case .end: anchor = end ?? duration
                    }
                    drag = TimelineDrag(target: target, anchor: anchor, time: anchor)
                    if target == .playhead {
                        isEditingProgress = true
                    }
                }
                if let drag {
                    self.drag?.time = clampedTime(drag.anchor + value.translation.width / width * duration, for: drag.target)
                }
            }
            .onEnded { value in
                guard let drag else { return }
                let time = drag.anchor + value.translation.width / width * duration
                commit(time, for: drag.target)
                cancelDrag()
            }
    }

    private func target(at point: CGPoint, width: CGFloat) -> Target? {
        // Select by the initial touch row, then keep that target for the whole drag.
        guard (0..<timelineHeight).contains(point.y) else { return nil }
        if point.y < playheadY - inset {
            guard let start, abs(point.x - xPosition(for: start, width: width)) <= inset else { return nil }
            return .start
        }
        if point.y >= playheadY + inset {
            guard let end, abs(point.x - xPosition(for: end, width: width)) <= inset else { return nil }
            return .end
        }
        return .playhead
    }

    private func xPosition(for time: Double, width: CGFloat) -> CGFloat {
        inset + (duration > 0 ? min(max(time / duration, 0), 1) * width : 0)
    }

    private func time(at x: CGFloat, width: CGFloat) -> Double {
        min(max((x - inset) / width, 0), 1) * duration
    }

    private func clampedTime(_ time: Double, for target: Target) -> Double {
        let time = min(max(time, 0), duration)
        let frameDuration = 1 / max(player.audioSampleRate, 1)
        switch target {
        case .start:
            return min(time, max(0, (player.loopEnd ?? duration) - frameDuration))
        case .playhead:
            return time
        case .end:
            return max(time, min(duration, (player.loopStart ?? 0) + frameDuration))
        }
    }

    private func commit(_ time: Double, for target: Target) {
        let time = clampedTime(time, for: target)
        switch target {
        case .start:
            _ = player.setLoopStart(value: time)
        case .playhead:
            player.playbackProgress.value = time
            player.setCurrentTime(value: AVAudioFramePosition(time * player.audioSampleRate))
        case .end:
            _ = player.setLoopEnd(value: time)
        }
    }

    private func cancelDrag() {
        if drag?.target == .playhead {
            isEditingProgress = false
        }
        drag = nil
    }

    private func adjustable(_ content: some View, label: LocalizedStringKey, target: Target, time: Double) -> some View {
        content
            .frame(minWidth: rowHeight, minHeight: rowHeight)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityValue(clockTime(time, showTenths: target != .playhead))
            .accessibilityAdjustableAction { direction in
                let step = target == .playhead ? 1.0 : 0.1
                switch direction {
                case .increment: commit(time + step, for: target)
                case .decrement: commit(time - step, for: target)
                @unknown default: break
                }
            }
    }

    private func clockTime(_ time: Double, showTenths: Bool = false) -> String {
        let tenths = Int((max(0, time) * 10).rounded())
        if showTenths {
            return String(format: "%d:%02d.%d", tenths / 600, tenths / 10 % 60, tenths % 10)
        }
        let seconds = Int(max(0, time).rounded())
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview {
    @Previewable @StateObject var player = AudioHelper()
    @Previewable @State var isEditingProgress = false

    PlaybackProgressView(player: player, isEditingProgress: $isEditingProgress)
        .padding()
        .onAppear {
            player.duration = 120
            player.audioSampleRate = 44_100
            player.loopStart = 59.9
            player.playbackProgress.value = 60
            player.loopEnd = 60.1
        }
}
