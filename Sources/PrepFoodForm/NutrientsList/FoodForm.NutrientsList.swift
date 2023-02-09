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
        @State var showingNutrientForm = false
    }
}

extension FoodForm.NutrientsList {
    class ViewModel: ObservableObject {
        @Published var nutrientBeingEdited: AnyNutrient? = nil
    }
}

extension FoodForm.NutrientsList {
    
    public var body: some View {
        scrollView
            .toolbar { navigationTrailingContent }
            .navigationTitle("Nutrition Facts")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingMicronutrientsPicker) { micronutrientsPicker }
            .sheet(isPresented: $showingNutrientForm) { nutrientForm }
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
    var nutrientForm: some View {
        if let nutrient = viewModel.nutrientBeingEdited {
            NutrientForm(
                nutrient: nutrient,
                initialValue: fields.value(for: nutrient),
                handleNewValue: { newValue in
                    handleNewValue(newValue, for: nutrient)
                }
            )
        }
    }
    
    func handleNewValue(_ value: FoodLabelValue?, for nutrient: AnyNutrient) {
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
        
        switch nutrient {
        case .energy:
            guard let value else { return }
            handleNewEnergyValue(value)
        case .macro(let macro):
            guard let value else { return }
            handleNewMacroValue(value, for: macro)
        case .micro(let nutrientType):
            handleNewMicroValue(value, for: nutrientType)
        }
        fields.updateFormState()
    }
}
