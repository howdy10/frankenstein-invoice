import Foundation
import Observation

enum LK: String {
    // Navigation
    case invoices, newInvoice, editInvoice, settings
    // Form sections
    case invoiceDetails, invoiceNumberField, dateField
    case billedTo, customerName, address, city, state, zip
    case lineItems, specialNotes, subtotal, total
    // Buttons
    case previewPDF, save, done, delete, cancel
    // List
    case noInvoices, noInvoicesSubtitle
    // Settings
    case company, contact, defaultNotes, name, ownerName
    case phone, email, instagram, language, english, spanish
    // PDF template
    case invoiceHeading, invoiceNumberLabel, dateLabel, billedToLabel
    case activityCol, descriptionCol, qtyCol, amountCol
    case specialNotesLabel, subtotalLabel, totalLabel
    case chequesNote, thankYou, enquiries
    // Placeholders
    case customerNamePlaceholder, addressPlaceholder, cityPlaceholder
    case activityPlaceholder, descriptionPlaceholder
    case phonePlaceholder, emailPlaceholder

    func value(for lang: String) -> String {
        (lang == "es" ? LK.es : LK.en)[self] ?? rawValue
    }

    private static let en: [LK: String] = [
        .invoices: "Invoices",
        .newInvoice: "New Invoice",
        .editInvoice: "Edit Invoice",
        .settings: "Settings",
        .invoiceDetails: "Invoice Details",
        .invoiceNumberField: "Invoice #",
        .dateField: "Date",
        .billedTo: "Billed To",
        .customerName: "Customer Name *",
        .address: "Address",
        .city: "City",
        .state: "State",
        .zip: "ZIP",
        .lineItems: "Line Items",
        .specialNotes: "Special Notes",
        .subtotal: "Subtotal",
        .total: "Total",
        .previewPDF: "Preview PDF",
        .save: "Save",
        .done: "Done",
        .delete: "Delete",
        .cancel: "Cancel",
        .noInvoices: "No Invoices",
        .noInvoicesSubtitle: "Tap + to create your first invoice",
        .company: "Company",
        .contact: "Contact",
        .defaultNotes: "Default Invoice Notes",
        .name: "Name",
        .ownerName: "Owner Name",
        .phone: "Phone",
        .email: "Email",
        .instagram: "Instagram",
        .language: "Language",
        .english: "English",
        .spanish: "Español",
        .invoiceHeading: "Invoice",
        .invoiceNumberLabel: "Invoice #:",
        .dateLabel: "Date:",
        .billedToLabel: "Billed to",
        .activityCol: "Activity",
        .descriptionCol: "Description",
        .qtyCol: "Qty",
        .amountCol: "Amount",
        .specialNotesLabel: "Special notes and instructions",
        .subtotalLabel: "SUBTOTAL",
        .totalLabel: "TOTAL",
        .chequesNote: "Make all cheques payable to",
        .thankYou: "Thank you for your business!",
        .enquiries: "Should you have any enquiries concerning this invoice, please contact us.",
        .customerNamePlaceholder: "Customer Name",
        .addressPlaceholder: "Street Address",
        .cityPlaceholder: "City",
        .activityPlaceholder: "Activity (e.g. Stamp Concrete)",
        .descriptionPlaceholder: "Description (e.g. approx. 1,100 sq. ft)",
        .phonePlaceholder: "(555) 555-5555",
        .emailPlaceholder: "email@example.com",
    ]

    private static let es: [LK: String] = [
        .invoices: "Invoices",
        .newInvoice: "Nueoa Invoice",
        .editInvoice: "Editar Invoice",
        .settings: "Configuración",
        .invoiceDetails: "Detalles de Invoice",
        .invoiceNumberField: "Invoice #",
        .dateField: "Fecha",
        .billedTo: "Facturado A",
        .customerName: "Nombre del Cliente *",
        .address: "Dirección",
        .city: "Ciudad",
        .state: "Estado",
        .zip: "C.P.",
        .lineItems: "Servicios",
        .specialNotes: "Notas Especiales",
        .subtotal: "Subtotal",
        .total: "Total",
        .previewPDF: "Vista Previa PDF",
        .save: "Guardar",
        .done: "Listo",
        .delete: "Eliminar",
        .cancel: "Cancelar",
        .noInvoices: "Sin Invoices",
        .noInvoicesSubtitle: "Toca + para crear tu primer Invoice",
        .company: "Empresa",
        .contact: "Contacto",
        .defaultNotes: "Notas Predeterminadas",
        .name: "Nombre",
        .ownerName: "Nombre del Dueño",
        .phone: "Teléfono",
        .email: "Correo",
        .instagram: "Instagram",
        .language: "Idioma",
        .english: "English",
        .spanish: "Español",
        .invoiceHeading: "Invoice",
        .invoiceNumberLabel: "Invoice #:",
        .dateLabel: "Fecha:",
        .billedToLabel: "Facturado a",
        .activityCol: "Actividad",
        .descriptionCol: "Descripción",
        .qtyCol: "Cant.",
        .amountCol: "Monto",
        .specialNotesLabel: "Notas e instrucciones especiales",
        .subtotalLabel: "SUBTOTAL",
        .totalLabel: "TOTAL",
        .chequesNote: "Emitir cheques a nombre de",
        .thankYou: "¡Gracias por su preferencia!",
        .enquiries: "Si tiene alguna pregunta sobre esta factura, contáctenos.",
        .customerNamePlaceholder: "Nombre del Cliente",
        .addressPlaceholder: "Dirección",
        .cityPlaceholder: "Ciudad",
        .activityPlaceholder: "Actividad (p.ej. Concreto Estampado)",
        .descriptionPlaceholder: "Descripción (p.ej. aprox. 100 m²)",
        .phonePlaceholder: "(555) 555-5555",
        .emailPlaceholder: "correo@ejemplo.com",
    ]
}

@Observable
class LanguageManager {
    var language: String {
        didSet { UserDefaults.standard.set(language, forKey: "appLanguage") }
    }

    init() {
        self.language = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
    }

    func s(_ key: LK) -> String {
        key.value(for: language)
    }

    func deleteTitle(invoiceNumber: String) -> String {
        language == "es"
            ? "¿Eliminar Invoice #\(invoiceNumber)?"
            : "Delete Invoice #\(invoiceNumber)?"
    }

    func invoiceRowLabel(number: String) -> String {
        language == "es" ? "Invoice #\(number)" : "Invoice #\(number)"
    }
}
