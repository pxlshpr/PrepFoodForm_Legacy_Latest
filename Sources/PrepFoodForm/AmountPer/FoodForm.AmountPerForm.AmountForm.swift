import SwiftUI
import PrepDataTypes
import SwiftHaptics

extension FoodForm.AmountPerForm {
    struct AmountForm: View {
        
        @EnvironmentObject var fields: FoodForm.Fields
        @EnvironmentObject var sources: FoodForm.Sources

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

extension FoodForm.AmountPerForm.AmountForm {
    
    var body: some View {
        FoodForm.FieldForm(
            field: field,
            existingField: existingField,
            unitView: unitButton,
            footerString: footerString,
            titleString: headerString,
            didSave: didSave,
            tappedPrefillFieldValue: tappedPrefillFieldValue,
            setNewValue: setNewValue
        )
        .sheet(isPresented: $showingUnitPicker) { unitPicker }
        .sheet(isPresented: $showingAddSizeForm) { addSizeForm }
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
            pickedUnit: field.value.doubleValue.unit
        ) {
            showingAddSizeForm = true
        } didPickUnit: { unit in
            setUnit(unit)
        }
        .environmentObject(fields)
    }

    var addSizeForm: some View {
        FoodForm.AmountPerForm.SizeForm(includeServing: false, allowAddSize: false) { sizeField in
            guard let size = sizeField.size else { return }
            field.value.doubleValue.unit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                Haptics.feedback(style: .rigid)
                showingUnitPicker = false
            }
        }
        .environmentObject(fields)
        .environmentObject(sources)
    }

    func tappedPrefillFieldValue(_ fieldValue: FieldValue) {
        switch fieldValue {
        case .amount(let doubleValue):
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
        setUnit(value.unit?.formUnit ?? .serving)
    }
    
    func setAmount(_ amount: Double) {
        field.value.doubleValue.double = amount
    }
    
    func didSave() {
        fields.amountChanged()
    }
    
    func setUnit(_ unit: FormUnit) {
        field.value.doubleValue.unit = unit
    }
    
    var headerString: String {
        switch field.value.doubleValue.unit {
        case .serving:
            return "Servings"
        case .weight:
            return "Weight"
        case .volume:
            return "Volume"
        case .size:
            return "Size"
        }
    }

    var footerString: String {
        "This is how much of this food the nutrition facts are for. You'll be able to log this food using the unit you choose."
    }
}
