import Foundation

struct CompanySettings: Codable {
    var companyName: String
    var ownerName: String
    var phone: String
    var email: String
    var instagram: String
    var defaultNotes: String

    static var `default`: CompanySettings {
        CompanySettings(
            companyName: "Frankenstein Concrete",
            ownerName: "Owner Name",
            phone: "(555) 555-5555",
            email: "owneremail@yahoo.com",
            instagram: "frankenstain concrete",
            defaultNotes: "INCLUDES:\n-Prices include cost of material, equipment, and labor.\n-All labor and cleanup to complete the above scope of work.\n-Job site to be left in a clean and orderly manner."
        )
    }

    static func load() -> CompanySettings {
        guard let data = UserDefaults.standard.data(forKey: "companySettings"),
              let settings = try? JSONDecoder().decode(CompanySettings.self, from: data)
        else { return .default }
        return settings
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: "companySettings")
    }
}
