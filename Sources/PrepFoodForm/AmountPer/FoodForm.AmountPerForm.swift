import SwiftUI
import SwiftUISugar
import PrepDataTypes
import PrepViews

extension FoodForm {
    struct AmountPerForm: View {
        @EnvironmentObject var fields: FoodForm.Fields
        @EnvironmentObject var sources: FoodForm.Sources
        @State var showingAddSizeForm = false
    }
}

extension FoodForm.AmountPerForm {

    public var body: some View {
        form
        .navigationTitle("Amount Per")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAddSizeForm) { sizeForm }
    }
    
    var form: some View {
        FormStyledScrollView {
            fieldSection
            if fields.shouldShowSizes {
                sizesSection
            }
            if fields.shouldShowDensity {
                densitySection
            }
        }
    }
   
    var fieldSection: some View {
        var footer: some View {
            Text("How much of this food the nutrition facts are for.")
                .foregroundColor(fields.shouldShowSizes ? FormFooterFilledColor : FormFooterEmptyColor )
        }
        
        return FormStyledSection(footer: footer) {
            amountField
        }
    }
    
    var sizesSection: some View {
        var header: some View {
            Text("Sizes")
        }

        @ViewBuilder
        var footer: some View {
            Text("Sizes give you additional named units to log this food in, such as – biscuit, bottle, container, etc.")
                .foregroundColor(fields.allSizes.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
        }

        var addButton: some View {
            Button {
                showingAddSizeForm = true
            } label: {
                Text("Add a size")
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
        }
        
        let sizesBinding = Binding<[FormSize]>(
            get: { fields.allSizes },
            set: { _ in }
        )

        return Group {
            if fields.allSizes.isEmpty {
                FormStyledSection(header: header, footer: footer) {
                    addButton
                }
            } else {
                FormStyledSection(header: header) {
                    NavigationLink {
                        SizesList()
                            .environmentObject(fields)
                            .environmentObject(sources)
                    } label: {
                        FoodSizesView(sizes: sizesBinding, didTapAddSize: {
                            showingAddSizeForm = true
                        })
                        .environmentObject(fields)
                    }
                }
            }
        }
    }

    var densitySection: some View {
        FormStyledSection(header: Text("Unit Conversion"), footer: densityFooter) {
            NavigationLink {
                densityForm
            } label: {
                DensityView(
                    field: fields.density,
                    isWeightBased: Binding<Bool>(
                        get: { fields.isWeightBased },
                        set: { _ in }
                    ),
                    shouldShowFillIcon: Binding<Bool>(
                        get: { fields.hasNonUserInputFills },
                        set: { _ in }
                    )
                )
            }
        }
    }

    @ViewBuilder
    var densityFooter: some View {
        Group {
            if fields.isWeightBased {
                Text("Enter this to be able to log this food using volume units, like cups.")
            } else if fields.isVolumeBased {
                Text("Enter this to be able to log this food using using its weight.")
            }
        }
        .foregroundColor(!fields.hasValidDensity ? FormFooterEmptyColor : FormFooterFilledColor)
    }
    
    //MARK: - Amount Field
    
    var amountField: some View {
        HStack {
            Spacer()
            amountButton
            if fields.shouldShowServing {
                Spacer()
                Text("of")
                    .font(.title3)
                    .foregroundColor(Color(.tertiaryLabel))
                Spacer()
                servingButton
                Spacer()
            }
        }
    }
    
    var amountButton: some View {
        NavigationLink {
            amountForm
        } label: {
            label(fields.amount.doubleValueDescription, placeholder: "Required")
        }
    }
    
    var servingButton: some View {
        NavigationLink {
            servingForm
        } label: {
            label(fields.serving.doubleValueDescription, placeholder: "serving size")
        }
    }
    
    func label(_ string: String, placeholder: String) -> some View {
        Group {
            if string.isEmpty {
                HStack(spacing: 5) {
                    Text(placeholder)
                        .foregroundColor(Color(.quaternaryLabel))
                }
            } else {
                Text(string)
            }
        }
        .foregroundColor(.accentColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
    
    //MARK: - SubForms
    
    var amountForm: some View {
        AmountForm(existingField: fields.amount)
            .environmentObject(fields)
            .environmentObject(sources)
    }

    var servingForm: some View {
        ServingForm(existingField: fields.serving)
            .environmentObject(fields)
            .environmentObject(sources)
    }

    func sizeForm(for sizeField: Field) -> some View {
        SizeForm(field: sizeField, sources: sources) { sizeField in

        }
        .environmentObject(fields)
    }

    var sizeForm: some View {
        SizeForm(sources: sources)
            .environmentObject(fields)
    }

    var densityForm: some View {
        DensityForm(field: fields.density, orderWeightFirst: fields.isWeightBased)
            .environmentObject(fields)
            .environmentObject(sources)
    }
}
