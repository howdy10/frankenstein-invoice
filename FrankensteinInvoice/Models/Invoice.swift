import Foundation
import SwiftData

@Model
final class Invoice {
    var id: UUID = UUID()
    var invoiceNumber: Int = 1001
    var date: Date = Date.now
    var customerName: String = ""
    var customerAddress: String = ""
    var customerCity: String = ""
    var customerState: String = ""
    var customerZip: String = ""
    var notes: String = ""
    @Relationship(deleteRule: .cascade, inverse: \LineItem.invoice)
    var lineItems: [LineItem] = []

    init(invoiceNumber: Int,
         date: Date = .now,
         customerName: String = "",
         customerAddress: String = "",
         customerCity: String = "",
         customerState: String = "",
         customerZip: String = "",
         notes: String = "") {
        self.id = UUID()
        self.invoiceNumber = invoiceNumber
        self.date = date
        self.customerName = customerName
        self.customerAddress = customerAddress
        self.customerCity = customerCity
        self.customerState = customerState
        self.customerZip = customerZip
        self.notes = notes
        self.lineItems = []
    }

    var subtotal: Double {
        lineItems.reduce(0.0) { $0 + $1.amount }
    }

    var formattedInvoiceNumber: String {
        String(format: "%04d", invoiceNumber)
    }
}
