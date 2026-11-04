//
//  LibraryWidgetPublisher.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/26.
//

import WidgetKit

enum LibraryWidgetPublisher {
    static func publish(_ items: [LibraryWidgetRecord], library: WidgetLibrary = .songs) {
        do {
            if try LibraryWidgetStore(library: library).saveItems(items) {
                WidgetCenter.shared.reloadTimelines(ofKind: library.kind)
            }
        } catch {
            print("Could not update \(library.title) widget: \(error)")
        }
    }
}
