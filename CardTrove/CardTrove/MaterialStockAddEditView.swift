import SwiftUI

struct MaterialStockAddEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var manager: MaterialStockManager
    @Binding var itemToEdit: MaterialStock?

    // MARK: – State
    @State private var name = ""
    @State private var category = ""
    @State private var quantity = ""
    @State private var unitType = ""
    @State private var reorderLevel = ""
    @State private var supplier = ""
    @State private var costPerUnit = ""
    @State private var storageLocation = ""
    @State private var isCritical = false
    @State private var damageReported = false

    // Optional dates
    @State private var hasExpiration = false
    @State private var expirationDate = Date()
    @State private var hasLastUsed = false
    @State private var lastUsedDate = Date()

    @State private var lastRestocked = Date()
    @State private var barcode = ""
    @State private var reference = ""
    @State private var notes = ""
    @State private var qualityRating = ""
    @State private var showAlert = false

    // MARK: – View
    var body: some View {
        NavigationView {
            Form {
                Group {
                    Section(header: Text("Item Details")) {
                        TextField("Material Name", text: $name)
                        TextField("Category", text: $category)
                        TextField("Unit Type", text: $unitType)
                        TextField("Quantity", text: $quantity)
                            .keyboardType(.numberPad)
                        TextField("Reorder Level", text: $reorderLevel)
                            .keyboardType(.numberPad)
                    }

                    Section(header: Text("Supplier & Cost")) {
                        TextField("Supplier", text: $supplier)
                        TextField("Cost Per Unit", text: $costPerUnit)
                            .keyboardType(.decimalPad)
                        TextField("Storage Location", text: $storageLocation)
                    }

                    Section(header: Text("Dates")) {
                        DatePicker("Last Restocked",
                                   selection: $lastRestocked,
                                   displayedComponents: .date)

                        Toggle("Has Expiration Date", isOn: $hasExpiration.animation())
                        if hasExpiration {
                            DatePicker("Expiration Date",
                                       selection: $expirationDate,
                                       displayedComponents: .date)
                        }

                        Toggle("Track Last Used", isOn: $hasLastUsed.animation())
                        if hasLastUsed {
                            DatePicker("Last Used",
                                       selection: $lastUsedDate,
                                       displayedComponents: .date)
                        }
                    }

                    Section(header: Text("Extra Info")) {
                        Toggle("Is Critical?", isOn: $isCritical)
                        Toggle("Damage Reported", isOn: $damageReported)
                        TextField("Barcode", text: $barcode)
                        TextField("Purchase Reference", text: $reference)
                        TextField("Quality Rating (1‑5)", text: $qualityRating)
                            .keyboardType(.numberPad)
                        TextEditor(text: $notes)
                            .frame(height: 65)
                    }
                }
            }
            .navigationTitle(itemToEdit == nil ? "Add Material" : "Edit Material")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveData)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
            }
            .onAppear(perform: populateData)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Missing Fields"),
                      message: Text("Name, quantity, reorder level, and cost are required."),
                      dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: – Save
    private func saveData() {
        guard
            !name.trimmingCharacters(in: .whitespaces).isEmpty,
            let qty = Int(quantity),
            let reorder = Int(reorderLevel),
            let cost = Double(costPerUnit)
        else {
            showAlert = true
            return
        }

        let material = MaterialStock(
            id: itemToEdit?.id ?? UUID(),
            materialName: name,
            category: category,
            quantity: qty,
            unitType: unitType,
            reorderLevel: reorder,
            supplier: supplier,
            costPerUnit: cost,
            lastRestocked: lastRestocked,
            expirationDate: hasExpiration ? expirationDate : nil,
            storageLocation: storageLocation,
            isCritical: isCritical,
            lastUsedDate: hasLastUsed ? lastUsedDate : nil,
            damageReported: damageReported,
            barcode: barcode.isEmpty ? nil : barcode,
            purchaseReference: reference.isEmpty ? nil : reference,
            qualityRating: Int(qualityRating),
            notes: notes.isEmpty ? nil : notes
        )

        if itemToEdit == nil {
            manager.add(material)
        } else {
            manager.update(material)
        }
        presentationMode.wrappedValue.dismiss()
    }

    // MARK: – Populate
    private func populateData() {
        guard let m = itemToEdit else { return }
        name             = m.materialName
        category         = m.category
        unitType         = m.unitType
        quantity         = String(m.quantity)
        reorderLevel     = String(m.reorderLevel)
        supplier         = m.supplier
        costPerUnit      = String(m.costPerUnit)
        storageLocation  = m.storageLocation
        lastRestocked    = m.lastRestocked

        if let exp = m.expirationDate { hasExpiration = true; expirationDate = exp }
        if let last = m.lastUsedDate   { hasLastUsed  = true; lastUsedDate  = last }

        barcode         = m.barcode ?? ""
        reference       = m.purchaseReference ?? ""
        qualityRating   = m.qualityRating.map(String.init) ?? ""
        notes           = m.notes ?? ""
        isCritical      = m.isCritical
        damageReported  = m.damageReported
    }
}
