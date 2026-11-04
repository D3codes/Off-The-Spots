//
//  WidgetLibrary.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/26.
//


import Foundation

enum WidgetLibrary: String, Sendable {
    case songs, setLists

    var title: String { self == .songs ? "Songs" : "Set Lists" }
    var kind: String { self == .songs ? "OffTheSpotsSongs" : "OffTheSpotsSetLists" }
    var snapshotFile: String { self == .songs ? "songs.json" : "set-lists.json" }
    var pageFilePrefix: String { self == .songs ? "page-" : "set-lists-page-" }
    var emptyMessage: String {
        self == .songs ? "Add songs in Off The Spots to see them here." :
            "Add set lists in Off The Spots to see them here."
    }
    var libraryURL: URL {
        self == .songs ? SongWidgetLink.libraryURL : SetListWidgetLink.libraryURL
    }

    func playURL(for id: UUID) -> URL {
        self == .songs ? SongWidgetLink.playURL(for: id) : SetListWidgetLink.playURL(for: id)
    }
}

struct LibraryWidgetRecord: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    let name: String
}

enum SongWidgetLink {
    static let libraryURL = URL(string: "offthespots://songs")!

    static func playURL(for songID: UUID) -> URL {
        URL(string: "offthespots://play/\(songID.uuidString)")!
    }

    static func songID(from url: URL) -> UUID? {
        itemID(from: url, host: "play")
    }

    static func itemID(from url: URL, host: String) -> UUID? {
        guard url.scheme == "offthespots", url.host == host,
              url.user == nil, url.password == nil, url.port == nil,
              url.query == nil, url.fragment == nil,
              url.pathComponents.count == 2 else { return nil }
        return UUID(uuidString: url.lastPathComponent)
    }
}

enum SetListWidgetLink {
    static let libraryURL = URL(string: "offthespots://set-lists")!

    static func playURL(for setListID: UUID) -> URL {
        URL(string: "offthespots://play-set-list/\(setListID.uuidString)")!
    }

    static func setListID(from url: URL) -> UUID? {
        SongWidgetLink.itemID(from: url, host: "play-set-list")
    }
}

struct LibraryWidgetPage {
    let items: [LibraryWidgetRecord]
    let index: Int
    let count: Int

    init(items: [LibraryWidgetRecord], requestedIndex: Int, pageSize: Int) {
        let size = max(1, pageSize)
        count = max(1, (items.count + size - 1) / size)
        index = min(max(0, requestedIndex), count - 1)
        self.items = Array(items.dropFirst(index * size).prefix(size))
    }
}

// Share titles and stable IDs only. The app's existing SwiftData/CloudKit store
// and externally stored audio remain in their original locations.
struct LibraryWidgetStore {
    static let appGroup = "group.codes.d3.Off-The-Spots"
    let library: WidgetLibrary
    let directoryURL: URL?

    init(library: WidgetLibrary = .songs, directoryURL: URL? = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroup
    )?.appendingPathComponent("SongWidget", isDirectory: true)) {
        self.library = library
        self.directoryURL = directoryURL
    }

    func loadItems() -> [LibraryWidgetRecord] {
        read([LibraryWidgetRecord].self, file: library.snapshotFile) ?? []
    }

    @discardableResult
    func saveItems(_ items: [LibraryWidgetRecord]) throws -> Bool {
        if read([LibraryWidgetRecord].self, file: library.snapshotFile) == items { return false }
        try write(items, file: library.snapshotFile)
        return true
    }

    func pageIndex(pageSize: Int) -> Int {
        read(Int.self, file: "\(library.pageFilePrefix)\(pageSize).json") ?? 0
    }

    func setPageIndex(_ index: Int, pageSize: Int) throws {
        let page = LibraryWidgetPage(items: loadItems(), requestedIndex: index, pageSize: pageSize)
        try write(page.index, file: "\(library.pageFilePrefix)\(pageSize).json")
    }

    private func read<T: Decodable>(_ type: T.Type, file: String) -> T? {
        guard let url = directoryURL?.appendingPathComponent(file),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func write<T: Encodable>(_ value: T, file: String) throws {
        guard let directoryURL else { throw CocoaError(.fileNoSuchFile) }
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        try JSONEncoder().encode(value).write(
            to: directoryURL.appendingPathComponent(file),
            options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
        )
    }
}
