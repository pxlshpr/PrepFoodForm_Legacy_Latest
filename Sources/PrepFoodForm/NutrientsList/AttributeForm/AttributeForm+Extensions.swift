import Foundation
import PrepDataTypes
import FoodLabelScanner

extension Field {
    var foodLabelValue: FoodLabelValue? {
        switch value {
        case .energy(let energyValue):
            guard let amount = energyValue.double else { return nil }
            let unit = energyValue.unit.foodLabelUnit ?? .kcal
            return FoodLabelValue(amount: amount , unit: unit)
        case .macro(let macroValue):
            guard let amount = macroValue.double else { return nil }
            return FoodLabelValue(amount: amount, unit: .g)
        case .micro(let microValue):
            guard let amount = microValue.double else { return nil }
            let unit = microValue.unit.foodLabelUnit ?? .g
            return FoodLabelValue(amount: amount, unit: unit)
        default:
            return nil
        }
    }
}

extension NutrientType {
    var supportedFoodLabelUnits: [FoodLabelUnit] {
        supportedNutrientUnits.map {
            $0.foodLabelUnit ?? .g
        }
    }
}


extension FoodForm.Fields {
    func value(for attribute: Attribute) -> FoodLabelValue? {
        field(for: attribute)?.foodLabelValue
    }
    
    func field(for attribute: Attribute) -> Field? {
        if attribute == .energy {
            return energy
        } else if let macro = attribute.macro {
            return field(for: macro)
        } else if let nutrientType = attribute.nutrientType {
            return field(for: nutrientType)
        }
        return nil
    }
    
    func field(for macro: Macro) -> Field {
        switch macro {
        case .carb:
            return carb
        case .fat:
            return fat
        case .protein:
            return protein
        }
    }
    
    func fieldsArray(for nutrientType: NutrientType) -> [Field]? {
        switch nutrientType.group {
        case .fats:
            return microsFats
        case .fibers:
            return microsFibers
        case .sugars:
            return microsSugars
        case .minerals:
            return microsMinerals
        case .vitamins:
            return microsVitamins
        case .misc:
            return microsMisc

        default:
            return nil
        }
    }
    func field(for nutrientType: NutrientType) -> Field? {
        guard let array = fieldsArray(for: nutrientType) else { return nil }
        return array.first(where: { $0.nutrientType == nutrientType } )
    }
}
