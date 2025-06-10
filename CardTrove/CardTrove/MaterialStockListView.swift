import SwiftUI

// MARK: - Material Stock Analytics
struct MaterialAnalytics {
    let totalItems: Int
    let totalValue: Double
    let criticalItems: Int
    
    static func fromMaterials(_ materials: [MaterialStock]) -> MaterialAnalytics {
        let critical = materials.filter { $0.isCritical }.count
        let totalValue = materials.reduce(0) { $0 + ($1.costPerUnit * Double($1.quantity)) }
        
        return MaterialAnalytics(
            totalItems: materials.count,
            totalValue: totalValue,
            criticalItems: critical
        )
    }
}

// MARK: - Material Stock List View
struct MaterialStockListView: View {
    @ObservedObject var manager: MaterialStockManager
    @State private var showAddEdit = false
    @State private var selectedItem: MaterialStock? = nil
    
    var analytics: MaterialAnalytics {
        return MaterialAnalytics.fromMaterials(manager.materials)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Analysis Summary Section
                MaterialAnalysisSummaryView(analytics: analytics)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                // Materials List
                List {
                    ForEach(manager.materials) { item in
                        Button(action: {
                            selectedItem = item
                            showAddEdit = true
                        }) {
                            MaterialStockCardView(item: item)
                                .padding(.vertical, 16)
                                .contextMenu {
                                    Button(action: {
                                        if let index = manager.materials.firstIndex(where: { $0.id == item.id }) {
                                            manager.delete(at: IndexSet(integer: index))
                                        }
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: manager.delete)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Material Stock")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedItem = nil
                        showAddEdit = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#4A6FA5"))
                    }
                }
            }
            .sheet(isPresented: $showAddEdit) {
                MaterialStockAddEditView(manager: manager, itemToEdit: $selectedItem)
            }
            .background(Color(hex: "#F8F9FA"))
        }
    }
}

// MARK: - Material Analysis Summary View
struct MaterialAnalysisSummaryView: View {
    let analytics: MaterialAnalytics
    
    var body: some View {
        VStack(spacing: 16) {
            
            HStack(spacing: 16) {
                // Total Items Card
                MAnalysisCardView(
                    title: "Total Materials",
                    value: "\(analytics.totalItems)",
                    icon: "cube.fill",
                    color: Color(hex: "#4A6FA5")
                )
                
                // Total Value Card
                MAnalysisCardView(
                    title: "Inventory Value",
                    value: "₹\(String(format: "%.2f", analytics.totalValue))",
                    icon: "indianrupeesign.circle.fill",
                    color: Color(hex: "#48BB78")
                )
            }
        }
    }
}

// MARK: - Analysis Card View
struct MAnalysisCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color(hex: "#4A5568"))
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#2D3748"))
            }
            
            Spacer()
            
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(color)
                .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Material Stock Card View
struct MaterialStockCardView: View {
    let item: MaterialStock
    
    // Premium color gradients based on category and status
    var cardGradient: LinearGradient {
        if item.isCritical {
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#FF416C"), Color(hex: "#FF4B2B")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        switch item.category.lowercased() {
        case "ink":
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#667EEA"), Color(hex: "#764BA2")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "card paper":
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#0F2027"), Color(hex: "#203A43"), Color(hex: "#2C5364")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "banner roll":
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#0BA360"), Color(hex: "#3CBA92")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#4A6FA5"), Color(hex: "#6B8CCE")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // Glass effect background overlay
    var glassOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.12))
            .blur(radius: 0.5)
    }
    
    // Stock level indicator color
    var stockLevelColor: Color {
        return item.quantity <= item.reorderLevel ? Color(hex: "#F39C12") : Color(hex: "#00B894")
    }
    
    var body: some View {
        ZStack {
            // Fancy background
            RoundedRectangle(cornerRadius: 18)
                .fill(cardGradient)
                .overlay(glassOverlay)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            
            // Main content
            VStack(alignment: .leading, spacing: 14) {
                // Header Section with enhanced styling
                HStack(alignment: .top) {
                    // Premium category icon design
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 46, height: 46)
                        
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                            .frame(width: 46, height: 46)
                        
                        Image(systemName: categoryIcon(for: item.category))
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.materialName)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(item.category)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.leading, 4)
                    
                    Spacer()
                    
                    // Status badge for critical items
                    if item.isCritical {
                        Text("Critical")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "#FF4B2B").opacity(0.25))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(hex: "#FF4B2B").opacity(0.5), lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.white)
                    }
                }
                
                // Elegant divider with glow effect
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.white.opacity(0), .white.opacity(0.5), .white.opacity(0)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .padding(.vertical, 4)
                
                // Middle Section with enhanced styling
                HStack(spacing: 0) {
                    // Left column
                    VStack(alignment: .leading, spacing: 10) {
                        // Quantity with elegant design
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 26, height: 26)
                                
                                Image(systemName: "number")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            
                            HStack(spacing: 4) {
                                Text("Stock: \(item.quantity)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(item.unitType)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        // Supplier with elegant design
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 26, height: 26)
                                
                                Image(systemName: "building.2.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            
                            Text(item.supplier)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    // Right column
                    VStack(alignment: .trailing, spacing: 10) {
                        // Reorder level with elegant design
                        HStack(spacing: 10) {
                            Text("Reorder at: \(item.reorderLevel)")
                                .font(.system(size: 12, weight: .medium))
                            
                            ZStack {
                                Circle()
                                    .fill(stockLevelColor.opacity(0.2))
                                    .frame(width: 26, height: 26)
                                
                                Image(systemName: item.quantity <= item.reorderLevel ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(stockLevelColor)
                            }
                        }
                        
                        // Last restocked date with elegant design
                        HStack(spacing: 10) {
                            Text(formatDate(item.lastRestocked))
                                .font(.system(size: 12, weight: .medium))
                            
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 26, height: 26)
                                
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                }
                
                // Enhanced feature tags and additional info
                VStack(spacing: 12) {
                    // Feature tags in a more elegant layout
                    HStack(spacing: 10) {
                        // Storage location
                        PremiumFeatureTag(text: "Location: \(item.storageLocation)", icon: "mappin.circle.fill")
                        
                        if item.damageReported {
                            PremiumFeatureTag(text: "Damaged", icon: "exclamationmark.octagon.fill")
                        }
                        
                        if let rating = item.qualityRating {
                            PremiumFeatureTag(text: "Quality: \(rating)/5", icon: "star.fill")
                        }
                        
                        Spacer()
                    }
                    
                    // Cost information
                    HStack {
                        Spacer()
                        
                        Text("Cost: ₹\(String(format: "%.2f", item.costPerUnit)) per \(item.unitType)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220) // Fixed height for consistency
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "ink":
            return "drop.fill"
        case "card paper":
            return "doc.fill"
        case "banner roll":
            return "scroll.fill"
        default:
            return "shippingbox.fill"
        }
    }
}
