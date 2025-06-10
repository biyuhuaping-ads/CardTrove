import SwiftUI

// MARK: - Analysis Data Structure
struct ClientAnalytics {
    let totalClients: Int
    let repeatClients: Int
    let averageRating: Double
    
    static func fromProfiles(_ profiles: [ClientProfile]) -> ClientAnalytics {
        let repeatCount = profiles.filter { $0.repeatClient }.count
        let ratedProfiles = profiles.compactMap { $0.feedbackRating }
        let avgRating = ratedProfiles.isEmpty ? 0 : Double(ratedProfiles.reduce(0, +)) / Double(ratedProfiles.count)
        
        return ClientAnalytics(
            totalClients: profiles.count,
            repeatClients: repeatCount,
            averageRating: avgRating
        )
    }
}

// MARK: - Client Profile List View
struct ClientProfileListView: View {
    @ObservedObject var manager: ClientProfileManager
    @State private var showAddEdit = false
    @State private var selectedProfile: ClientProfile? = nil
    
    var analytics: ClientAnalytics {
        return ClientAnalytics.fromProfiles(manager.profiles)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Analysis Summary Section
                AnalysisSummaryView(analytics: analytics)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                // Clients List
                List {
                    ForEach(manager.profiles) { profile in
                        Button(action: {
                            selectedProfile = profile
                            showAddEdit = true
                        }) {
                            ClientCardView(profile: profile)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: manager.delete)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Client Profiles")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedProfile = nil
                        showAddEdit = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#4A6FA5"))
                    }
                }
            }
            .sheet(isPresented: $showAddEdit) {
                ClientProfileAddEditView(manager: manager, profileToEdit: $selectedProfile)
            }
            .background(Color(hex: "#F8F9FA"))
        }
    }
}

// MARK: - Analysis Summary View
struct AnalysisSummaryView: View {
    let analytics: ClientAnalytics
    
    var body: some View {
        VStack(spacing: 16) {
            
            HStack(spacing: 16) {
                // Total Clients Card
                AnalysisCardView(
                    title: "Total Clients",
                    value: "\(analytics.totalClients)",
                    icon: "person.3.fill",
                    color: Color(hex: "#4A6FA5")
                )
                
                // Repeat Clients Card
                AnalysisCardView(
                    title: "Repeat Clients",
                    value: "\(analytics.repeatClients)",
                    icon: "arrow.triangle.2.circlepath",
                    color: Color(hex: "#48BB78")
                )
            }
        }
    }
}

struct AnalysisCardView: View {
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

// MARK: - Client Card View
struct ClientCardView: View {
    let profile: ClientProfile
    
    // Determine card color based on industry type
    var cardGradient: LinearGradient {
        switch profile.industryType.lowercased() {
        case "salon":
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#FF9A9E"), Color(hex: "#FAD0C4")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "tech":
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#84FAB0"), Color(hex: "#8FD3F4")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "real estate":
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#A6C0FE"), Color(hex: "#F68084")]),
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Section
            HStack(alignment: .top) {
                // Logo Placeholder
                Image(systemName: "building.2.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.businessName)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(profile.industryType)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                if profile.repeatClient {
                    Text("Repeat")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(6)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // Details Section
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person.fill")
                            .frame(width: 16)
                        Text(profile.contactPerson)
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .frame(width: 16)
                        Text(profile.phoneNumber)
                            .font(.subheadline)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    if let lastOrder = profile.lastOrderDate {
                        HStack {
                            Text(DateFormatter.shortDate.string(from: lastOrder))
                                .font(.caption)
                            Image(systemName: "calendar")
                                .frame(width: 16)
                        }
                    }
                    
                    if let rating = profile.feedbackRating {
                        HStack {
                            Text("\(rating)/5")
                                .font(.caption)
                            HStack(spacing: 1) {
                                ForEach(1...5, id: \.self) { i in
                                    Image(systemName: i <= rating ? "star.fill" : "star")
                                        .font(.system(size: 8))
                                        .foregroundColor(i <= rating ? Color.yellow : Color.white.opacity(0.5))
                                }
                            }
                        }
                    }
                }
            }
            
            // Footer with tags
            if let tags = profile.tags, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding()
        .background(cardGradient)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
