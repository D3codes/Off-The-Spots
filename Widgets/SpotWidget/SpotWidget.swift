//
//  SpotEntry.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/26.
//


import SwiftUI
import WidgetKit

struct SpotEntry: TimelineEntry {
    let date: Date
    let appearance: SpotAppearance

    static let preview = SpotEntry(
        date: .now,
        appearance: SpotAppearance(pose: .standard, quote: SpotContent.spotPhrases[0])
    )
}

struct SpotProvider: TimelineProvider {
    func placeholder(in context: Context) -> SpotEntry { .preview }

    func getSnapshot(in context: Context, completion: @escaping (SpotEntry) -> Void) {
        completion(context.isPreview ? .preview : SpotEntry(date: .now, appearance: SpotContent.random()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SpotEntry>) -> Void) {
        let now = Date()
        let hour: TimeInterval = 3600
        // Keep the number of image views WidgetKit archives per timeline small.
        let entryCount = 4
        var previousPose: SpotPose?
        let entries = (0..<entryCount).map { offset in
            let appearance = SpotContent.random(excluding: previousPose)
            previousPose = appearance.pose
            return SpotEntry(date: now.addingTimeInterval(Double(offset) * hour), appearance: appearance)
        }
        completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(Double(entryCount) * hour))))
    }
}

struct SpotWidgetView: View {
    let entry: SpotEntry

    var body: some View {
        VStack(spacing: 4) {
            Image(entry.appearance.pose.rawValue)
                .resizable()
                .widgetAccentedRenderingMode(.fullColor)
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(true)

            Text(entry.appearance.quote)
                .font(.custom(SpotContent.quoteFontName, size: 14, relativeTo: .caption))
                .multilineTextAlignment(.center)
                .lineLimit(5)
                .minimumScaleFactor(0.8)
                .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Spot says: \(entry.appearance.quote)")
        .widgetURL(SongWidgetLink.libraryURL)
        .containerBackground(for: .widget) {
            ScreenBackground()
        }
    }
}

struct SpotWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "OffTheSpotsSpot", provider: SpotProvider()) { entry in
            SpotWidgetView(entry: entry)
        }
        .configurationDisplayName("Spot")
        .description("A little encouragement from your rehearsal companion.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    SpotWidget()
} timeline: {
    SpotEntry.preview
    SpotEntry(date: .now.addingTimeInterval(600), appearance: SpotAppearance(
        pose: .escapingNotes, quote: SpotContent.spotPhrases[1]
    ))
    SpotEntry(date: .now.addingTimeInterval(1200), appearance: SpotAppearance(
        pose: .fetchASong, quote: SpotContent.spotPhrases[2]
    ))
    SpotEntry(date: .now.addingTimeInterval(1800), appearance: SpotAppearance(
        pose: .pointing, quote: SpotContent.spotPhrases[3]
    ))
    SpotEntry(date: .now.addingTimeInterval(2400), appearance: SpotAppearance(
        pose: .tinyRehearsalStage, quote: SpotContent.spotPhrases[4]
    ))
    SpotEntry(date: .now.addingTimeInterval(3000), appearance: SpotAppearance(
        pose: .waitingForRehearsal, quote: SpotContent.spotPhrases[5]
    ))
    SpotEntry(date: .now.addingTimeInterval(3600), appearance: SpotAppearance(
        pose: .practicingTheRests, quote: SpotContent.sleepingPhrases[2]
    ))
    SpotEntry(date: .now.addingTimeInterval(7200), appearance: SpotAppearance(
        pose: .barbershop, quote: SpotContent.barbershopPhrases[1]
    ))
    SpotEntry(date: .now.addingTimeInterval(10800), appearance: SpotAppearance(
        pose: .standard, quote: SpotContent.spotPhrases[1]
    ))
}
