import SwiftUI
import WidgetKit

struct SongsEntry: TimelineEntry {
    let date: Date
    let songs: [SongWidgetRecord]
    let mediumPage: Int
    let largePage: Int
    let portraitPage: Int

    static let preview = SongsEntry(
        date: .now,
        songs: [
            "My Wild Irish Rose",
            "Wait Till The Sun Shines, Nellie",
            "Sweet And Lovely",
            "Down Our Way",
            "Honey - Little 'Lize Medley",
            "Let Me Call You Sweetheart",
            "Sweet, Sweet Roses Of Morn",
            "Shine On Me",
            "The Story of the Rose",
            "You're the Flower of My Heart, Sweet Adeline",
            "Down By The Old Mill Stream",
            "You Tell Me Your Dream"
        ].map {
            SongWidgetRecord(id: UUID(), name: $0)
        },
        mediumPage: 0, largePage: 0, portraitPage: 0
    )
}

struct SongsProvider: TimelineProvider {
    func placeholder(in context: Context) -> SongsEntry { .preview }

    func getSnapshot(in context: Context, completion: @escaping (SongsEntry) -> Void) {
        completion(context.isPreview ? .preview : entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SongsEntry>) -> Void) {
        completion(Timeline(entries: [entry()], policy: .after(.now.addingTimeInterval(900))))
    }

    private func entry() -> SongsEntry {
        let store = SongWidgetStore()
        return SongsEntry(date: .now, songs: store.loadSongs(),
                          mediumPage: store.pageIndex(pageSize: 3),
                          largePage: store.pageIndex(pageSize: 7),
                          portraitPage: store.pageIndex(pageSize: 10))
    }
}

struct SongsWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SongsEntry

    private var pageSize: Int {
        if #available(iOS 27.0, *), family == .systemExtraLargePortrait { return 10 }
        return family == .systemMedium ? 3 : 7
    }
    private var pageIndex: Int {
        if #available(iOS 27.0, *), family == .systemExtraLargePortrait { return entry.portraitPage }
        return family == .systemMedium ? entry.mediumPage : entry.largePage
    }
    private var page: SongWidgetPage {
        SongWidgetPage(songs: entry.songs,
                       requestedIndex: pageIndex,
                       pageSize: pageSize)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: family == .systemMedium ? 1 : 6) {
            Text("Songs")
//                .font(family == .systemMedium ? .subheadline.weight(.semibold) : .headline)
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)

            if entry.songs.isEmpty {
                Text("Add songs in Off The Spots to see them here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(page.songs) { song in
                    HStack(spacing: 8) {
                        Text(song.name)
                            .font(.subheadline)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Link(destination: SongWidgetLink.playURL(for: song.id)) {
                            Image(systemName: "play.circle.fill")
                                .font(.title3)
                                .frame(width: 32, height: family == .systemMedium ? 24 : 32)
                        }
                        .accessibilityLabel("Play \(song.name)")
                    }
                    .frame(height: family == .systemMedium ? 24 : 32)
                }

                if page.count > 1 {
                    Spacer()
                    
                    HStack {
                        Button(intent: ChangeSongsWidgetPageIntent(page: page.index - 1, pageSize: pageSize)) {
                            Image(systemName: "chevron.left")
                                .frame(width: 32, height: 18)
                        }
                        .disabled(page.index == 0)
                        .accessibilityLabel("Previous songs")
                        Spacer(minLength: 0)
                        Text("\(page.index + 1) / \(page.count)")
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Page \(page.index + 1) of \(page.count)")
                        Spacer(minLength: 0)
                        Button(intent: ChangeSongsWidgetPageIntent(page: page.index + 1, pageSize: pageSize)) {
                            Image(systemName: "chevron.right")
                                .frame(width: 32, height: 18)
                        }
                        .disabled(page.index == page.count - 1)
                        .accessibilityLabel("Next songs")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(SongWidgetLink.libraryURL)
        .containerBackground(for: .widget) {
            ScreenBackground()
        }
    }
}

@main
struct SongsWidget: Widget {
    private var supportedFamilies: [WidgetFamily] {
        var families: [WidgetFamily] = [.systemMedium, .systemLarge, .systemExtraLarge]
        if #available(iOS 27.0, *) { families.append(.systemExtraLargePortrait) }
        return families
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: SongWidgetStore.kind, provider: SongsProvider()) { entry in
            SongsWidgetView(entry: entry)
        }
        .configurationDisplayName("Songs")
        .description("Browse your songs and tap play to rehearse in Off The Spots.")
        .supportedFamilies(supportedFamilies)
    }
}

#Preview(as: .systemMedium) {
    SongsWidget()
} timeline: {
    SongsEntry.preview
}

#Preview(as: .systemLarge) {
    SongsWidget()
} timeline: {
    SongsEntry.preview
}

#Preview(as: .systemExtraLarge) {
    SongsWidget()
} timeline: {
    SongsEntry.preview
}

@available(iOS 27.0, *)
#Preview(as: .systemExtraLargePortrait) {
    SongsWidget()
} timeline: {
    SongsEntry.preview
}
