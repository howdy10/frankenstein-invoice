import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    let invoice: Invoice
    let settings: CompanySettings

    @Environment(LanguageManager.self) private var lang
    @State private var pdfData: Data?
    @State private var pdfURL: URL?
    @State private var showShareSheet = false

    var body: some View {
        Group {
            if let data = pdfData {
                PDFKitView(data: data)
                    .ignoresSafeArea(edges: .bottom)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("\(lang.s(.invoiceHeading)) #\(invoice.formattedInvoiceNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(pdfURL == nil)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(items: [url])
            }
        }
        .task {
            let data = PDFGenerator.generate(invoice: invoice, settings: settings, language: lang.language)
            pdfData = data
            pdfURL = PDFGenerator.temporaryURL(for: invoice, data: data)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePage
        view.displayDirection = .vertical
        view.backgroundColor = .systemGroupedBackground
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document == nil, let doc = PDFDocument(data: data) {
            uiView.document = doc
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
