import Foundation

class DesignRequestManager: ObservableObject {
    @Published private(set) var requests: [DesignRequest] {
        didSet {
            saveData()
        }
    }

    private let fileName = "designRequests.json"

    init() {
        self.requests = []
        loadData()
        if requests.isEmpty {
            loadSampleData()
        }
    }

    // MARK: - CRUD Operations

    func add(_ request: DesignRequest) {
        requests.append(request)
    }

    func update(_ request: DesignRequest) {
        if let index = requests.firstIndex(where: { $0.id == request.id }) {
            requests[index] = request
        }
    }

    func delete(at offsets: IndexSet) {
        requests.remove(atOffsets: offsets)
    }

    // MARK: - Persistence

    private func saveData() {
        do {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            let data = try JSONEncoder().encode(requests)
            try data.write(to: url)
        } catch {
            print("Failed to save design requests: \(error)")
        }
    }

    private func loadData() {
        do {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([DesignRequest].self, from: data)
            requests = decoded
        } catch {
            print("Failed to load design requests: \(error)")
            requests = []
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // MARK: - Sample Data

    private func loadSampleData() {
        requests = [
            DesignRequest(
                id: UUID(),
                clientId: UUID(), // Replace with real client ID
                requestDate: Date(),
                textContent: "Elegant Beauty Salon | Call Us Today",
                fontPreference: "Playfair Display",
                colorTheme: "Soft Pink & Gold",
                referenceFile: "beauty_banner_sketch.png",
                approvalStatus: "Pending",
                designStage: "Draft",
                isUrgent: true,
                assignedDesigner: "Riya",
                requestedDimensions: "3x2 ft",
                deliveryFormat: "PDF",
                requiresMultipleVersions: true,
                estimatedDesignHours: 4.5,
                notes: "Client wants vintage floral elements."
            ),
            DesignRequest(
                id: UUID(),
                clientId: UUID(),
                requestDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                textContent: "TechWave Innovations | Smart IT Solutions",
                fontPreference: "Roboto Bold",
                colorTheme: "Blue Gradient",
                referenceFile: nil,
                approvalStatus: "Approved",
                designStage: "Final",
                isUrgent: false,
                assignedDesigner: "Karan",
                requestedDimensions: "A5",
                deliveryFormat: "AI",
                requiresMultipleVersions: false,
                estimatedDesignHours: 2.0,
                notes: "Minimal layout with QR code on the back."
            )
        ]
    }
}
