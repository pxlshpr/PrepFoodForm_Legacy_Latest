import SwiftUI
import PrepDataTypes
import FoodLabelScanner

class AttributeFormViewModel: ObservableObject {
    
    let attribute: Attribute
    let handleNewValue: (FoodLabelValue?) -> ()
    let initialValue: FoodLabelValue?
    
    @Published var unit: FoodLabelUnit
    @Published var internalTextfieldString: String = ""
    @Published var internalTextfieldDouble: Double? = nil
    
    init(
        attribute: Attribute,
        initialValue: FoodLabelValue?,
        handleNewValue: @escaping (FoodLabelValue?) -> Void
    ) {
        self.attribute = attribute
        self.handleNewValue = handleNewValue
        self.initialValue = initialValue
        
        if let initialValue {
            internalTextfieldDouble = initialValue.amount
            internalTextfieldString = initialValue.amount.cleanWithoutRounding
        }
        self.unit = initialValue?.unit ?? attribute.defaultUnit ?? .g
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
        attribute == .energy || attribute.macro != nil
    }
    
    var value: FoodLabelValue? {
        guard let internalTextfieldDouble else { return nil }
        return FoodLabelValue(amount: internalTextfieldDouble, unit: unit)
    }
    
    var shouldDisableDone: Bool {
        if initialValue == value {
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
}
