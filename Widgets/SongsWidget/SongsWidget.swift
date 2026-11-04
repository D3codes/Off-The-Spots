//
//  SongsWidget.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/26.
//


import SwiftUI
import WidgetKit

struct SongsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetLibrary.songs.kind,
                            provider: LibraryWidgetProvider(library: .songs)) { entry in
            LibraryWidgetView(entry: entry, library: .songs)
        }
        .configurationDisplayName("Songs")
        .description("Browse your songs and tap play to rehearse in Off The Spots.")
        .supportedFamilies(LibraryWidgetFamilies.supported)
    }
}

#Preview(as: .systemMedium) {
    SongsWidget()
} timeline: {
    LibraryWidgetEntry.songsPreview
}

#Preview(as: .systemLarge) {
    SongsWidget()
} timeline: {
    LibraryWidgetEntry.songsPreview
    LibraryWidgetEntry.songsPreview.lastPagePreview
}

#Preview(as: .systemExtraLarge) {
    SongsWidget()
} timeline: {
    LibraryWidgetEntry.songsPreview
    LibraryWidgetEntry.songsPreview.lastPagePreview
}

@available(iOS 27.0, *)
#Preview(as: .systemExtraLargePortrait) {
    SongsWidget()
} timeline: {
    LibraryWidgetEntry.songsPreview
    LibraryWidgetEntry.songsPreview.lastPagePreview
}
