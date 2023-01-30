import SwiftUI
import PrepDataTypes
import FoodLabelScanner

class ServingFormViewModel: ObservableObject {
    
    /// If this is false, it's for the 'amount per' value
    let isServingSize: Bool
    let handleNewValue: ((Double, FormUnit)?) -> ()
    let initialField: Field?
    
    @Published var unit: FormUnit
    @Published var internalTextfieldString: String = ""
    @Published var internalTextfieldDouble: Double? = nil
    
    init(
        isServingSize: Bool,
        initialField: Field?,
        handleNewValue: @escaping ((Double, FormUnit)?) -> Void
    ) {
        self.isServingSize = isServingSize
        self.handleNewValue = handleNewValue
        self.initialField = initialField
        
        if let initialField {
            internalTextfieldDouble = initialField.value.double ?? nil
            internalTextfieldString = initialField.value.double?.cleanWithoutRounding ?? ""
        }
        self.unit = initialField?.value.doubleValue.unit ?? (isServingSize ? .weight(.g) : .serving)
    }

    var textFieldAmountString: String {
        get { internalTextfieldString }
        set {
            guard !newValue.isEmpty else {
                internalTextfieldDouble = nil
                internalTextfieldString = newValue
                return
            }
            guard let double = Double(newValue) else {
                return
            }
            self.internalTextfieldDouble = double
            self.internalTextfieldString = newValue
        }
    }
    
    var isRequired: Bool {
        !isServingSize
    }
    
    var returnTuple: (Double, FormUnit)? {
        guard let internalTextfieldDouble else { return nil }
        return (internalTextfieldDouble, unit)
    }

    var shouldDisableDone: Bool {
        if initialField?.value.double == internalTextfieldDouble
            && initialField?.value.doubleValue.unit == unit
        {
            return true
        }
        
        if isRequired && internalTextfieldDouble == nil {
            return true
        }
        return false
    }
    
    var shouldShowClearButton: Bool {
        !textFieldAmountString.isEmpty
    }
    
    func tappedClearButton() {
        textFieldAmountString = ""
    }
    
    var title: String {
        isServingSize ? "Serving Size" : "Nutrients Per"
    }
}
