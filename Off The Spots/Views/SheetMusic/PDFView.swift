//
//  PDFView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/24/25.
//

import SwiftUI
import PDFKit

struct PDFUIView: UIViewRepresentable {
    let pdfData: Data

    @MainActor
    final class Coordinator {
        private var loadedData: Data?

        func loadIfNeeded(_ data: Data, into pdfView: PDFView) {
            // Preserve scroll position and zoom during unrelated SwiftUI updates.
            guard loadedData != data else { return }

            pdfView.document = PDFDocument(data: data)
            loadedData = data
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        context.coordinator.loadIfNeeded(pdfData, into: pdfView)
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        context.coordinator.loadIfNeeded(pdfData, into: pdfView)
    }
}
