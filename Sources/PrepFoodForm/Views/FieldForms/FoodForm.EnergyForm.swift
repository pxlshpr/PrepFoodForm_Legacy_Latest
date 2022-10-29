import SwiftUI
import PrepDataTypes

extension FoodForm {
    struct EnergyForm: View {
        @ObservedObject var existingField: Field
        @StateObject var field: Field
        
        init(existingField: Field) {
            self.existingField = existingField
            
            let fieldViewModel = existingField
            _field = StateObject(wrappedValue: fieldViewModel)
        }
    }
}

extension FoodForm.EnergyForm {
    
    var body: some View {
        FoodForm.FieldForm(
            field: field,
            existingField: existingField,
            unitView: unitPicker,
            tappedPrefillFieldValue: tappedPrefillFieldValue,
            setNewValue: setNewValue
        )
    }
    
    var unitPicker: some View {
        let binding = Binding<EnergyUnit> (
            get: { field.value.energyValue.unit },
            set: { newValue in
                field.value.energyValue.unit = newValue
                field.value.fill = .userInput
            }
        )
        return Picker("", selection: binding) {
            ForEach(EnergyUnit.allCases, id: \.self) {
                unit in
                Text(unit.shortDescription).tag(unit)
            }
        }
        .pickerStyle(.segmented)
        
    }
    
    func tappedPrefillFieldValue(_ fieldValue: FieldValue) {
        guard case .energy(let energyValue) = fieldValue else {
            return
        }
        field.value.energyValue = energyValue
    }
    
    func setNewValue(_ value: FoodLabelValue) {
        field.value.energyValue.string = value.amount.cleanAmount
        if let unit = value.unit, unit.isEnergy {
            field.value.energyValue.unit = unit.energyUnit
        } else {
            field.value.energyValue.unit = .kcal
        }
    }
}
