import SwiftUI
import SwiftUISugar
import FoodLabel
import PrepDataTypes
import PrepViews
import SwiftHaptics

extension FoodForm {
    var detailsSection: some View {
        FormStyledSection(header: Text("Details")) {
            NavigationLink {
                DetailsForm()
                    .environmentObject(fields)
            } label: {
                if fields.detailsAreEmpty {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                } else {
                    FoodDetailsView(
                        emoji: $fields.emoji,
                        name: $fields.name,
                        detail: $fields.detail,
                        brand: $fields.brand,
                        didTapEmoji: {
                            showingEmojiPicker = true
                        }
                    )
                }
            }
        }
    }
    
    var sourcesSection: some View {
        SourcesSummaryCell(sources: sources)
    }
    
    var foodLabelSection: some View {
        @ViewBuilder var header: some View {
            if !fields.shouldShowFoodLabel {
                Text("Nutrition Facts")
            }
        }
        
        return FormStyledSection(header: header) {
            NavigationLink {
                NutrientsList()
                    .environmentObject(fields)
                    .environmentObject(sources)
            } label: {
                if fields.shouldShowFoodLabel {
                    foodLabel
                } else {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    @ViewBuilder
    var prefillSection: some View {
        if let url = fields.prefilledFood?.sourceUrl {
            FormStyledSection(header: Text("Prefilled Food")) {
                NavigationLink {
                    WebView(urlString: url)
                } label: {
                    LinkCell(LinkInfo("https://myfitnesspal.com")!, title: "MyFitnessPal")
                }
            }
        }
    }
    
    var servingSection: some View {
        FormStyledSection(header: Text("Amount Per")) {
            NavigationLink {
                AmountPerForm()
                    .environmentObject(fields)
            } label: {
                if fields.hasAmount {
                    foodAmountPerView
                } else {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
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
                showingAddBarcodeMenu: Binding<Bool>(
                    get: { showingAddBarcodeMenu },
                    set: { newValue in showingAddBarcodeMenu = newValue }
                ),
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
                        } label: {
                            Label("Scan a Barcode", systemImage: "barcode.viewfinder")
                        }
                        
                        Button {
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
