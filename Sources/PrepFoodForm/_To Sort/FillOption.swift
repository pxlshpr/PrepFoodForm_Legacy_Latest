import Foundation
import PrepDataTypes

struct FillOption: Hashable {
    let string: String
    let systemImage: String
    let isSelected: Bool
    let disableWhenSelected: Bool
    let type: FillOptionType
    
    init(string: String, systemImage: String, isSelected: Bool, disableWhenSelected: Bool = true, type: FillOptionType) {
        self.string = string
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.disableWhenSelected = disableWhenSelected
        self.type = type
    }
}

extension Fill {
    var prefilledDensityValue: FieldValue.DensityValue? {
        guard case .prefill(let info) = self else {
            return nil
        }
        return info.densityValue
    }
}
extension FoodLabelValue {
    public var fillOptionString: String {
        if let unit = unit {
            return "\(amount.cleanAmount) \(unit.description)"
        } else {
            return "\(amount.cleanAmount)"
        }
    }
}
