import Foundation
import SwiftData
import Observation

struct LineItemForm: Identifiable {
    var id = UUID()
    var activity: String = ""
    var descriptionText: String = ""
    var quantity: Int = 1
    var amountString: String = ""

    init() {}

    init(from item: LineItem) {
        self.id = item.id
        self.activity = item.activity
        self.descriptionText = item.descriptionText
        self.quantity = item.quantity
        self.amountString = item.amount > 0 ? String(format: "%.2f", item.amount) : ""
    }

    var parsedAmount: Double {
        let clean = amountString
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        return Double(clean) ?? 0.0
    }

    func toLineItem() -> LineItem {
        LineItem(activity: activity, descriptionText: descriptionText,
                 quantity: quantity, amount: parsedAmount)
    }
}

@Observable
class InvoiceFormViewModel {
    var invoiceNumber: Int = 1001
    var date: Date = .now
    var customerName: String = ""
    var customerAddress: String = ""
    var customerCity: String = ""
    var customerState: String = ""
    var customerZip: String = ""
    var notes: String = ""
    var lineItems: [LineItemForm] = [LineItemForm()]

    var formattedInvoiceNumber: String {
        String(format: "%04d", invoiceNumber)
    }

    var subtotal: Double {
        lineItems.reduce(0.0) { $0 + $1.parsedAmount }
    }

    var isValid: Bool {
        !customerName.trimmingCharacters(in: .whitespaces).isEmpty &&
        lineItems.contains { !$0.activity.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    func setupForNew(context: ModelContext, settings: CompanySettings) {
        notes = settings.defaultNotes
        var descriptor = FetchDescriptor<Invoice>(sortBy: [SortDescriptor(\.invoiceNumber, order: .reverse)])
        descriptor.fetchLimit = 1
        let results = (try? context.fetch(descriptor)) ?? []
        invoiceNumber = (results.first?.invoiceNumber ?? 1000) + 1
    }

    func populate(from invoice: Invoice) {
        invoiceNumber = invoice.invoiceNumber
        date = invoice.date
        customerName = invoice.customerName
        customerAddress = invoice.customerAddress
        customerCity = invoice.customerCity
        customerState = invoice.customerState
        customerZip = invoice.customerZip
        notes = invoice.notes
        let sorted = invoice.lineItems.sorted { $0.id.uuidString < $1.id.uuidString }
        lineItems = sorted.map { LineItemForm(from: $0) }
        if lineItems.isEmpty { lineItems = [LineItemForm()] }
    }

    func applyTo(invoice: Invoice, context: ModelContext) {
        invoice.invoiceNumber = invoiceNumber
        invoice.date = date
        invoice.customerName = customerName
        invoice.customerAddress = customerAddress
        invoice.customerCity = customerCity
        invoice.customerState = customerState
        invoice.customerZip = customerZip
        invoice.notes = notes

        let old = invoice.lineItems
        invoice.lineItems = []
        for item in old { context.delete(item) }

        let filtered = lineItems.filter { !$0.activity.trimmingCharacters(in: .whitespaces).isEmpty }
        for form in filtered {
            let item = form.toLineItem()
            context.insert(item)
            invoice.lineItems.append(item)
        }
        try? context.save()
    }

    @discardableResult
    func saveNew(context: ModelContext) -> Invoice {
        let invoice = Invoice(
            invoiceNumber: invoiceNumber, date: date,
            customerName: customerName, customerAddress: customerAddress,
            customerCity: customerCity, customerState: customerState,
            customerZip: customerZip, notes: notes
        )
        context.insert(invoice)

        let filtered = lineItems.filter { !$0.activity.trimmingCharacters(in: .whitespaces).isEmpty }
        for form in filtered {
            let item = form.toLineItem()
            context.insert(item)
            invoice.lineItems.append(item)
        }
        try? context.save()
        return invoice
    }
}
