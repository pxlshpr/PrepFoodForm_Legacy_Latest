import SwiftUI
import PrepDataTypes
import FoodLabelScanner

enum Nutrient {
    case energy
    case macro(Macro)
    case micro(NutrientType)
    
    var defaultFoodLabelUnit: FoodLabelUnit {
        switch self {
        case .energy:
            return .kcal
        case .macro:
            return .g
        case .micro(let nutrientType):
            return nutrientType.defaultUnit.foodLabelUnit ?? .g
        }
    }
    
    var isRequired: Bool {
        switch self {
        case .micro:
            return false
        default:
            return true
        }
    }
    
    var description: String {
        switch self {
        case .energy:
            return "Energy"
        case .macro(let macro):
            return macro.description
        case .micro(let nutrientType):
            return nutrientType.description
        }
    }
    
    var isEnergy: Bool {
        switch self {
        case .energy:
            return true
        default:
            return false
        }
    }
    
    var nutrientType: NutrientType? {
        switch self {
        case .micro(let nutrientType):
            return nutrientType
        default:
            return nil
        }
    }
    
    var macro: Macro? {
        switch self {
        case .macro(let macro):
            return macro
        default:
            return nil
        }
    }
}

class NutrientFormViewModel: ObservableObject {
    
    let nutrient: Nutrient
    
    let handleNewValue: (FoodLabelValue?) -> ()
    let initialValue: FoodLabelValue?
    
    @Published var unit: FoodLabelUnit
    @Published var internalTextfieldString: String = ""
    @Published var internalTextfieldDouble: Double? = nil
    
    init(
        nutrient: Nutrient,
        initialValue: FoodLabelValue?,
        handleNewValue: @escaping (FoodLabelValue?) -> Void
    ) {
        self.nutrient = nutrient
        
        self.handleNewValue = handleNewValue
        self.initialValue = initialValue
        
        if let initialValue {
            internalTextfieldDouble = initialValue.amount
            internalTextfieldString = initialValue.amount.cleanWithoutRounding
        }
        self.unit = initialValue?.unit ?? nutrient.defaultFoodLabelUnit
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
        nutrient.isRequired
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
