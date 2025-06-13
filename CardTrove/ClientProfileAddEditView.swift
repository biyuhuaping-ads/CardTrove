import SwiftUI

struct ClientProfileAddEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var manager: ClientProfileManager
    @Binding var profileToEdit: ClientProfile?

    @State private var businessName = ""
    @State private var contactPerson = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var address = ""
    @State private var logoReference = ""
    @State private var industryType = "Salon"
    @State private var preferredDesignStyle = "Minimal"
    @State private var communicationPreference = "WhatsApp"
    @State private var gstNumber = ""
    @State private var socialMediaHandle = ""
    @State private var specialInstructions = ""
    @State private var tagsText = ""
    @State private var totalOrdersPlaced = ""
    @State private var feedbackRating = ""
    @State private var repeatClient = false
    @State private var showAlert = false

    let designStyles = ["Minimal", "Bold", "Elegant", "Classic"]
    let industryTypes = ["Salon", "Tech", "Real Estate", "Retail", "Food"]
    let communicationOptions = ["WhatsApp", "Call", "Email"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Business Info")) {
                    TextField("Business Name", text: $businessName)
                    TextField("Contact Person", text: $contactPerson)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Address", text: $address)
                }

                Section(header: Text("Design Preferences")) {
                    Picker("Industry Type", selection: $industryType) {
                        ForEach(industryTypes, id: \.self) { Text($0) }
                    }
                    Picker("Design Style", selection: $preferredDesignStyle) {
                        ForEach(designStyles, id: \.self) { Text($0) }
                    }
                    Picker("Preferred Contact", selection: $communicationPreference) {
                        ForEach(communicationOptions, id: \.self) { Text($0) }
                    }
                    Toggle("Repeat Client", isOn: $repeatClient)
                }

                Section(header: Text("Extras")) {
                    TextField("GST Number", text: $gstNumber)
                    TextField("Social Media Handle", text: $socialMediaHandle)
                    TextField("Logo Reference", text: $logoReference)
                    TextEditor(text: $specialInstructions)
                        .frame(height: 60)
                    TextField("Tags (comma separated)", text: $tagsText)
                }

                Section(header: Text("Tracking")) {
                    TextField("Total Orders", text: $totalOrdersPlaced)
                        .keyboardType(.numberPad)
                    TextField("Rating (Optional)", text: $feedbackRating)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle(profileToEdit == nil ? "Add Client" : "Edit Client")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveData)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear(perform: populateData)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Missing Info"), message: Text("Business name and phone number are required."), dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: - Functions

    private func saveData() {
        guard !businessName.trimmingCharacters(in: .whitespaces).isEmpty,
              !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert = true
            return
        }

        let profile = ClientProfile(
            id: profileToEdit?.id ?? UUID(),
            businessName: businessName,
            contactPerson: contactPerson,
            phoneNumber: phoneNumber,
            email: email.isEmpty ? nil : email,
            address: address.isEmpty ? nil : address,
            logoReference: logoReference.isEmpty ? nil : logoReference,
            industryType: industryType,
            repeatClient: repeatClient,
            preferredDesignStyle: preferredDesignStyle,
            lastOrderDate: Date(),
            gstNumber: gstNumber.isEmpty ? nil : gstNumber,
            socialMediaHandle: socialMediaHandle.isEmpty ? nil : socialMediaHandle,
            communicationPreference: communicationPreference,
            totalOrdersPlaced: Int(totalOrdersPlaced) ?? 0,
            feedbackRating: Int(feedbackRating),
            specialInstructions: specialInstructions.isEmpty ? nil : specialInstructions,
            tags: tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        )

        if profileToEdit == nil {
            manager.add(profile)
        } else {
            manager.update(profile)
        }

        presentationMode.wrappedValue.dismiss()
    }

    private func populateData() {
        guard let profile = profileToEdit else { return }
        businessName = profile.businessName
        contactPerson = profile.contactPerson
        phoneNumber = profile.phoneNumber
        email = profile.email ?? ""
        address = profile.address ?? ""
        logoReference = profile.logoReference ?? ""
        industryType = profile.industryType
        preferredDesignStyle = profile.preferredDesignStyle
        communicationPreference = profile.communicationPreference
        repeatClient = profile.repeatClient
        gstNumber = profile.gstNumber ?? ""
        socialMediaHandle = profile.socialMediaHandle ?? ""
        specialInstructions = profile.specialInstructions ?? ""
        tagsText = profile.tags?.joined(separator: ", ") ?? ""
        totalOrdersPlaced = String(profile.totalOrdersPlaced)
        feedbackRating = profile.feedbackRating.map { String($0) } ?? ""
    }
}
