import Foundation
import PrepDataTypes

extension FoodForm.Fields {
    
    func fillOptions(for fieldValue: FieldValue, using sources: FoodForm.Sources) -> [FillOption] {
        var fillOptions: [FillOption] = []

        fillOptions.append(contentsOf: extractedFillOptions(for: fieldValue))
        fillOptions.append(contentsOf: selectionFillOptions(for: fieldValue))
        fillOptions.append(contentsOf: prefillOptions(for: fieldValue))

        if let selectFillOption = selectFillOption(for: fieldValue, using: sources) {
            fillOptions .append(selectFillOption)
        }
        
        return fillOptions
    }
    
    func fillButtonString(for fieldValue: FieldValue) -> String {
        switch fieldValue {
        case .amount(let doubleValue), .serving(let doubleValue):
            return doubleValue.description
        case .energy(let energyValue):
            return energyValue.description
        case .macro(let macroValue):
            return macroValue.description
        case .micro(let microValue):
            return microValue.description
        case .density(let densityValue):
            return densityValue.description(weightFirst: isWeightBased)
        case .size(let sizeValue):
            return sizeValue.size.fullNameString
        default:
            return "(not implemented)"
        }
    }
    
    func hasFillOptions(for fieldValue: FieldValue, using sources: FoodForm.Sources) -> Bool {
        !fillOptions(for: fieldValue, using: sources).isEmpty
    }
}
