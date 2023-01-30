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
                Text("This will allow you to scan and log this food.")
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

        var barcodeValues: [FieldValue] {
            fields.barcodes.map { $0.value }
        }
        
        var buttonWidth: CGFloat {
            (UIScreen.main.bounds.width - (2 * 35.0) - (8.0 * 2.0)) / 3.0
        }

        var addBarcodeSection: some View {
            FormStyledSection(header: header, footer: footer, horizontalPadding: 0, verticalPadding: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8.0) {
                        ForEach(barcodeValues, id: \.self) {
                            if let image = $0.barcodeThumbnail(width: buttonWidth, height: 80) {
                                Menu {
                                    Button(role: .destructive) {
                                        //TODO: Write this
                                    } label: {
                                        Label("Remove", systemImage: "minus.circle")
                                    }
                                } label: {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: buttonWidth)
                                        .shadow(radius: 3, x: 0, y: 3)
                                }
                                .contentShape(Rectangle())
                                .simultaneousGesture(TapGesture().onEnded {
                                    Haptics.feedback(style: .soft)
                                })
                                .transition(
                                    .asymmetric(
                                        insertion: .move(edge: .leading),
                                        removal: .scale
                                    )
                                )
                            }
                        }
                        
                        if barcodeValues.isEmpty {
                            Group {
                                foodFormButton("Scan", image: "barcode.viewfinder", isSecondary: true) {
                                    Haptics.feedback(style: .soft)
                                    showingBarcodeScanner = true
                                }
                                foodFormButton("Enter", image: "keyboard", isSecondary: true) {
                                    Haptics.feedback(style: .soft)
                                    showingAddBarcodeAlert = true
                                }
                            }
                            .frame(width: buttonWidth)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .scale)
                            )
                        }
                        
                        /// Add Menu
                        if !barcodeValues.isEmpty {
                            
                            Menu {
                                
                                Button {
                                    Haptics.feedback(style: .soft)
                                    showingBarcodeScanner = true
                                } label: {
                                    Label("Scan", systemImage: "barcode.viewfinder")
                                }

                                Button {
                                    Haptics.feedback(style: .soft)
                                    showingAddBarcodeAlert = true
                                } label: {
                                    Label("Enter", systemImage: "keyboard")
                                }
                                                                
                            } label: {
                                foodFormButton("Add", image: "plus", isSecondary: true)
                                    .frame(width: buttonWidth)
                            }
                            .contentShape(Rectangle())
                            .simultaneousGesture(TapGesture().onEnded {
                                Haptics.feedback(style: .soft)
                            })
                            .transition(.move(edge: .trailing))
                        }

                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                }
            }
        }
        
        var addBarcodeSection_legacy: some View {
            FormStyledSection(header: header, footer: footer, verticalPadding: 0) {
                HStack {
                    foodFormButton("Scan", image: "barcode.viewfinder", isSecondary: true) {
                        Haptics.feedback(style: .soft)
                        showingBarcodeScanner = true
                    }
                    foodFormButton("Enter", image: "keyboard", isSecondary: true) {
                        Haptics.feedback(style: .soft)
                        showingAddBarcodeAlert = true
                    }
                    foodFormButton("", image: "") {
                    }
                    .disabled(true)
                    .opacity(0)
                }
                .padding(.vertical, 15)
//                HStack {
//                    Menu {
//                        Button {
//                            Haptics.feedback(style: .soft)
//                            showingBarcodeScanner = true
//                        } label: {
//                            Label("Scan a Barcode", systemImage: "barcode.viewfinder")
//                        }
//
//                        Button {
//                            Haptics.feedback(style: .soft)
//                            showingAddBarcodeAlert = true
//                        } label: {
//                            Label("Enter Manually", systemImage: "123.rectangle")
//                        }
//
//                    } label: {
//                        Text("Add a Barcode")
//                            .frame(height: 50)
//                    }
//                    .contentShape(Rectangle())
//                    .simultaneousGesture(TapGesture().onEnded {
//                        Haptics.feedback(style: .soft)
//                    })
//                    Spacer()
//                }
            }
        }
        
        return Group {
            
//            if !fields.barcodes.isEmpty {
//                FormStyledSection(
//                    header: header,
//                    footer: footer,
//                    horizontalPadding: 0,
//                    verticalPadding: 0)
//                {
//                    NavigationLink {
//                        barcodesForm
//                    } label: {
//                        barcodesView
//                    }
//                }
//            } else {
                addBarcodeSection
//            }
        }
    }
}
