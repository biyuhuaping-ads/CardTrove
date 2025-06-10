import SwiftUI

// MARK: - ClientProfile
struct ClientProfile: Identifiable, Codable {
    var id: UUID
    var businessName: String
    var contactPerson: String
    var phoneNumber: String
    var email: String?
    var address: String?
    var logoReference: String?                // Local image name or asset ID
    var industryType: String                  // "Salon", "Tech", "Real Estate"
    var repeatClient: Bool
    var preferredDesignStyle: String          // "Minimal", "Bold", "Elegant"
    var lastOrderDate: Date?
    var gstNumber: String?                    // For invoice generation
    var socialMediaHandle: String?            // For design reference
    var communicationPreference: String       // "WhatsApp", "Call", "Email"
    var totalOrdersPlaced: Int
    var feedbackRating: Int?                  // Out of 5
    var specialInstructions: String?
    var tags: [String]?
}

// MARK: - OrderEntry
struct OrderEntry: Identifiable, Codable {
    var id: UUID
    var clientId: UUID
    var orderDate: Date
    var productType: String                   // "Visiting Card", "Flex", "Standee"
    var size: String
    var quantity: Int
    var unitCost: Double
    var totalCost: Double
    var deliveryDate: Date
    var urgencyLevel: String                  // "Normal", "Urgent", "Same Day"
    var paymentStatus: String                 // "Paid", "Pending"
    var paymentMethod: String                 // "Cash", "UPI", "Card"
    var orderStatus: String                   // "In Progress", "Completed", "Delivered"
    var includesDesign: Bool
    var requiresInstallation: Bool
    var discountCode: String?
    var invoiceNumber: String?
    var deliveryAddress: String?
    var notes: String?
}

// MARK: - MaterialStock
struct MaterialStock: Identifiable, Codable {
    var id: UUID
    var materialName: String
    var category: String                      // "Ink", "Card Paper", "Banner Roll"
    var quantity: Int
    var unitType: String                      // "Sheets", "Liters", "Rolls"
    var reorderLevel: Int
    var supplier: String
    var costPerUnit: Double
    var lastRestocked: Date
    var expirationDate: Date?
    var storageLocation: String
    var isCritical: Bool
    var lastUsedDate: Date?
    var damageReported: Bool
    var barcode: String?
    var purchaseReference: String?
    var qualityRating: Int?                   // 1–5 score
    var notes: String?
}

// MARK: - DesignRequest
struct DesignRequest: Identifiable, Codable {
    var id: UUID
    var clientId: UUID
    var requestDate: Date
    var textContent: String
    var fontPreference: String
    var colorTheme: String
    var referenceFile: String?                // Optional sketch/image
    var approvalStatus: String                // "Pending", "Approved", "Revision Needed"
    var designStage: String                   // "Draft", "Final", "Sent for Print"
    var isUrgent: Bool
    var assignedDesigner: String?
    var requestedDimensions: String?
    var deliveryFormat: String                // "JPEG", "PDF", "AI"
    var requiresMultipleVersions: Bool
    var estimatedDesignHours: Double
    var notes: String?
}


// Extension for hex color support (iOS 14 compatible)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
