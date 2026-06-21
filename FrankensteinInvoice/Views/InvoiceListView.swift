import SwiftUI
import SwiftData

struct InvoiceListView: View {
    @Query(sort: \Invoice.date, order: .reverse) private var invoices: [Invoice]
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var lang
    @State private var showSettings = false
    @State private var showNewInvoice = false
    @State private var invoiceToDelete: Invoice?

    private let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }()

    private let currency: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f
    }()

    var body: some View {
        NavigationStack {
            List {
                ForEach(invoices) { invoice in
                    NavigationLink {
                        InvoiceFormView(invoice: invoice)
                    } label: {
                        rowView(for: invoice)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            invoiceToDelete = invoice
                        } label: {
                            Label(lang.s(.delete), systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(lang.s(.invoices))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewInvoice = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .overlay {
                if invoices.isEmpty {
                    ContentUnavailableView(
                        lang.s(.noInvoices),
                        systemImage: "doc.text",
                        description: Text(lang.s(.noInvoicesSubtitle))
                    )
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showNewInvoice) {
                NavigationStack {
                    InvoiceFormView(invoice: nil)
                }
            }
            .confirmationDialog(
                deleteTitle,
                isPresented: .init(
                    get: { invoiceToDelete != nil },
                    set: { if !$0 { invoiceToDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button(lang.s(.delete), role: .destructive) {
                    if let invoice = invoiceToDelete {
                        modelContext.delete(invoice)
                        try? modelContext.save()
                    }
                    invoiceToDelete = nil
                }
                Button(lang.s(.cancel), role: .cancel) {
                    invoiceToDelete = nil
                }
            }
        }
    }

    private var deleteTitle: String {
        invoiceToDelete.map { lang.deleteTitle(invoiceNumber: $0.formattedInvoiceNumber) }
            ?? (lang.language == "es" ? "¿Eliminar Factura?" : "Delete Invoice?")
    }

    private func rowView(for invoice: Invoice) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(lang.invoiceRowLabel(number: invoice.formattedInvoiceNumber))
                    .font(.headline)
                Text(invoice.customerName.isEmpty ? (lang.language == "es" ? "Sin cliente" : "No customer") : invoice.customerName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(currency.string(from: NSNumber(value: invoice.subtotal)) ?? "$0.00")
                    .font(.headline)
                Text(dateFmt.string(from: invoice.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
