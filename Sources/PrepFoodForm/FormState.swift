import Foundation
import PrepDataTypes

enum FormState: Hashable {
    case empty
    case noChange
    case duplicate
    case invalid(message: String)
    case okToSave
}

extension Field {
    
    /**
     Returns the current `FormState` that would result from the values present in the `fieldValue`, depending on its type.
     
     So for a `FieldValue.size`, for instance:
        - `FormState.invalid` is returned if the amount is empty, the name is empty, or the quantity and amount aren't greater than 0.
        - `FormState.duplicate` is returned with the duplicate if the `FoodFormViewModel.shared` singleton already contains a size with that name and volume prefix unit.
     
     Further types will be handled as required.
     */
    func formState(existingFieldViewModel: Field? = nil) -> FormState {
        switch self.value {
        case .size(let sizeValue):
            let sizeBeingEdited = existingFieldViewModel?.value.size
            return sizeValue.size.formState(sizeBeingEdited: sizeBeingEdited)
        default:
            return .okToSave
        }
    }
}

extension FormSize {
    func formState(sizeBeingEdited: FormSize? = nil) -> FormState {
        //TODO: Bring this back before using this
//        if FoodFormViewModel.shared.containsSize(withName: name, andVolumePrefixUnit: volumePrefixUnit, ignoring: sizeBeingEdited) {
//            return .duplicate
//        }

        guard !amountString.isEmpty, let _ = amount else {
            return .invalid(message: "Amount cannot be empty")
        }
        guard !name.isEmpty else {
            return .invalid(message: "Name cannot be empty")
        }
        guard let quantity, quantity > 0 else {
            return .invalid(message: "Quantity has to be greater than 0")
        }
        guard let amount, amount > 0 else {
            return .invalid(message: "Amount has to be greater than 0")
        }
        
        if let sizeBeingEdited {
            if self == sizeBeingEdited {
                return .noChange
            }
        }
 
        return .okToSave
    }
}

