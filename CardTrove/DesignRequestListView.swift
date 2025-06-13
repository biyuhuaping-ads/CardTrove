import SwiftUI

// MARK: - Design Request Analytics
struct DesignAnalytics {
    let totalRequests: Int
    let pendingApproval: Int
    let urgentRequests: Int
    let totalHours: Double
    
    static func fromRequests(_ requests: [DesignRequest]) -> DesignAnalytics {
        let pending = requests.filter { $0.approvalStatus == "Pending" }.count
        let urgent = requests.filter { $0.isUrgent }.count
        let hours = requests.reduce(0) { $0 + $1.estimatedDesignHours }
        
        return DesignAnalytics(
            totalRequests: requests.count,
            pendingApproval: pending,
            urgentRequests: urgent,
            totalHours: hours
        )
    }
}

// MARK: - Design Request List View
struct DesignRequestListView: View {
    @ObservedObject var manager: DesignRequestManager
    @State private var showAddEdit = false
    @State private var selectedRequest: DesignRequest? = nil
    
    var analytics: DesignAnalytics {
        return DesignAnalytics.fromRequests(manager.requests)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Analysis Summary Section
                DesignAnalysisSummaryView(analytics: analytics)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                // Design Requests List
                List {
                    ForEach(manager.requests) { request in
                        Button(action: {
                            selectedRequest = request
                            showAddEdit = true
                        }) {
                            DesignRequestCardView(request: request)
                                .padding(.vertical, 16)
                                .contextMenu {
                                    Button(action: {
                                        if let index = manager.requests.firstIndex(where: { $0.id == request.id }) {
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
            .navigationTitle("Design Requests")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedRequest = nil
                        showAddEdit = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#4A6FA5"))
                    }
                }
            }
            .sheet(isPresented: $showAddEdit) {
                DesignRequestAddEditView(manager: manager, requestToEdit: $selectedRequest)
            }
            .background(Color(hex: "#F8F9FA"))
        }
    }
}

// MARK: - Design Analysis Summary View
struct DesignAnalysisSummaryView: View {
    let analytics: DesignAnalytics
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Total Requests Card
                DAnalysisCardView(
                    title: "Total Requests",
                    value: "\(analytics.totalRequests)",
                    icon: "paintbrush.fill",
                    color: Color(hex: "#4A6FA5")
                )
                
                // Total Hours Card
                DAnalysisCardView(
                    title: "Design Hours",
                    value: "\(String(format: "%.1f", analytics.totalHours))",
                    icon: "clock.fill",
                    color: Color(hex: "#805AD5")
                )
            }
        }
    }
}

// MARK: - Analysis Card View
struct DAnalysisCardView: View {
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

// MARK: - Design Request Card View
struct DesignRequestCardView: View {
    let request: DesignRequest
    
    // Premium color gradients based on design stage and urgency
    var cardGradient: LinearGradient {
        if request.isUrgent {
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#FF416C"), Color(hex: "#FF4B2B")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        switch request.designStage {
        case "Draft":
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#4776E6"), Color(hex: "#8E54E9")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "Final":
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#0BA360"), Color(hex: "#3CBA92")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "Sent for Print":
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#2C3E50"), Color(hex: "#4CA1AF")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#FDC830"), Color(hex: "#F37335")]),
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
        switch request.approvalStatus {
        case "Approved":
            return Color(hex: "#00B894")
        case "Revision Needed":
            return Color(hex: "#F39C12")
        default:
            return Color(hex: "#0984E3")
        }
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
                    // Premium design icon
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 46, height: 46)
                        
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                            .frame(width: 46, height: 46)
                        
                        Image(systemName: deliveryFormatIcon(for: request.deliveryFormat))
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(request.textContent)
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        
                        Text(request.colorTheme)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.leading, 4)
                    
                    Spacer()
                    
                    // Enhanced status badge for urgent requests
                    if request.isUrgent {
                        Text("Urgent")
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
                        // Font preference with elegant design
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 26, height: 26)
                                
                                Image(systemName: "textformat")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            
                            Text(request.fontPreference)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        // Delivery format with elegant design
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 26, height: 26)
                                
                                Image(systemName: "square.and.arrow.down.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            
                            Text(request.deliveryFormat)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    // Right column
                    VStack(alignment: .trailing, spacing: 10) {
                        // Approval status with elegant design
                        HStack(spacing: 10) {
                            Text(request.approvalStatus)
                                .font(.system(size: 12, weight: .medium))
                            
                            ZStack {
                                Circle()
                                    .fill(statusColor.opacity(0.2))
                                    .frame(width: 26, height: 26)
                                
                                Image(systemName: approvalStatusIcon(for: request.approvalStatus))
                                    .font(.caption)
                                    .foregroundColor(statusColor)
                            }
                        }
                        
                        // Design stage with elegant design
                        HStack(spacing: 10) {
                            Text(request.designStage)
                                .font(.system(size: 12, weight: .medium))
                            
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 26, height: 26)
                                
                                Image(systemName: designStageIcon(for: request.designStage))
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
                        if let dimensions = request.requestedDimensions {
                            PremiumFeatureTag(text: dimensions, icon: "ruler.fill")
                        }
                        
                        if request.requiresMultipleVersions {
                            PremiumFeatureTag(text: "Multiple Versions", icon: "square.stack.fill")
                        }
                        
                        if let designer = request.assignedDesigner {
                            PremiumFeatureTag(text: designer, icon: "person.fill")
                        }
                        
                        Spacer()
                    }
                    
                    // Request date and estimated hours
                    HStack {
                        Spacer()
                        
                        Text("\(formatDate(request.requestDate)) • \(String(format: "%.1f", request.estimatedDesignHours))h")
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
    
    func deliveryFormatIcon(for format: String) -> String {
        switch format.uppercased() {
        case "JPEG", "JPG":
            return "photo.fill"
        case "PDF":
            return "doc.fill"
        case "AI":
            return "pencil.and.outline"
        default:
            return "doc.richtext.fill"
        }
    }
    
    func approvalStatusIcon(for status: String) -> String {
        switch status {
        case "Approved":
            return "checkmark.circle.fill"
        case "Revision Needed":
            return "arrow.triangle.2.circlepath"
        default:
            return "hourglass"
        }
    }
    
    func designStageIcon(for stage: String) -> String {
        switch stage {
        case "Draft":
            return "pencil"
        case "Final":
            return "checkmark.seal.fill"
        case "Sent for Print":
            return "printer.fill"
        default:
            return "square.and.pencil"
        }
    }
}
