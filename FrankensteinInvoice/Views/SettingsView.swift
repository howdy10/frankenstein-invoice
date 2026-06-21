import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var lang
    @State private var settings = CompanySettings.load()

    var body: some View {
        @Bindable var bindableLang = lang

        NavigationStack {
            Form {
                Section(lang.s(.language)) {
                    Picker(lang.s(.language), selection: $bindableLang.language) {
                        Text(lang.s(.english)).tag("en")
                        Text(lang.s(.spanish)).tag("es")
                    }
                    .pickerStyle(.segmented)
                }

                Section(lang.s(.company)) {
                    HStack {
                        Text(lang.s(.name))
                            .foregroundStyle(.secondary)
                        TextField("Frankenstein Concrete", text: $settings.companyName)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text(lang.s(.ownerName))
                            .foregroundStyle(.secondary)
                        TextField(lang.s(.ownerName), text: $settings.ownerName)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section(lang.s(.contact)) {
                    HStack {
                        Text(lang.s(.phone))
                            .foregroundStyle(.secondary)
                        TextField(lang.s(.phonePlaceholder), text: $settings.phone)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.phonePad)
                    }
                    HStack {
                        Text(lang.s(.email))
                            .foregroundStyle(.secondary)
                        TextField(lang.s(.emailPlaceholder), text: $settings.email)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                    }
                    HStack {
                        Text(lang.s(.instagram))
                            .foregroundStyle(.secondary)
                        TextField("@handle", text: $settings.instagram)
                            .multilineTextAlignment(.trailing)
                            .textInputAutocapitalization(.never)
                    }
                }

                Section(lang.s(.defaultNotes)) {
                    TextEditor(text: $settings.defaultNotes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle(lang.s(.settings))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.s(.done)) {
                        settings.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
