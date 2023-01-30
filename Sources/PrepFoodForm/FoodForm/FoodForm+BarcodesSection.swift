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
    
    func showAddBarcodeAlert() {
//        if presentedSheet != nil {
//            presentedSheet = nil
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                Haptics.selectionFeedback()
//                presentedSheet = sheet
//            }
//        } else if presentedFullScreenSheet != nil {
//            presentedFullScreenSheet = nil
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                Haptics.selectionFeedback()
//                presentedSheet = sheet
//            }
//        } else {
//            Haptics.selectionFeedback()
//            presentedSheet = sheet
//        }
        Haptics.feedback(style: .soft)
        if showingAddBarcodeAlert {
            /// Mitigates glitch where the alert fails to present if we're already presenting a `Menu`, but still sets this flag
            showingAddBarcodeAlert = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingAddBarcodeAlert = true
            }
        } else {
            showingAddBarcodeAlert = true
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
        
        func removeBarcode(_ barcodeValue: FieldValue) {
            withAnimation {
                sources.removeBarcodePayload(barcodeValue.string)
                fields.barcodes.removeAll(where: {
                    $0.barcodeValue == barcodeValue.barcodeValue
                })
            }
        }

        var addBarcodeSection: some View {
            FormStyledSection(header: header, footer: footer, horizontalPadding: 0, verticalPadding: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8.0) {
                        ForEach(barcodeValues, id: \.self) { barcodeValue in
                            if let image = barcodeValue.barcodeThumbnail(width: buttonWidth, height: 80) {
                                Menu {
                                    Text(barcodeValue.string)
                                    Divider()
                                    Button(role: .destructive) {
                                        removeBarcode(barcodeValue)
                                    } label: {
                                        Label("Remove", systemImage: "minus.circle")
                                    }
                                } label: {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: buttonWidth)
//                                        .shadow(radius: 3, x: 0, y: 3)
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
                                    showAddBarcodeAlert()
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
                                    showAddBarcodeAlert()
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
                        showAddBarcodeAlert()
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
