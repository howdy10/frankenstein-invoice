# Frankenstein Concrete Invoice App

iOS app for creating, previewing, and sharing professional PDF invoices. Built for a concrete contractor to replace a manual Google Sheets → PDF → email workflow.

---

## Features

- **Create invoices** — customer info, line items, auto-incrementing invoice numbers (starting at 1001)
- **PDF generation** — on-device, matches branded template (dark green accents, company header, itemized table)
- **Share** — save to Files, send via Mail or Messages directly from the app
- **Invoice history** — list of all past invoices, tap to edit and re-export
- **Company settings** — one-time setup for company name, owner, phone, email, Instagram
- **English / Español toggle** — full UI and PDF template localization for Latin American Spanish

---

## Requirements

- Xcode 15+
- iOS 17+ on device
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the `.xcodeproj`
- An Apple Developer account (free tier works for TestFlight via personal device)

---

## Getting Started

**1. Install XcodeGen**
```bash
brew install xcodegen
```

**2. Clone and generate the project**
```bash
git clone https://github.com/howdy10/frankenstein-invoice.git
cd frankenstein-invoice
xcodegen generate
```

**3. Open in Xcode**
```bash
open FrankensteinInvoice.xcodeproj
```

**4. Set signing team**

In Xcode: select the `FrankensteinInvoice` target → **Signing & Capabilities** → set your Apple ID as the team.

**5. Build to device**

Connect iPhone (iOS 17+), select it as the run destination, press **⌘R**.

---

## TestFlight Distribution

1. **Product → Archive**
2. **Distribute App → TestFlight**
3. Follow the prompts — app appears in TestFlight on the target device within a few minutes

---

## First Launch

On first launch the app pre-fills company settings with placeholder values. Go to **Settings (gear icon)** and update:

- Company name
- Owner name
- Phone / Email / Instagram
- Default invoice notes (boilerplate that appears on every new invoice)

---

## Project Structure

```
FrankensteinInvoice/
├── project.yml                        # XcodeGen config — edit here, not .xcodeproj
├── FrankensteinInvoice/
│   ├── FrankensteinInvoiceApp.swift   # App entry, SwiftData + LanguageManager setup
│   ├── Models/
│   │   ├── Invoice.swift              # SwiftData model
│   │   ├── LineItem.swift             # SwiftData model
│   │   └── CompanySettings.swift      # Codable struct, persisted to UserDefaults
│   ├── ViewModels/
│   │   └── InvoiceFormViewModel.swift # Form state, auto-increment logic, save/update
│   ├── Views/
│   │   ├── InvoiceListView.swift      # Root: history list, nav to form/settings
│   │   ├── InvoiceFormView.swift      # Create / edit invoice
│   │   ├── LineItemRowView.swift      # Single editable line item row
│   │   ├── InvoiceDocumentView.swift  # PDF layout (rendered via ImageRenderer)
│   │   ├── PDFPreviewView.swift       # PDFKit preview + share sheet
│   │   └── SettingsView.swift         # Company info + language toggle
│   └── Utilities/
│       ├── PDFGenerator.swift         # InvoiceDocumentView → PDF Data
│       └── AppStrings.swift           # LK enum + LanguageManager (EN/ES strings)
└── FrankensteinInvoiceTests/
    └── InvoiceTests.swift             # Unit tests: auto-increment, subtotal, validation
```

---

## Tech Stack

| | |
|---|---|
| Language | Swift 5.9+ |
| UI | SwiftUI |
| Persistence | SwiftData (iOS 17+) |
| PDF | ImageRenderer + CGContext PDF |
| Localization | Custom `LanguageManager` (`@Observable`) — no Localizable.strings |
| Distribution | TestFlight |
| Dependencies | None |

---

## Running Tests

**⌘U** in Xcode, or:
```bash
xcodebuild test -scheme FrankensteinInvoice -destination 'platform=iOS Simulator,name=iPhone 16'
```
