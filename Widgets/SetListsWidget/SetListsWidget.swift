//
//  SetListsWidget.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/26.
//


import SwiftUI
import WidgetKit

struct SetListsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetLibrary.setLists.kind,
                            provider: LibraryWidgetProvider(library: .setLists)) { entry in
            LibraryWidgetView(entry: entry, library: .setLists)
        }
        .configurationDisplayName("Set Lists")
        .description("Browse your set lists and play each one from the first song.")
        .supportedFamilies(LibraryWidgetFamilies.supported)
    }
}

#Preview(as: .systemMedium) {
    SetListsWidget()
} timeline: {
    LibraryWidgetEntry.setListsPreview
}

#Preview(as: .systemLarge) {
    SetListsWidget()
} timeline: {
    LibraryWidgetEntry.setListsPreview
    LibraryWidgetEntry.setListsPreview.lastPagePreview
}

#Preview(as: .systemExtraLarge) {
    SetListsWidget()
} timeline: {
    LibraryWidgetEntry.setListsPreview
    LibraryWidgetEntry.setListsPreview.lastPagePreview
}

@available(iOS 27.0, *)
#Preview(as: .systemExtraLargePortrait) {
    SetListsWidget()
} timeline: {
    LibraryWidgetEntry.setListsPreview
    LibraryWidgetEntry.setListsPreview.lastPagePreview
}
