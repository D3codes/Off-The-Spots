//
//  ChangeLibraryWidgetPageIntent.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/26.
//


import AppIntents
import WidgetKit

struct ChangeLibraryWidgetPageIntent: AppIntent {
    static let title: LocalizedStringResource = "Change Library Page"
    static let isDiscoverable = false

    @Parameter(title: "Library") var libraryName: String
    @Parameter(title: "Page") var page: Int
    @Parameter(title: "Items per Page") var pageSize: Int

    init() {}

    init(library: WidgetLibrary, page: Int, pageSize: Int) {
        self.libraryName = library.rawValue
        self.page = page
        self.pageSize = pageSize
    }

    func perform() async throws -> some IntentResult {
        guard let library = WidgetLibrary(rawValue: libraryName) else { return .result() }
        try LibraryWidgetStore(library: library).setPageIndex(page, pageSize: pageSize)
        WidgetCenter.shared.reloadTimelines(ofKind: library.kind)
        return .result()
    }
}
