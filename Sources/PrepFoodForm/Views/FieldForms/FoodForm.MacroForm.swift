import SwiftUI
import PrepDataTypes

extension FoodForm.NutrientsList {
    struct MacroForm: View {
        @EnvironmentObject var fields: FoodForm.Fields
        @ObservedObject var existingField: Field
        @StateObject var field: Field
        
        init(existingField: Field) {
            self.existingField = existingField
            
            let fieldViewModel = existingField
            _field = StateObject(wrappedValue: fieldViewModel)
        }
    }
}

extension FoodForm.NutrientsList.MacroForm {
    
    var body: some View {
        FoodForm.FieldForm(
            field: field,
            existingField: existingField,
            unitView: unit,
            tappedPrefillFieldValue: tappedPrefillFieldValue,
            setNewValue: setNewValue
        )
    }
    
    var unit: some View {
        Text(field.value.macroValue.unitDescription)
            .foregroundColor(.secondary)
            .font(.title3)
        
    }
    
    func tappedPrefillFieldValue(_ fieldValue: FieldValue) {
        guard case .macro(let macroValue) = fieldValue else {
            return
        }
        field.value.macroValue = macroValue
    }

    func setNewValue(_ value: FoodLabelValue) {
        field.value.macroValue.string = value.amount.cleanAmount
    }
}
