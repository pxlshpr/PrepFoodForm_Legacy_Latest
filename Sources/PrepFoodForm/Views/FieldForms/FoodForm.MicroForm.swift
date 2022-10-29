import SwiftUI
import PrepDataTypes

extension FoodForm.NutrientsList {
    struct MicroForm: View {
        @ObservedObject var existingField: Field
        @StateObject var field: Field
        
//        @State var unit: NutrientUnit
        
        init(existingField: Field) {
            self.existingField = existingField
            
            let field = existingField
            _field = StateObject(wrappedValue: field)
            
//            _unit = State(initialValue: existingField.value.microValue.unit)
        }
    }
}

extension FoodForm.NutrientsList.MicroForm {
    
    var body: some View {
        FoodForm.FieldForm(
            field: field,
            existingField: existingField,
            unitView: unitView,
            supplementaryView: percentageInfoView,
            supplementaryViewHeaderString: supplementaryViewHeaderString,
            supplementaryViewFooterString: supplementaryViewFooterString,
            tappedPrefillFieldValue: tappedPrefillFieldValue,
            setNewValue: setNewValue
        )
//        .onChange(of: unit) { newValue in
//            withAnimation {
//                field.value.microValue.unit = newValue
//            }
//        }
    }
    
    var supplementaryViewHeaderString: String? {
//        if fieldViewModel.fieldValue.microValue.unit == .p {
        if field.value.microValue.convertedFromPercentage != nil {
            return "Equivalent Value"
        }
        return nil
    }

    var supplementaryViewFooterString: String? {
//        if fieldViewModel.fieldValue.microValue.unit == .p {
        if field.value.microValue.convertedFromPercentage != nil {
            return "% values will be converted and saved as their equivalent amounts."
        }
        
        return nil
    }

    @ViewBuilder
    var percentageInfoView: some View {
        if let valueAndUnit = field.value.microValue.convertedFromPercentage {
            HStack {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(valueAndUnit.amount.cleanAmount)
                        .foregroundColor(Color.secondary)
                        .font(.system(size: 30, weight: .regular, design: .rounded))
//                        .font(.title)
                    Text(valueAndUnit.1.shortDescription)
                        .foregroundColor(Color(.tertiaryLabel))
                        .font(.system(size: 25, weight: .regular, design: .rounded))
//                        .font(.title3)
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var unitView: some View {
        if supportedUnits.count > 1 {
            unitPicker
        } else {
            Text(field.value.microValue.unitDescription)
                .foregroundColor(.secondary)
                .font(.title3)
        }
    }
    
    var unitPicker: some View {
        let binding = Binding<NutrientUnit> (
            get: { existingField.value.microValue.unit },
            set: { newValue in
                existingField.value.microValue.unit = newValue
                existingField.value.fill = .userInput
            }
        )
        return Picker("", selection: binding) {
            ForEach(supportedUnits, id: \.self) { unit in
                Text(unit.shortDescription).tag(unit)
            }
        }
        .pickerStyle(.menu)
    }

    func tappedPrefillFieldValue(_ fieldValue: FieldValue) {
        guard case .micro(let microValue) = fieldValue else {
            return
        }
        field.value.microValue = microValue
    }

    func setNewValue(_ value: FoodLabelValue) {
        field.value.microValue.string = value.amount.cleanAmount
        if let unit = value.unit?.nutrientUnit(for: field.value.microValue.nutrientType),
           supportedUnits.contains(unit)
        {
            field.value.microValue.unit = unit
        } else {
            field.value.microValue.unit = defaultUnit
        }
    }

    var supportedUnits: [NutrientUnit] {
        field.value.microValue.nutrientType.supportedNutrientUnits
    }
    
    var defaultUnit: NutrientUnit {
        supportedUnits.first ?? .g
    }
}
