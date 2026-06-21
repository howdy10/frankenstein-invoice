import SwiftUI

struct LineItemRowView: View {
    @Binding var item: LineItemForm
    @Environment(LanguageManager.self) private var lang
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TextField(lang.s(.activityPlaceholder), text: $item.activity)
                    .font(.headline)
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.red)
                        .font(.title3)
                }
            }

            TextField(lang.s(.descriptionPlaceholder), text: $item.descriptionText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text(lang.s(.qtyCol))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Stepper(value: $item.quantity, in: 1...99) {
                    Text("\(item.quantity)")
                        .frame(minWidth: 24, alignment: .leading)
                }
                .fixedSize()

                Spacer()

                HStack(spacing: 2) {
                    Text("$")
                        .foregroundStyle(.secondary)
                    TextField("0.00", text: $item.amountString)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
            }
        }
    }
}
