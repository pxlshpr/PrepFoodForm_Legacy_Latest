//import PrepDataTypes
//
//public enum AnyNutrient {
//    case energy
//    case macro(Macro)
//    case micro(NutrientType)
//
//    public var defaultFoodLabelUnit: FoodLabelUnit {
//        switch self {
//        case .energy:
//            return .kcal
//        case .macro:
//            return .g
//        case .micro(let nutrientType):
//            return nutrientType.supportedNutrientUnits.first?.foodLabelUnit ?? .g
//        }
//    }
//
//    public var isRequired: Bool {
//        switch self {
//        case .micro:
//            return false
//        default:
//            return true
//        }
//    }
//
//    public var description: String {
//        switch self {
//        case .energy:
//            return "Energy"
//        case .macro(let macro):
//            return macro.description
//        case .micro(let nutrientType):
//            return nutrientType.description
//        }
//    }
//
//    public var isEnergy: Bool {
//        switch self {
//        case .energy:
//            return true
//        default:
//            return false
//        }
//    }
//
//    public var nutrientType: NutrientType? {
//        switch self {
//        case .micro(let nutrientType):
//            return nutrientType
//        default:
//            return nil
//        }
//    }
//
//    public var macro: Macro? {
//        switch self {
//        case .macro(let macro):
//            return macro
//        default:
//            return nil
//        }
//    }
//}
