import SwiftUI
import SwiftData

struct InvoiceFormView: View {
    let existingInvoice: Invoice?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var lang
    @State private var viewModel = InvoiceFormViewModel()
    @State private var hasLoaded = false
    @State private var showPDFPreview = false
    @State private var savedInvoice: Invoice?

    init(invoice: Invoice?) {
        self.existingInvoice = invoice
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                invoiceHeaderSection
                billedToSection
                lineItemsSection
                notesSection
                totalsSection
                previewButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
            .padding(.top, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(existingInvoice == nil ? lang.s(.newInvoice) : lang.s(.editInvoice))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(lang.s(.save)) {
                    if let existing = existingInvoice {
                        viewModel.applyTo(invoice: existing, context: modelContext)
                    } else {
                        viewModel.saveNew(context: modelContext)
                    }
                    dismiss()
                }
                .disabled(!viewModel.isValid)
            }
        }
        .onAppear {
            guard !hasLoaded else { return }
            hasLoaded = true
            if let existing = existingInvoice {
                viewModel.populate(from: existing)
            } else {
                viewModel.setupForNew(context: modelContext, settings: CompanySettings.load())
            }
        }
        .navigationDestination(isPresented: $showPDFPreview) {
            if let invoice = savedInvoice {
                PDFPreviewView(invoice: invoice, settings: CompanySettings.load())
            }
        }
    }

    // MARK: - Sections

    private var invoiceHeaderSection: some View {
        cardSection(title: lang.s(.invoiceDetails)) {
            HStack {
                Text(lang.s(.invoiceNumberField))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(viewModel.formattedInvoiceNumber)
                    .fontWeight(.semibold)
            }
            .padding()

            Divider().padding(.leading)

            DatePicker(lang.s(.dateField), selection: $viewModel.date, displayedComponents: .date)
                .padding()
        }
    }

    private var billedToSection: some View {
        cardSection(title: lang.s(.billedTo)) {
            formRow(label: lang.s(.customerName),
                    text: $viewModel.customerName,
                    placeholder: lang.s(.customerNamePlaceholder))
            Divider().padding(.leading)
            formRow(label: lang.s(.address),
                    text: $viewModel.customerAddress,
                    placeholder: lang.s(.addressPlaceholder))
            Divider().padding(.leading)
            formRow(label: lang.s(.city),
                    text: $viewModel.customerCity,
                    placeholder: lang.s(.cityPlaceholder))
            Divider().padding(.leading)
            HStack(spacing: 0) {
                HStack {
                    Text(lang.s(.state))
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 44, alignment: .leading)
                    TextField("TX", text: $viewModel.customerState)
                        .textInputAutocapitalization(.characters)
                }
                .padding()
                .frame(maxWidth: .infinity)

                Divider()

                HStack {
                    Text(lang.s(.zip))
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 32, alignment: .leading)
                    TextField("00000", text: $viewModel.customerZip)
                        .keyboardType(.numberPad)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var lineItemsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(lang.s(.lineItems))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .padding(.horizontal, 20)
                Spacer()
                Button {
                    viewModel.lineItems.append(LineItemForm())
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.invoiceGreen)
                        .font(.title3)
                }
                .padding(.trailing, 20)
            }

            ForEach(viewModel.lineItems.map(\.id), id: \.self) { id in
                if let idx = viewModel.lineItems.firstIndex(where: { $0.id == id }) {
                    LineItemRowView(item: $viewModel.lineItems[idx]) {
                        viewModel.lineItems.remove(at: idx)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    private var notesSection: some View {
        cardSection(title: lang.s(.specialNotes)) {
            TextEditor(text: $viewModel.notes)
                .frame(minHeight: 100)
                .padding(8)
        }
    }

    private var totalsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text(lang.s(.subtotal))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(formatCurrency(viewModel.subtotal))
            }
            .padding()

            Divider().padding(.horizontal)

            HStack {
                Text(lang.s(.total))
                    .font(.headline)
                Spacer()
                Text(formatCurrency(viewModel.subtotal))
                    .font(.title3.bold())
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
    }

    private var previewButton: some View {
        Button {
            saveAndPreview()
        } label: {
            Text(lang.s(.previewPDF))
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isValid ? Color.invoiceGreen : Color(.systemGray4))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!viewModel.isValid)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func cardSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                content()
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
        }
    }

    private func formRow(label: String, text: Binding<String>, placeholder: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(minWidth: 110, alignment: .leading)
            TextField(placeholder, text: text)
        }
        .padding()
    }

    private func formatCurrency(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func saveAndPreview() {
        if let existing = existingInvoice {
            viewModel.applyTo(invoice: existing, context: modelContext)
            savedInvoice = existing
        } else {
            savedInvoice = viewModel.saveNew(context: modelContext)
        }
        showPDFPreview = true
    }
}
