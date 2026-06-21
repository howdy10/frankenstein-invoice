import Foundation
import SwiftData

@Model
final class LineItem {
    var id: UUID = UUID()
    var activity: String = ""
    var descriptionText: String = ""
    var quantity: Int = 1
    var amount: Double = 0.0
    var invoice: Invoice?

    init(activity: String = "",
         descriptionText: String = "",
         quantity: Int = 1,
         amount: Double = 0.0) {
        self.id = UUID()
        self.activity = activity
        self.descriptionText = descriptionText
        self.quantity = quantity
        self.amount = amount
    }
}
