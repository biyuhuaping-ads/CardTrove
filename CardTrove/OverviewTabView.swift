import SwiftUI

// MARK: - Business Analytics
struct BusinessAnalytics {
    let totalClients: Int
    let totalOrders: Int
    let totalRevenue: Double
    let pendingPayments: Int
    
    static func fromManagers(clientManager: ClientProfileManager, orderManager: OrderEntryManager) -> BusinessAnalytics {
        let pendingPayments = orderManager.orders.filter { $0.paymentStatus == "Pending" }.count
        let totalRevenue = orderManager.orders.reduce(0) { $0 + $1.totalCost }
        
        return BusinessAnalytics(
            totalClients: clientManager.profiles.count,
            totalOrders: orderManager.orders.count,
            totalRevenue: totalRevenue,
            pendingPayments: pendingPayments
        )
    }
}

// MARK: - Overview Tab View
struct OverviewTabView: View {
    @ObservedObject var clientManager: ClientProfileManager
    @ObservedObject var orderManager: OrderEntryManager
    @ObservedObject var materialManager: MaterialStockManager
    @ObservedObject var designManager: DesignRequestManager
    
    var analytics: BusinessAnalytics {
        return BusinessAnalytics.fromManagers(clientManager: clientManager, orderManager: orderManager)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Business Analytics Section
                BusinessAnalysisSummaryView(analytics: analytics)
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                
                // Category Cards Section
                VStack(spacing: 20) {
                    // Clients Card
                    EnhancedSummaryCard(
                        title: "Client Overview",
                        icon: "person.crop.rectangle.fill",
                        gradient: [Color(hex: "#4776E6"), Color(hex: "#8E54E9")],
                        metrics: [
                            MetricItem(
                                title: "Total Clients",
                                value: "\(clientManager.profiles.count)",
                                icon: "person.3.fill",
                                color: Color(hex: "#4A6FA5")
                            ),
                            MetricItem(
                                title: "Repeat Clients",
                                value: "\(clientManager.profiles.filter { $0.repeatClient }.count)",
                                icon: "arrow.triangle.2.circlepath",
                                color: Color(hex: "#48BB78")
                            )
                        ]
                    )
                    
                    // Orders Card
                    EnhancedSummaryCard(
                        title: "Order Summary",
                        icon: "cart.fill",
                        gradient: [Color(hex: "#0F2027"), Color(hex: "#203A43"), Color(hex: "#2C5364")],
                        metrics: [
                            MetricItem(
                                title: "Total Orders",
                                value: "\(orderManager.orders.count)",
                                icon: "doc.richtext.fill",
                                color: Color(hex: "#4A6FA5")
                            ),
                            MetricItem(
                                title: "Pending Payments",
                                value: "\(orderManager.orders.filter { $0.paymentStatus == "Pending" }.count)",
                                icon: "indianrupeesign.circle.fill",
                                color: Color(hex: "#F39C12")
                            )
                        ]
                    )
                    
                    // Materials Card
                    EnhancedSummaryCard(
                        title: "Material Status",
                        icon: "shippingbox.fill",
                        gradient: [Color(hex: "#0BA360"), Color(hex: "#3CBA92")],
                        metrics: [
                            MetricItem(
                                title: "Total Items",
                                value: "\(materialManager.materials.count)",
                                icon: "cube.box.fill",
                                color: Color(hex: "#4A6FA5")
                            ),
                            MetricItem(
                                title: "Low Stock Items",
                                value: "\(materialManager.materials.filter { $0.quantity <= $0.reorderLevel }.count)",
                                icon: "exclamationmark.triangle.fill",
                                color: Color(hex: "#E53E3E")
                            )
                        ]
                    )
                    
                    // Design Card
                    EnhancedSummaryCard(
                        title: "Design Requests",
                        icon: "pencil.and.outline",
                        gradient: [Color(hex: "#FF416C"), Color(hex: "#FF4B2B")],
                        metrics: [
                            MetricItem(
                                title: "Total Requests",
                                value: "\(designManager.requests.count)",
                                icon: "paintbrush.fill",
                                color: Color(hex: "#4A6FA5")
                            ),
                            MetricItem(
                                title: "Urgent Requests",
                                value: "\(designManager.requests.filter { $0.isUrgent }.count)",
                                icon: "exclamationmark.circle.fill",
                                color: Color(hex: "#E53E3E")
                            )
                        ]
                    )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(hex: "#F8F9FA"))
        .navigationTitle("Business Overview")
    }
    
    private func averageRating() -> Double {
        let ratings = clientManager.profiles.compactMap { $0.feedbackRating }
        guard !ratings.isEmpty else { return 0.0 }
        let total = ratings.reduce(0, +)
        return Double(total) / Double(ratings.count)
    }
}

// MARK: - Business Analysis Summary View
struct BusinessAnalysisSummaryView: View {
    let analytics: BusinessAnalytics
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Business Performance")
                .font(.headline)
                .foregroundColor(Color(hex: "#2D3748"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            
            HStack(spacing: 16) {
                // Total Clients Card
                AnalysisCardView(
                    title: "Total Clients",
                    value: "\(analytics.totalClients)",
                    icon: "person.3.fill",
                    color: Color(hex: "#4A6FA5")
                )
                
                // Revenue Card
                AnalysisCardView(
                    title: "Total Revenue",
                    value: "₹\(String(format: "%.2f", analytics.totalRevenue))",
                    icon: "indianrupeesign.circle.fill",
                    color: Color(hex: "#48BB78")
                )
            }
        }
    }
}


// MARK: - Metric Item Data Structure
struct MetricItem {
    let title: String
    let value: String
    let icon: String
    let color: Color
}

// MARK: - Enhanced Summary Card
struct EnhancedSummaryCard: View {
    let title: String
    let icon: String
    let gradient: [Color]
    let metrics: [MetricItem]
    
    // Glass effect background overlay
    var glassOverlay: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color.white.opacity(0.12))
            .blur(radius: 0.5)
    }
    
    var body: some View {
        ZStack {
            // Fancy background
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(gradient: Gradient(colors: gradient), startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(glassOverlay)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            
            // Content
            VStack(alignment: .leading, spacing: 15) {
                // Header with icon
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 42, height: 42)
                        
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                            .frame(width: 42, height: 42)
                        
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.7))
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
                    .padding(.vertical, 2)
                
                // Metrics
                VStack(spacing: 12) {
                    ForEach(0..<metrics.count, id: \.self) { index in
                        let metric = metrics[index]
                        
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(metric.color.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: metric.icon)
                                    .font(.caption)
                                    .foregroundColor(metric.color)
                            }
                            
                            Text(metric.title)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                            
                            Text(metric.value)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        if index < metrics.count - 1 {
                            Divider()
                                .background(Color.white.opacity(0.3))
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
    }
}
