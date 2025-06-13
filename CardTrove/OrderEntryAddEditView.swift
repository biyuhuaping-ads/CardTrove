import SwiftUI

struct OrderEntryAddEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var manager: OrderEntryManager
    @Binding var orderToEdit: OrderEntry?

    @State private var productType = "Visiting Card"
    @State private var size = ""
    @State private var quantity = ""
    @State private var unitCost = ""
    @State private var totalCost = ""
    @State private var urgencyLevel = "Normal"
    @State private var paymentStatus = "Pending"
    @State private var paymentMethod = "Cash"
    @State private var orderStatus = "In Progress"
    @State private var includesDesign = false
    @State private var requiresInstallation = false
    @State private var deliveryDate = Date()
    @State private var invoiceNumber = ""
    @State private var discountCode = ""
    @State private var deliveryAddress = ""
    @State private var notes = ""
    @State private var showAlert = false

    private let productTypes = ["Visiting Card", "Flex", "Standee"]
    private let urgencyLevels = ["Normal", "Urgent", "Same Day"]
    private let paymentStatuses = ["Paid", "Pending"]
    private let paymentMethods = ["Cash", "UPI", "Card"]
    private let orderStatuses = ["In Progress", "Completed", "Delivered"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    Picker("Product Type", selection: $productType) {
                        ForEach(productTypes, id: \.self) { Text($0) }
                    }
                    TextField("Size", text: $size)
                    TextField("Quantity", text: $quantity).keyboardType(.numberPad)
                    TextField("Unit Cost", text: $unitCost).keyboardType(.decimalPad)
                    TextField("Total Cost", text: $totalCost).keyboardType(.decimalPad)
                }

                Section(header: Text("Order Details")) {
                    Picker("Urgency", selection: $urgencyLevel) {
                        ForEach(urgencyLevels, id: \.self) { Text($0) }
                    }
                    Picker("Order Status", selection: $orderStatus) {
                        ForEach(orderStatuses, id: \.self) { Text($0) }
                    }
                    DatePicker("Delivery Date", selection: $deliveryDate, displayedComponents: .date)
                }

                Section(header: Text("Payment")) {
                    Picker("Status", selection: $paymentStatus) {
                        ForEach(paymentStatuses, id: \.self) { Text($0) }
                    }
                    Picker("Method", selection: $paymentMethod) {
                        ForEach(paymentMethods, id: \.self) { Text($0) }
                    }
                    TextField("Invoice Number", text: $invoiceNumber)
                    TextField("Discount Code", text: $discountCode)
                }

                Section(header: Text("Additional")) {
                    TextField("Delivery Address", text: $deliveryAddress)
                    TextEditor(text: $notes).frame(height: 60)
                    Toggle("Includes Design", isOn: $includesDesign)
                    Toggle("Requires Installation", isOn: $requiresInstallation)
                }
            }
            .navigationTitle(orderToEdit == nil ? "Add Order" : "Edit Order")
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
                Alert(title: Text("Missing Info"), message: Text("Product type, quantity, and cost are required."), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func saveData() {
        guard !productType.isEmpty,
              let qty = Int(quantity),
              let unit = Double(unitCost),
              let total = Double(totalCost) else {
            showAlert = true
            return
        }

        let entry = OrderEntry(
            id: orderToEdit?.id ?? UUID(),
            clientId: UUID(), // Replace with linked client ID in production
            orderDate: Date(),
            productType: productType,
            size: size,
            quantity: qty,
            unitCost: unit,
            totalCost: total,
            deliveryDate: deliveryDate,
            urgencyLevel: urgencyLevel,
            paymentStatus: paymentStatus,
            paymentMethod: paymentMethod,
            orderStatus: orderStatus,
            includesDesign: includesDesign,
            requiresInstallation: requiresInstallation,
            discountCode: discountCode.isEmpty ? nil : discountCode,
            invoiceNumber: invoiceNumber.isEmpty ? nil : invoiceNumber,
            deliveryAddress: deliveryAddress.isEmpty ? nil : deliveryAddress,
            notes: notes.isEmpty ? nil : notes
        )

        if orderToEdit == nil {
            manager.add(entry)
        } else {
            manager.update(entry)
        }

        presentationMode.wrappedValue.dismiss()
    }

    private func populateData() {
        guard let entry = orderToEdit else { return }
        productType = entry.productType
        size = entry.size
        quantity = String(entry.quantity)
        unitCost = String(entry.unitCost)
        totalCost = String(entry.totalCost)
        urgencyLevel = entry.urgencyLevel
        paymentStatus = entry.paymentStatus
        paymentMethod = entry.paymentMethod
        orderStatus = entry.orderStatus
        includesDesign = entry.includesDesign
        requiresInstallation = entry.requiresInstallation
        deliveryDate = entry.deliveryDate
        invoiceNumber = entry.invoiceNumber ?? ""
        discountCode = entry.discountCode ?? ""
        deliveryAddress = entry.deliveryAddress ?? ""
        notes = entry.notes ?? ""
    }
}
