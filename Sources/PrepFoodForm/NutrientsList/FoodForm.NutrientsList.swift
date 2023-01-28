import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar
import FoodLabelScanner

extension FoodForm {
    struct NutrientsList: View {
        @EnvironmentObject var fields: FoodForm.Fields
        @EnvironmentObject var sources: FoodForm.Sources

        @StateObject var viewModel = ViewModel()
        
        @State var showingMicronutrientsPicker = false
        @State var showingImages = true
        @State var showingAttributeForm = false
    }
}

extension FoodForm.NutrientsList {
    class ViewModel: ObservableObject {
        @Published var attributeBeingEdited: Attribute? = nil
    }
}

extension FoodForm.NutrientsList {
    
    public var body: some View {
        scrollView
            .toolbar { navigationTrailingContent }
            .navigationTitle("Nutrition Facts")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingMicronutrientsPicker) { micronutrientsPicker }
            .sheet(isPresented: $showingAttributeForm) { attributeForm }
    }
    
    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                energyCell
                macronutrientsGroup
                micronutrientsGroup
            }
            .padding(.horizontal, 20)
            .safeAreaInset(edge: .bottom) {
                Spacer()
                    .frame(height: 60)
            }
        }
        .scrollContentBackground(.hidden)
        .background(
            FormBackground()
                .edgesIgnoringSafeArea(.all)
        )
//        .background(Color(.systemGroupedBackground))
    }
    
    @ViewBuilder
    var attributeForm: some View {
        if let attribute = viewModel.attributeBeingEdited {
            AttributeForm(
                attribute: attribute,
                initialValue: fields.value(for: attribute),
                handleNewValue: { newValue in
                    handleNewValue(newValue, for: attribute)
                }
            )
        }
    }
    
    func handleNewValue(_ value: FoodLabelValue?, for attribute: Attribute) {
        func handleNewEnergyValue(_ value: FoodLabelValue) {
            fields.energy.value.energyValue.string = value.amount.cleanAmount
            if let unit = value.unit, unit.isEnergy {
                fields.energy.value.energyValue.unit = unit.energyUnit
            } else {
                fields.energy.value.energyValue.unit = .kcal
            }
            fields.energy.registerUserInput()
        }
        
        func handleNewMacroValue(_ value: FoodLabelValue, for macro: Macro) {
            let field = fields.field(for: macro)
            field.value.macroValue.string = value.amount.cleanAmount
            field.registerUserInput()
        }
        
        func handleNewMicroValue(_ value: FoodLabelValue?, for nutrientType: NutrientType) {
            guard let field = fields.field(for: nutrientType) else { return }
            if let value {
                field.value.microValue.string = value.amount.cleanAmount
                if let unit = value.unit?.nutrientUnit(
                    for: field.value.microValue.nutrientType)
//                    , supportedUnits.contains(unit)
                {
                    field.value.microValue.unit = unit
                } else {
                    field.value.microValue.unit = nutrientType.defaultUnit
                }
                field.registerUserInput()
            } else {
                field.value.microValue.double = nil
                field.value.microValue.unit = nutrientType.defaultUnit
                field.registerUserInput()
            }
        }
        
        if attribute == .energy {
            guard let value else { return }
            handleNewEnergyValue(value)
        } else if let macro = attribute.macro {
            guard let value else { return }
            handleNewMacroValue(value, for: macro)
        } else if let nutrientType = attribute.nutrientType {
            handleNewMicroValue(value, for: nutrientType)
        }
        fields.updateFormState()
    }
}
