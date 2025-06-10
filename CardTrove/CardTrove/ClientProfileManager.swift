import Foundation

class ClientProfileManager: ObservableObject {
    @Published private(set) var profiles: [ClientProfile] {
        didSet {
            saveData()
        }
    }

    private let fileName = "clientProfiles.json"

    init() {
        self.profiles = []
        loadData()
        if profiles.isEmpty {
            loadSampleData()
        }
    }

    // MARK: - CRUD

    func add(_ profile: ClientProfile) {
        profiles.append(profile)
    }

    func update(_ profile: ClientProfile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
        }
    }

    func delete(at offsets: IndexSet) {
        profiles.remove(atOffsets: offsets)
    }

    // MARK: - Persistence

    private func saveData() {
        do {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            let data = try JSONEncoder().encode(profiles)
            try data.write(to: url)
        } catch {
            print("Failed to save client profiles: \(error)")
        }
    }

    private func loadData() {
        do {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([ClientProfile].self, from: data)
            profiles = decoded
        } catch {
            print("Failed to load client profiles: \(error)")
            profiles = []
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // MARK: - Sample Data

    private func loadSampleData() {
        profiles = [
            ClientProfile(
                id: UUID(),
                businessName: "Elegant Touch Salon",
                contactPerson: "Priya Sharma",
                phoneNumber: "9876543210",
                email: "contact@elegantsalon.in",
                address: "Sector 17, Chandigarh",
                logoReference: "elegant_logo",
                industryType: "Salon",
                repeatClient: true,
                preferredDesignStyle: "Minimal",
                lastOrderDate: Calendar.current.date(byAdding: .day, value: -12, to: Date()),
                gstNumber: "27AAACB1234F1Z2",
                socialMediaHandle: "@eleganttouchsalon",
                communicationPreference: "WhatsApp",
                totalOrdersPlaced: 5,
                feedbackRating: 4,
                specialInstructions: "Prefer soft pastel tones",
                tags: ["Salon", "Luxury", "Regular"]
            ),
            ClientProfile(
                id: UUID(),
                businessName: "TechWave Innovations",
                contactPerson: "Rahul Mehta",
                phoneNumber: "9988776655",
                email: "info@techwave.io",
                address: "Koramangala, Bengaluru",
                logoReference: nil,
                industryType: "Tech",
                repeatClient: false,
                preferredDesignStyle: "Bold",
                lastOrderDate: nil,
                gstNumber: nil,
                socialMediaHandle: "@techwaveio",
                communicationPreference: "Email",
                totalOrdersPlaced: 1,
                feedbackRating: nil,
                specialInstructions: "Use futuristic fonts and gradients",
                tags: ["Tech", "Startup"]
            )
        ]
    }
}
