import SwiftUI

extension Color {
    static let invoiceGreen = Color(red: 37/255, green: 94/255, blue: 36/255)
}

struct InvoiceDocumentView: View {
    let invoice: Invoice
    let settings: CompanySettings
    let language: String

    private func t(_ key: LK) -> String { key.value(for: language) }

    private static let currency: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        return f
    }()

    private static let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yyyy"
        return f
    }()

    private func fmt(_ value: Double) -> String {
        Self.currency.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
                .padding(.top, 40)

            Spacer().frame(height: 24)

            billedToView

            Spacer().frame(height: 20)

            lineItemsTable

            Spacer().frame(height: 20)

            notesAndTotals

            Spacer().frame(height: 14)

            Text("\(t(.chequesNote)) \(settings.companyName)")
                .font(.system(size: 10))
                .foregroundStyle(Color(white: 0.5))
                .padding(.horizontal, 40)

            Spacer().frame(height: 16)

            Text(t(.thankYou))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.invoiceGreen)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer().frame(height: 6)

            Text(t(.enquiries))
                .font(.system(size: 10))
                .foregroundStyle(Color(white: 0.5))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 80)

            Spacer()

            footerView
                .padding(.bottom, 24)
        }
        .frame(width: 612, height: 792)
        .background(Color.white)
    }

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(settings.companyName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.invoiceGreen)

                HStack(spacing: 16) {
                    Text(settings.ownerName)
                    Text(settings.phone)
                }
                .font(.system(size: 11))

                Text(settings.email)
                    .font(.system(size: 11))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(t(.invoiceHeading))
                    .font(.system(size: 20, weight: .semibold))

                HStack(spacing: 6) {
                    Text(t(.invoiceNumberLabel))
                        .font(.system(size: 11))
                        .foregroundStyle(Color(white: 0.5))
                    Text(invoice.formattedInvoiceNumber)
                        .font(.system(size: 11))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(white: 0.93))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }

                HStack(spacing: 6) {
                    Text(t(.dateLabel))
                        .font(.system(size: 11))
                        .foregroundStyle(Color(white: 0.5))
                    Text(Self.dateFmt.string(from: invoice.date))
                        .font(.system(size: 11))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(white: 0.93))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }
        }
        .padding(.horizontal, 40)
    }

    private var billedToView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(t(.billedToLabel))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.invoiceGreen)
                .clipShape(RoundedRectangle(cornerRadius: 3))

            VStack(alignment: .leading, spacing: 2) {
                Text(invoice.customerName)
                    .font(.system(size: 12))
                if !invoice.customerAddress.isEmpty {
                    Text(invoice.customerAddress)
                        .font(.system(size: 12))
                }
                let parts = [invoice.customerCity, invoice.customerState]
                    .filter { !$0.isEmpty }.joined(separator: ", ")
                let zip = invoice.customerZip.isEmpty ? "" : " \(invoice.customerZip)"
                if !parts.isEmpty || !zip.isEmpty {
                    Text(parts + zip)
                        .font(.system(size: 12))
                }
            }
        }
        .padding(.horizontal, 40)
    }

    private var lineItemsTable: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(t(.activityCol))
                    .frame(width: 130, alignment: .leading)
                Text(t(.descriptionCol))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(t(.qtyCol))
                    .frame(width: 44, alignment: .center)
                Text(t(.amountCol))
                    .frame(width: 90, alignment: .trailing)
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.invoiceGreen)

            let sorted = invoice.lineItems.sorted { $0.id.uuidString < $1.id.uuidString }
            ForEach(Array(sorted.enumerated()), id: \.offset) { index, item in
                HStack(spacing: 0) {
                    Text(item.activity)
                        .frame(width: 130, alignment: .leading)
                    Text(item.descriptionText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(item.quantity)")
                        .frame(width: 44, alignment: .center)
                    Text(fmt(item.amount))
                        .frame(width: 90, alignment: .trailing)
                }
                .font(.system(size: 11))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(index % 2 == 0 ? Color.white : Color(white: 0.97))

                Rectangle()
                    .fill(Color(white: 0.88))
                    .frame(height: 0.5)
                    .padding(.horizontal, 12)
            }

            let filled = sorted.count
            let empty = max(0, 5 - filled)
            ForEach(0..<empty, id: \.self) { i in
                Color((filled + i) % 2 == 0 ? .white : Color(white: 0.97))
                    .frame(height: 36)
                Rectangle()
                    .fill(Color(white: 0.88))
                    .frame(height: 0.5)
                    .padding(.horizontal, 12)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(white: 0.85), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .padding(.horizontal, 40)
    }

    private var notesAndTotals: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 0) {
                Text(t(.specialNotesLabel))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.invoiceGreen)

                Text(invoice.notes)
                    .font(.system(size: 10))
                    .foregroundStyle(Color(white: 0.3))
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(white: 0.97))
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))

            VStack(alignment: .trailing, spacing: 10) {
                HStack {
                    Text(t(.subtotalLabel))
                        .font(.system(size: 11))
                        .foregroundStyle(Color(white: 0.5))
                    Spacer()
                    Text(fmt(invoice.subtotal))
                        .font(.system(size: 11))
                }

                Rectangle()
                    .fill(Color(white: 0.85))
                    .frame(height: 0.5)

                HStack {
                    Text(t(.totalLabel))
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                    Text(fmt(invoice.subtotal))
                        .font(.system(size: 22, weight: .bold))
                }
            }
            .frame(width: 186)
            .padding(.top, 4)
        }
        .padding(.horizontal, 40)
    }

    private var footerView: some View {
        VStack(spacing: 4) {
            Rectangle()
                .fill(Color(white: 0.85))
                .frame(height: 0.5)
                .padding(.horizontal, 40)

            Text(settings.companyName + " LLC")
                .font(.system(size: 11))
                .padding(.top, 6)

            Text("Tel: \(settings.phone) | \(settings.email) | Instagram: @\(settings.instagram)")
                .font(.system(size: 10))
                .foregroundStyle(Color(white: 0.5))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
