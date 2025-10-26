//
//  PDFView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/24/25.
//

import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {

    let pdfDocument: PDFDocument

    init(showing pdfDoc: PDFDocument) {
        self.pdfDocument = pdfDoc
    }

    //could also have inits that take a URL or Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
//        pdfView.displayMode = .singlePageContinuous
//        pdfView.displayDirection = .vertical
//        pdfView.usePageViewController(false)
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        pdfView.document = pdfDocument
    }
}

struct PDFUIView: View {

    let pdfDoc: PDFDocument

    init(pdfData: Data) {
        self.pdfDoc = PDFDocument(data: pdfData)!
//        let url = Bundle.main.url(forResource: "Lipsum", withExtension: "pdf")!
//        pdfDoc = PDFDocument(url: url)!
    }

    var body: some View {
        PDFKitView(showing: pdfDoc)
    }
}
