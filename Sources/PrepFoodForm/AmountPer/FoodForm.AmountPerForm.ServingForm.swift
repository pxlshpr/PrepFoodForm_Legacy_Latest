import SwiftUI
import PrepDataTypes
import SwiftHaptics

extension FoodForm.AmountPerForm {
    struct ServingForm: View {
        @EnvironmentObject var fields: FoodForm.Fields
        @ObservedObject var existingField: Field
        @StateObject var field: Field

        @State var showingUnitPicker = false
        @State var showingAddSizeForm = false

        init(existingField: Field) {
            self.existingField = existingField
            
            let field = existingField
            _field = StateObject(wrappedValue: field)
        }
    }
}

extension FoodForm.AmountPerForm.ServingForm {
    
    var body: some View {
        FoodForm.FieldForm(
            field: field,
            existingField: existingField,
            unitView: unitButton,
            headerString: headerString,
            footerString: footerString,
            placeholderString: "Optional",
            didSave: didSave,
            tappedPrefillFieldValue: tappedPrefillFieldValue,
            setNewValue: setNewValue
        )
        .sheet(isPresented: $showingUnitPicker) { unitPicker }
    }
    
    var unitButton: some View {
        Button {
            showingUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(field.value.doubleValue.unit.shortDescription)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }

    var unitPicker: some View {
        FoodForm.AmountPerForm.UnitPicker(
            pickedUnit: field.value.doubleValue.unit,
            includeServing: false
        ) {
            showingAddSizeForm = true
        } didPickUnit: { unit in
            setUnit(unit)
        }
        .environmentObject(fields)
        .sheet(isPresented: $showingAddSizeForm) { addSizeForm }
    }
    
    var addSizeForm: some View {
        FoodForm.AmountPerForm.SizeForm(includeServing: true, allowAddSize: false) { sizeField in
            guard let size = sizeField.size else { return }
            field.value.doubleValue.unit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                Haptics.feedback(style: .rigid)
                showingUnitPicker = false
            }
        }
        .environmentObject(fields)
    }

    func didSave() {
        fields.servingChanged()
    }

    func tappedPrefillFieldValue(_ fieldValue: FieldValue) {
        switch fieldValue {
        case .serving(let doubleValue):
            guard let double = doubleValue.double else {
                return
            }
            setAmount(double)
            setUnit(doubleValue.unit)
        default:
            return
        }
    }
    func setNewValue(_ value: FoodLabelValue) {
        setAmount(value.amount)
        setUnit(value.unit?.formUnit ?? .weight(.g))
        fields.updateFormState()
    }
    
    func setAmount(_ amount: Double) {
        field.value.doubleValue.double = amount
    }
    
    func setUnit(_ unit: FormUnit) {
        if unit.isServingBased {
            modifyServingAmount(for: unit)
        }
        field.value.doubleValue.unit = unit
    }
    
    //TODO: AmountPerForm Revisit this
    func modifyServingAmount(for unit: FormUnit) {
//        guard fieldViewModel.fieldValue.doubleValue.unit.isServingBased,
//              case .size(let size, _) = fieldViewModel.fieldValue.doubleValue.unit
//        else {
//            return
//        }
//        let newAmount: Double
//        if let quantity = size.quantity,
//           let servingAmount = fieldViewModel.fieldValue.doubleValue.double, servingAmount > 0
//        {
//            newAmount = quantity / servingAmount
//        } else {
//            newAmount = 0
//        }
        
        //TODO-SIZE: We need to get access to it here—possibly need to add it to sizes to begin with so that we can modify it here
//        size.amountDouble = newAmount
//        updateSummary()
    }

    var headerString: String {
        switch field.value.doubleValue.unit {
        case .weight:
            return "Weight"
        case .volume:
            return "Volume"
        case .size:
            return "Size"
        default:
            return ""
        }
    }

    var footerString: String {
        switch field.value.doubleValue.unit {
        case .weight:
            return "This is the weight of 1 serving. Enter this to log this food using its weight in addition to servings."
        case .volume:
            return "This is the volume of 1 serving. Enter this to log this food using its volume in addition to servings."
        case .size(let size, _):
            return "This is how many \(size.prefixedName) is 1 serving."
        case .serving:
            return "Unsupported"
        }
        
    }
}
