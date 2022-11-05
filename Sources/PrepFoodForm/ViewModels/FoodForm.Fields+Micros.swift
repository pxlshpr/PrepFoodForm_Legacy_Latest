import Foundation
import PrepDataTypes

extension FoodForm.Fields {
    
    func groupArray(for nutrientType: NutrientType) -> [Field] {
        switch nutrientType.group {
        case .fats:         return microsFats
        case .fibers:       return microsFibers
        case .sugars:       return microsSugars
        case .minerals:     return microsMinerals
        case .vitamins:     return microsVitamins
        case .misc:         return microsMisc
        default:            return []
        }
    }
    
    func micronutrientField(for nutrientType: NutrientType) -> Field? {
        for field in groupArray(for: nutrientType) {
            if case .micro(let microValue) = field.value, microValue.nutrientType == nutrientType {
                return field
            }
        }
        return nil
    }
    
    func hasMicronutrient(for nutrientType: NutrientType) -> Bool {
        micronutrientField(for: nutrientType) != nil
    }

    func addMicronutrient(for nutrientType: NutrientType) {
        /// Make sure we don't already have it
        guard micronutrientField(for: nutrientType) == nil else {
            return
        }
        
        let field = Field.init(fieldValue: .init(micronutrient: nutrientType), sources: sources)
        switch nutrientType.group {
        case .fats:         microsFats.append(field)
        case .fibers:       microsFibers.append(field)
        case .sugars:       microsSugars.append(field)
        case .minerals:     microsMinerals.append(field)
        case .vitamins:     microsVitamins.append(field)
        case .misc:         microsMisc.append(field)
        default:        return
        }
    }
    
    func addMicronutrients(_ nutrientTypes: [NutrientType]) {
        for nutrientType in nutrientTypes {
            addMicronutrient(for: nutrientType)
        }
    }

    func hasUnusedMicros(in group: NutrientTypeGroup, matching searchString: String = "") -> Bool {
        group.nutrients.contains(where: {
            if searchString.isEmpty {
                return !hasMicronutrient(for: $0)
            } else {
                return !hasMicronutrient(for: $0) && $0.matchesSearchString(searchString)
            }
        })
    }
    
    var haveMicronutrients: Bool {
        !allMicronutrientFields.isEmpty
    }
    
    var microsDict: [NutrientType : FoodLabelValue] {
        var dict: [NutrientType : FoodLabelValue] = [:]
        for fieldValue in allMicronutrientFieldValues {
            guard let value = fieldValue.value else { continue }
            dict[fieldValue.microValue.nutrientType] = value
        }
        return dict
    }
}

//extension FoodForm.Fields {
//
//    func micronutrientField(for nutrientType: NutrientType) -> Field? {
//        for group in micronutrients {
//            for field in group.fields {
//                if case .micro(let microValue) = field.value, microValue.nutrientType == nutrientType {
//                    return field
//                }
//            }
//        }
//        return nil
//    }
//
//    func addMicronutrients(_ nutrientTypes: [NutrientType]) {
//        for g in micronutrients.indices {
//            for f in micronutrients[g].fields.indices {
//                guard let nutrientType = micronutrients[g].fields[f].nutrientType,
//                      nutrientTypes.contains(nutrientType) else {
//                    continue
//                }
//                micronutrients[g].fields[f].value.microValue.isIncluded = true
//            }
//        }
//    }
//
//    func hasRemainingMicrosForGroup(at index: Int, matching searchString: String = "") -> Bool {
//        micronutrients[index].fields.contains(where: {
//            if !searchString.isEmpty {
//                return $0.value.isEmpty && $0.value.microValue.matchesSearchString(searchString)
//            } else {
//                return $0.value.isEmpty
//            }
//        })
//    }
//
//    func hasMicrosForGroup(at index: Int) -> Bool {
//        micronutrients[index].fields.contains(where: { $0.value.microValue.isIncluded })
//    }
//
//    var micronutrientsIsEmpty: Bool {
//        for (_, fields) in micronutrients {
//            for field in fields {
//                if !field.value.isEmpty {
//                    return false
//                }
//            }
//        }
//        return true
//    }
//}
