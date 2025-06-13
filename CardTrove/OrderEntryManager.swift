import Foundation

class OrderEntryManager: ObservableObject {
    @Published private(set) var orders: [OrderEntry] {
        didSet {
            saveData()
        }
    }

    private let fileName = "orderEntries.json"

    init() {
        self.orders = []
        loadData()
        if orders.isEmpty {
            loadSampleData()
        }
    }

    // MARK: - CRUD

    func add(_ order: OrderEntry) {
        orders.append(order)
    }

    func update(_ order: OrderEntry) {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index] = order
        }
    }

    func delete(at offsets: IndexSet) {
        orders.remove(atOffsets: offsets)
    }

    // MARK: - Persistence

    private func saveData() {
        do {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            let data = try JSONEncoder().encode(orders)
            try data.write(to: url)
        } catch {
            print("Failed to save order entries: \(error)")
        }
    }

    private func loadData() {
        do {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([OrderEntry].self, from: data)
            orders = decoded
        } catch {
            print("Failed to load order entries: \(error)")
            orders = []
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // MARK: - Sample Data

    private func loadSampleData() {
        orders = [
            OrderEntry(
                id: UUID(),
                clientId: UUID(), // Replace with actual client ID in production
                orderDate: Date(),
                productType: "Visiting Card",
                size: "Standard 3.5x2 in",
                quantity: 500,
                unitCost: 1.2,
                totalCost: 600.0,
                deliveryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                urgencyLevel: "Normal",
                paymentStatus: "Paid",
                paymentMethod: "UPI",
                orderStatus: "In Progress",
                includesDesign: true,
                requiresInstallation: false,
                discountCode: "VCARD10",
                invoiceNumber: "INV-2024-001",
                deliveryAddress: "Shop No. 4, Sector 22 Market",
                notes: "Add QR on the back"
            ),
            OrderEntry(
                id: UUID(),
                clientId: UUID(),
                orderDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                productType: "Flex Banner",
                size: "6x3 ft",
                quantity: 2,
                unitCost: 350.0,
                totalCost: 700.0,
                deliveryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                urgencyLevel: "Urgent",
                paymentStatus: "Pending",
                paymentMethod: "Cash",
                orderStatus: "In Progress",
                includesDesign: false,
                requiresInstallation: true,
                discountCode: nil,
                invoiceNumber: "INV-2024-002",
                deliveryAddress: "Main Chowk, Model Town",
                notes: "Install by 11 AM sharp"
            )
        ]
    }
}
