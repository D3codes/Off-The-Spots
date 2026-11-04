//
//  LibraryWidgetEntry.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/26.
//


import SwiftUI
import WidgetKit

struct LibraryWidgetEntry: TimelineEntry {
    let date: Date
    let items: [LibraryWidgetRecord]
    let mediumPage: Int
    let largePage: Int
    let portraitPage: Int

    static let songsPreview = LibraryWidgetEntry(
        date: .now,
        items: [
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
        ].map { LibraryWidgetRecord(id: UUID(), name: $0) },
        mediumPage: 0,
        largePage: 0,
        portraitPage: 0
    )

    static let setListsPreview = LibraryWidgetEntry(
        date: .now,
        items: [
            "Contest",
                "Chorus Rehearsal",
                "Christmas Show",
                "Quartet",
                "Warm Ups",
                "Spring Concert",
                "Favorites",
                "Afterglow",
                "New Music",
                "Fall Concert",
                "Community Show",
                "Practice"
               ].map { LibraryWidgetRecord(id: UUID(), name: $0) },
        mediumPage: 0,
        largePage: 0,
        portraitPage: 0
    )

    var lastPagePreview: LibraryWidgetEntry {
        LibraryWidgetEntry(date: date.addingTimeInterval(60), items: items,
                           mediumPage: max(0, items.count - 1) / 3,
                           largePage: max(0, items.count - 1) / 7,
                           portraitPage: max(0, items.count - 1) / 10)
    }
}

struct LibraryWidgetProvider: TimelineProvider {
    let library: WidgetLibrary

    private var preview: LibraryWidgetEntry {
        library == .songs ? .songsPreview : .setListsPreview
    }

    func placeholder(in context: Context) -> LibraryWidgetEntry { preview }

    func getSnapshot(in context: Context, completion: @escaping (LibraryWidgetEntry) -> Void) {
        completion(context.isPreview ? preview : entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LibraryWidgetEntry>) -> Void) {
        completion(Timeline(entries: [entry()], policy: .after(.now.addingTimeInterval(900))))
    }

    private func entry() -> LibraryWidgetEntry {
        let store = LibraryWidgetStore(library: library)
        return LibraryWidgetEntry(date: .now, items: store.loadItems(),
                          mediumPage: store.pageIndex(pageSize: 3),
                          largePage: store.pageIndex(pageSize: 7),
                          portraitPage: store.pageIndex(pageSize: 10))
    }
}

struct LibraryWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: LibraryWidgetEntry
    let library: WidgetLibrary

    private var pageSize: Int {
        if #available(iOS 27.0, *), family == .systemExtraLargePortrait { return 10 }
        return family == .systemMedium ? 3 : 7
    }
    private var pageIndex: Int {
        if #available(iOS 27.0, *), family == .systemExtraLargePortrait { return entry.portraitPage }
        return family == .systemMedium ? entry.mediumPage : entry.largePage
    }
    private var page: LibraryWidgetPage {
        LibraryWidgetPage(items: entry.items,
                       requestedIndex: pageIndex,
                       pageSize: pageSize)
    }

    private var rowSpacing: CGFloat { family == .systemMedium ? 1 : 6 }

    private func rowHeight(in availableHeight: CGFloat) -> CGFloat {
        let preferredHeight: CGFloat = family == .systemMedium ? 24 : 32
        let spacing = CGFloat(pageSize - 1) * rowSpacing
        // Reserve space for a full page, even when the last page has fewer songs.
        return min(preferredHeight, max(0, availableHeight - spacing) / CGFloat(pageSize))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            Text(library.title)
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: rowSpacing) {
                    if entry.items.isEmpty {
                        Text(library.emptyMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(page.items) { item in
                            HStack(spacing: 8) {
                                Text(item.name)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Link(destination: library.playURL(for: item.id)) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title3)
                                        .frame(width: 32, height: rowHeight(in: geometry.size.height))
                                }
                                .accessibilityLabel("Play \(item.name)")
                            }
                            .frame(height: rowHeight(in: geometry.size.height))
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }

            if page.count > 1 {
                pageControls
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(library.libraryURL)
        .containerBackground(for: .widget) {
            ScreenBackground()
        }
    }

    private var pageControls: some View {
        HStack {
            Button(intent: ChangeLibraryWidgetPageIntent(library: library, page: page.index - 1, pageSize: pageSize)) {
                Image(systemName: "chevron.left")
                    .frame(width: 32, height: 18)
            }
            .disabled(page.index == 0)
            .accessibilityLabel("Previous \(library.title.lowercased())")
            Spacer(minLength: 0)
            Text("\(page.index + 1) / \(page.count)")
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .accessibilityLabel("Page \(page.index + 1) of \(page.count)")
            Spacer(minLength: 0)
            Button(intent: ChangeLibraryWidgetPageIntent(library: library, page: page.index + 1, pageSize: pageSize)) {
                Image(systemName: "chevron.right")
                    .frame(width: 32, height: 18)
            }
            .disabled(page.index == page.count - 1)
            .accessibilityLabel("Next \(library.title.lowercased())")
        }
        .buttonStyle(.plain)
    }
}

enum LibraryWidgetFamilies {
    static var supported: [WidgetFamily] {
        var families: [WidgetFamily] = [.systemMedium, .systemLarge, .systemExtraLarge]
        if #available(iOS 27.0, *) { families.append(.systemExtraLargePortrait) }
        return families
    }
}
