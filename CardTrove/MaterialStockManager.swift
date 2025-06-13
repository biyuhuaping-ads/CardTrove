import Foundation

class MaterialStockManager: ObservableObject {
    @Published private(set) var materials: [MaterialStock] {
        didSet {
            saveData()
        }
    }

    private let fileName = "materialStock.json"

    init() {
        self.materials = []
        loadData()
        if materials.isEmpty {
            loadSampleData()
        }
    }

    // MARK: - CRUD Operations

    func add(_ item: MaterialStock) {
        materials.append(item)
    }

    func update(_ item: MaterialStock) {
        if let index = materials.firstIndex(where: { $0.id == item.id }) {
            materials[index] = item
        }
    }

    func delete(at offsets: IndexSet) {
        materials.remove(atOffsets: offsets)
    }

    // MARK: - Persistence

    private func saveData() {
        do {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            let data = try JSONEncoder().encode(materials)
            try data.write(to: url)
        } catch {
            print("Failed to save material stock: \(error)")
        }
    }

    private func loadData() {
        do {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([MaterialStock].self, from: data)
            materials = decoded
        } catch {
            print("Failed to load material stock: \(error)")
            materials = []
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // MARK: - Sample Data

    private func loadSampleData() {
        materials = [
            MaterialStock(
                id: UUID(),
                materialName: "HP 678 Ink (Black)",
                category: "Ink",
                quantity: 3,
                unitType: "Cartridges",
                reorderLevel: 2,
                supplier: "PrintSupplies Co.",
                costPerUnit: 750.0,
                lastRestocked: Date(),
                expirationDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()),
                storageLocation: "Drawer A1",
                isCritical: true,
                lastUsedDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
                damageReported: false,
                barcode: "INK678-BLACK",
                purchaseReference: "PO-8723",
                qualityRating: 5,
                notes: "Only for HP Deskjet printers"
            ),
            MaterialStock(
                id: UUID(),
                materialName: "Glossy Card Paper A4",
                category: "Card Paper",
                quantity: 150,
                unitType: "Sheets",
                reorderLevel: 50,
                supplier: "PaperWorld",
                costPerUnit: 3.5,
                lastRestocked: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
                expirationDate: nil,
                storageLocation: "Shelf B2",
                isCritical: false,
                lastUsedDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
                damageReported: true,
                barcode: "CARD-A4-GLS",
                purchaseReference: "PO-8651",
                qualityRating: 4,
                notes: "Some sheets have corner bends"
            )
        ]
    }
}
