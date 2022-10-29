import SwiftUI
import PrepDataTypes
import SwiftHaptics

extension FoodForm.AmountPerForm.SizeForm {
    
    func changedShowingVolumePrefixToggle(to newValue: Bool) {
        withAnimation {
            field.registerUserInput()
            formViewModel.showingVolumePrefix = showingVolumePrefixToggle
            /// If we've turned it on and there's no volume prefix for the size—set it to cup
            if showingVolumePrefixToggle {
                if field.value.size?.volumePrefixUnit == nil {
                    field.value.size?.volumePrefixUnit = .volume(.cup)
                }
            } else {
                field.value.size?.volumePrefixUnit = nil
            }
//                formViewModel.updateFormState(of: field, comparedToExisting: existingField)
        }
    }
    
    func sizeChanged(to newValue: FormUnit) {
        if !field.sizeAmountIsValid || !newValue.isWeightBased {
            field.value.size?.volumePrefixUnit = nil
        }
    }
    
    func appeared() {
        if let existingField {
            fields.sizeBeingEdited = existingField.size
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            shouldAnimateOptions = true
//                doNotRegisterUserInput = true
        }
    }
    
    func disappeared() {
        /// Reset this so it doesn't get ignored when checking for conflicts later
        fields.sizeBeingEdited = nil
    }
    
    func didTapFillOption(_ fillOption: FillOption) {
        switch fillOption.type {
        case .select:
            break
        case .fill(let fill):
            Haptics.feedback(style: .rigid)
            
            doNotRegisterUserInput = true
            switch fill {
            case .prefill(let info):
                guard let size = info.size else { return }
                setSize(size)
            case .scanned(let info):
                guard let size = info.size else { return }
                setSize(size)
                field.assignNewScannedFill(fill)
            default:
                break
            }
            doNotRegisterUserInput = false
        }
    }
    
    func setSize(_ size: FormSize) {
        field.value.size?.quantity = size.quantity
        field.value.size?.volumePrefixUnit = size.volumePrefixUnit
        field.value.size?.name = size.name
        field.value.size?.amount = size.amount
        field.value.size?.unit = size.unit
        showingVolumePrefixToggle = field.value.size?.volumePrefixUnit != nil
    }
    
    func saveAndDismiss() {
        doNotRegisterUserInput = true
        
//        existingField?.copyData(from: field)
        
        if let existingField {
            fields.edit(existingField, with: field)
        } else {
            if fields.add(sizeField: field),
               let didAddSizeViewModel = didAddSizeViewModel
            {
                didAddSizeViewModel(field)
            }
        }
        
        /// Call this in case a unit change changes whether we show the density or not
        fields.updateFormState()
        
        dismiss()
    }
}
