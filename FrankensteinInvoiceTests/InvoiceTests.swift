import XCTest
import SwiftData
@testable import FrankensteinInvoice

final class InvoiceTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Invoice.self, LineItem.self, configurations: config)
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    func testNextInvoiceNumberEmptyStore() {
        let vm = InvoiceFormViewModel()
        vm.setupForNew(context: context, settings: .default)
        XCTAssertEqual(vm.invoiceNumber, 1001)
    }

    func testNextInvoiceNumberIncrement() throws {
        let invoice = Invoice(invoiceNumber: 1005)
        context.insert(invoice)
        try context.save()

        let vm = InvoiceFormViewModel()
        vm.setupForNew(context: context, settings: .default)
        XCTAssertEqual(vm.invoiceNumber, 1006)
    }

    func testSubtotalCalculation() {
        let vm = InvoiceFormViewModel()
        vm.lineItems = [
            makeItem("6600.00"),
            makeItem("3420.00"),
            makeItem("4480.00"),
        ]
        XCTAssertEqual(vm.subtotal, 14500.00, accuracy: 0.001)
    }

    func testSubtotalEmptyItems() {
        let vm = InvoiceFormViewModel()
        vm.lineItems = []
        XCTAssertEqual(vm.subtotal, 0.0)
    }

    func testCurrencyFormattingRetainsCents() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let formatted = formatter.string(from: NSNumber(value: 6600.99))!
        XCTAssertTrue(formatted.contains(".99"), "Currency must retain cents: \(formatted)")
    }

    func testFormattedInvoiceNumber() {
        let invoice = Invoice(invoiceNumber: 1001)
        XCTAssertEqual(invoice.formattedInvoiceNumber, "1001")
    }

    func testIsValidRequiresCustomerName() {
        let vm = InvoiceFormViewModel()
        vm.customerName = ""
        vm.lineItems = [makeItem("100.00")]
        XCTAssertFalse(vm.isValid)

        vm.customerName = "John Doe"
        XCTAssertTrue(vm.isValid)
    }

    func testIsValidRequiresLineItem() {
        let vm = InvoiceFormViewModel()
        vm.customerName = "John Doe"
        vm.lineItems = []
        XCTAssertFalse(vm.isValid)
    }

    // MARK: - Helpers

    private func makeItem(_ amountString: String) -> LineItemForm {
        var item = LineItemForm()
        item.activity = "Test"
        item.amountString = amountString
        return item
    }
}
