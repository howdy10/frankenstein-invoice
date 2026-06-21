import SwiftUI
import SwiftData

@main
struct FrankensteinInvoiceApp: App {
    @State private var langManager = LanguageManager()

    var body: some Scene {
        WindowGroup {
            InvoiceListView()
                .environment(langManager)
        }
        .modelContainer(for: [Invoice.self, LineItem.self])
    }
}
