import SwiftUI

// MARK: - Order Analytics Data Structure
struct OrderAnalytics {
    let totalOrders: Int
    let pendingOrders: Int
    let totalRevenue: Double
    let urgentOrders: Int
    
    static func fromOrders(_ orders: [OrderEntry]) -> OrderAnalytics {
        let pending = orders.filter { $0.orderStatus != "Delivered" && $0.orderStatus != "Completed" }.count
        let urgent = orders.filter { $0.urgencyLevel == "Urgent" || $0.urgencyLevel == "Same Day" }.count
        let revenue = orders.reduce(0) { $0 + $1.totalCost }
        
        return OrderAnalytics(
            totalOrders: orders.count,
            pendingOrders: pending,
            totalRevenue: revenue,
            urgentOrders: urgent
        )
    }
}

// MARK: - Order Entry List View
struct OrderEntryListView: View {
    @ObservedObject var manager: OrderEntryManager
    @State private var showAddEdit = false
    @State private var selectedOrder: OrderEntry? = nil
    @State private var showingContextMenu = false
    
    var analytics: OrderAnalytics {
        return OrderAnalytics.fromOrders(manager.orders)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Analysis Summary Section
                OrderAnalysisSummaryView(analytics: analytics)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                // Orders List
                List {
                    ForEach(manager.orders) { order in
                        Button(action: {
                            selectedOrder = order
                            showAddEdit = true
                        }) {
                            OrderCardView(order: order)
                                .padding(.vertical, 16) // Increased vertical spacing between cards
                                .contextMenu {
                                    Button(action: {
                                        if let index = manager.orders.firstIndex(where: { $0.id == order.id }) {
                                            manager.delete(at: IndexSet(integer: index))
                                        }
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)) // Increased row insets
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: manager.delete)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Orders")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedOrder = nil
                        showAddEdit = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#4A6FA5"))
                    }
                }
            }
            .sheet(isPresented: $showAddEdit) {
                OrderEntryAddEditView(manager: manager, orderToEdit: $selectedOrder)
            }
            .background(Color(hex: "#F8F9FA"))
        }
    }
}

// MARK: - Order Analysis Summary View
struct OrderAnalysisSummaryView: View {
    let analytics: OrderAnalytics
    
    var body: some View {
        VStack(spacing: 16) {
            
            HStack(spacing: 16) {
                // Total Orders Card
                OAnalysisCardView(
                    title: "Total Orders",
                    value: "\(analytics.totalOrders)",
                    icon: "cart.fill",
                    color: Color(hex: "#4A6FA5")
                )
                
                // Revenue Card
                OAnalysisCardView(
                    title: "Total Revenue",
                    value: "₹\(String(format: "%.2f", analytics.totalRevenue))",
                    icon: "indianrupeesign.circle.fill",
                    color: Color(hex: "#48BB78")
                )
            }
        }
    }
}

// MARK: - Analysis Card View
struct OAnalysisCardView: View {
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

// MARK: - Order Card View
struct OrderCardView: View {
    let order: OrderEntry
    
    // Premium color gradients based on urgency level
    var cardGradient: LinearGradient {
        switch order.urgencyLevel {
        case "Urgent":
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#FF416C"), Color(hex: "#FF4B2B")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "Same Day":
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#FEAC5E"), Color(hex: "#C779D0"), Color(hex: "#4BC0C8")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#0F2027"), Color(hex: "#203A43"), Color(hex: "#2C5364")]),
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
    
    // Status color with enhanced palette
    var statusColor: Color {
        switch order.orderStatus {
        case "Completed":
            return Color(hex: "#00B894")
        case "Delivered":
            return Color(hex: "#55EFC4")
        case "In Progress":
            return Color(hex: "#0984E3")
        default:
            return Color(hex: "#F39C12")
        }
    }
    
    // Payment status color
    var paymentColor: Color {
        return order.paymentStatus == "Paid" ? Color(hex: "#00B894") : Color(hex: "#F39C12")
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
                    // Premium product icon design
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 46, height: 46)
                        
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                            .frame(width: 46, height: 46)
                        
                        Image(systemName: productIcon(for: order.productType))
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(order.productType)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(order.size)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.leading, 4)
                    
                    Spacer()
                    
                    // Enhanced status badge
                    Text(order.orderStatus)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(statusColor.opacity(0.25))
                                .overlay(
                                    Capsule()
                                        .stroke(statusColor.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .foregroundColor(.white)
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
                            
                            Text("Qty: \(order.quantity)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        // Payment with elegant design
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 26, height: 26)
                                
                                Image(systemName: "indianrupeesign.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            
                            Text("₹\(order.totalCost, specifier: "%.2f")")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            // Enhanced payment badge
                            Text(order.paymentStatus)
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(paymentColor.opacity(0.25))
                                        .overlay(
                                            Capsule()
                                                .stroke(paymentColor.opacity(0.5), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.white)
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    // Right column
                    VStack(alignment: .trailing, spacing: 10) {
                        // Urgency level with elegant design
                        HStack(spacing: 10) {
                            Text(order.urgencyLevel)
                                .font(.system(size: 12, weight: .medium))
                            
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 26, height: 26)
                                
                                Image(systemName: urgencyIcon(for: order.urgencyLevel))
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Delivery date with elegant design
                        HStack(spacing: 10) {
                            Text(format(order.deliveryDate))
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
                
                // Enhanced feature tags and order date
                VStack(spacing: 12) {
                    // Feature tags in a more elegant layout
                    if order.includesDesign || order.requiresInstallation || (order.discountCode != nil && !order.discountCode!.isEmpty) {
                        HStack(spacing: 10) {
                            if order.includesDesign {
                                PremiumFeatureTag(text: "Design", icon: "paintbrush.fill")
                            }
                            
                            if order.requiresInstallation {
                                PremiumFeatureTag(text: "Installation", icon: "hammer.fill")
                            }
                            
                            if let discountCode = order.discountCode, !discountCode.isEmpty {
                                PremiumFeatureTag(text: "Discount", icon: "tag.fill")
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Elegant order date footer
                    HStack {
                        Spacer()
                        
                        Text("Ordered: \(format(order.orderDate))")
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
    
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    func productIcon(for productType: String) -> String {
        switch productType.lowercased() {
        case "visiting card":
            return "rectangle.stack.fill"
        case "flex":
            return "doc.richtext.fill"
        case "standee":
            return "rectangle.portrait.fill"
        default:
            return "doc.fill"
        }
    }
    
    func urgencyIcon(for urgencyLevel: String) -> String {
        switch urgencyLevel {
        case "Urgent":
            return "exclamationmark.triangle.fill"
        case "Same Day":
            return "timer"
        default:
            return "clock.fill"
        }
    }
}

// Premium Feature tag view for the footer section
struct PremiumFeatureTag: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 9))
            
            Text(text)
                .font(.system(size: 11, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
        .foregroundColor(.white)
    }
}
