import SwiftUI
import SwiftUISugar
import SwiftHaptics

extension FoodForm {
    
    var addBarcodeTitle: String {
        "Add a Barcode"
    }
    
    var addBarcodeActions: some View {
        Group {
            TextField("012345678912", text: $barcodePayload)
                .textInputAutocapitalization(.never)
                .keyboardType(.decimalPad)
                .submitLabel(.done)
            Button("Add", action: {
                Haptics.successFeedback()
                withAnimation {
                    handleTypedOutBarcode(barcodePayload)
                }
                barcodePayload = ""
            })
            Button("Cancel", role: .cancel, action: {})
        }
    }
    
    var addBarcodeMessage: some View {
        Text("Please enter the barcode number for this food.")
    }
    
    var barcodesSection: some View {
        var header: some View {
            Text("Barcodes")
        }
        
        var footer: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text("This will allow you to scan and quickly find this food again later.")
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.leading)
            }
            .font(.footnote)
        }
        
        var barcodesForm: some View {
            BarcodesForm(
                barcodeValues: Binding<[FieldValue]>(
                    get: { fields.barcodes.map { $0.value } },
                    set: { _ in }
                ),
                shouldShowFillIcon: Binding<Bool>(
                    get: { fields.hasNonUserInputFills },
                    set: { _ in }
                ),
                showingAddBarcodeAlert: $showingAddBarcodeAlert,
                showingBarcodeScanner: $showingBarcodeScanner,
                deleteBarcodes: deleteBarcodes)
        }
        
        var barcodesView: some View {
            BarcodesView(
                barcodeValues: Binding<[FieldValue]>(
                    get: { fields.barcodes.map { $0.value } },
                    set: { _ in }
                ),
                showAsSquares: Binding<Bool>(
                    get: { fields.hasSquareBarcodes },
                    set: { _ in }
                )
            )
        }
        
        var addBarcodeSection: some View {
            FormStyledSection(header: header, footer: footer, verticalPadding: 0) {
                HStack {
                    Menu {
                        Button {
                            Haptics.feedback(style: .soft)
                            showingBarcodeScanner = true
                        } label: {
                            Label("Scan a Barcode", systemImage: "barcode.viewfinder")
                        }
                        
                        Button {
                            Haptics.feedback(style: .soft)
                            showingAddBarcodeAlert = true
                        } label: {
                            Label("Enter Manually", systemImage: "123.rectangle")
                        }
                        
                    } label: {
                        Text("Add a Barcode")
                            .frame(height: 50)
                    }
                    .contentShape(Rectangle())
                    .simultaneousGesture(TapGesture().onEnded {
                        Haptics.feedback(style: .soft)
                    })
                    Spacer()
                }
            }
        }
        
        return Group {
            if !fields.barcodes.isEmpty {
                FormStyledSection(
                    header: header,
                    footer: footer,
                    horizontalPadding: 0,
                    verticalPadding: 0)
                {
                    NavigationLink {
                        barcodesForm
                    } label: {
                        barcodesView
                    }
                }
            } else {
                addBarcodeSection
            }
        }
    }
}
