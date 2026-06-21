import SwiftUI
import UIKit

@MainActor
enum PDFGenerator {
    static func generate(invoice: Invoice, settings: CompanySettings, language: String) -> Data {
        let view = InvoiceDocumentView(invoice: invoice, settings: settings, language: language)
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = ProposedViewSize(width: 612, height: 792)
        renderer.scale = 2.0

        let pdfData = NSMutableData()
        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData) else {
            return Data()
        }
        var mediaBox = CGRect(x: 0, y: 0, width: 612, height: 792)
        guard let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            return Data()
        }

        renderer.render { _, draw in
            pdfContext.beginPDFPage(nil)
            draw(pdfContext)
            pdfContext.endPDFPage()
        }
        pdfContext.closePDF()

        return pdfData as Data
    }

    static func temporaryURL(for invoice: Invoice, data: Data) -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Invoice \(invoice.formattedInvoiceNumber).pdf")
        try? data.write(to: url)
        return url
    }
}
