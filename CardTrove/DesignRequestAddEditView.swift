import SwiftUI

struct DesignRequestAddEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var manager: DesignRequestManager
    @Binding var requestToEdit: DesignRequest?

    @State private var textContent = ""
    @State private var fontPreference = "Roboto"
    @State private var colorTheme = "Blue"
    @State private var approvalStatus = "Pending"
    @State private var designStage = "Draft"
    @State private var isUrgent = false
    @State private var assignedDesigner = ""
    @State private var requestedDimensions = ""
    @State private var deliveryFormat = "PDF"
    @State private var requiresMultipleVersions = false
    @State private var estimatedDesignHours = ""
    @State private var notes = ""
    @State private var showAlert = false

    let statusOptions = ["Pending", "Approved", "Revision Needed"]
    let stageOptions = ["Draft", "Final", "Sent for Print"]
    let formatOptions = ["JPEG", "PDF", "AI"]
    let fonts = ["Roboto", "Playfair Display", "Montserrat", "Lato"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Content")) {
                    TextField("Text Content", text: $textContent)
                    Picker("Font", selection: $fontPreference) {
                        ForEach(fonts, id: \.self) { Text($0) }
                    }
                    TextField("Color Theme", text: $colorTheme)
                }

                Section(header: Text("Details")) {
                    Picker("Approval Status", selection: $approvalStatus) {
                        ForEach(statusOptions, id: \.self) { Text($0) }
                    }
                    Picker("Design Stage", selection: $designStage) {
                        ForEach(stageOptions, id: \.self) { Text($0) }
                    }
                    Picker("Delivery Format", selection: $deliveryFormat) {
                        ForEach(formatOptions, id: \.self) { Text($0) }
                    }
                    TextField("Estimated Hours", text: $estimatedDesignHours).keyboardType(.decimalPad)
                    Toggle("Urgent?", isOn: $isUrgent)
                    Toggle("Multiple Versions", isOn: $requiresMultipleVersions)
                }

                Section(header: Text("Extras")) {
                    TextField("Assigned Designer", text: $assignedDesigner)
                    TextField("Requested Dimensions", text: $requestedDimensions)
                    TextEditor(text: $notes).frame(height: 60)
                }
            }
            .navigationTitle(requestToEdit == nil ? "Add Request" : "Edit Request")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveData)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
            }
            .onAppear(perform: populateData)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Missing Info"), message: Text("Please enter required fields."), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func saveData() {
        guard !textContent.isEmpty, let hours = Double(estimatedDesignHours) else {
            showAlert = true
            return
        }

        let newRequest = DesignRequest(
            id: requestToEdit?.id ?? UUID(),
            clientId: UUID(), // Replace with actual client link if needed
            requestDate: Date(),
            textContent: textContent,
            fontPreference: fontPreference,
            colorTheme: colorTheme,
            referenceFile: nil,
            approvalStatus: approvalStatus,
            designStage: designStage,
            isUrgent: isUrgent,
            assignedDesigner: assignedDesigner,
            requestedDimensions: requestedDimensions,
            deliveryFormat: deliveryFormat,
            requiresMultipleVersions: requiresMultipleVersions,
            estimatedDesignHours: hours,
            notes: notes.isEmpty ? nil : notes
        )

        if requestToEdit == nil {
            manager.add(newRequest)
        } else {
            manager.update(newRequest)
        }

        presentationMode.wrappedValue.dismiss()
    }

    private func populateData() {
        guard let request = requestToEdit else { return }
        textContent = request.textContent
        fontPreference = request.fontPreference
        colorTheme = request.colorTheme
        approvalStatus = request.approvalStatus
        designStage = request.designStage
        isUrgent = request.isUrgent
        assignedDesigner = request.assignedDesigner ?? ""
        requestedDimensions = request.requestedDimensions ?? ""
        deliveryFormat = request.deliveryFormat
        requiresMultipleVersions = request.requiresMultipleVersions
        estimatedDesignHours = String(request.estimatedDesignHours)
        notes = request.notes ?? ""
    }
}
