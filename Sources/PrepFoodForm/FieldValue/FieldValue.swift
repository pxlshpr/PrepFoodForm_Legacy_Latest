import SwiftUI
import PrepDataTypes
import FoodLabelScanner
import Vision

enum FieldValue: Hashable, Codable {
    case name(StringValue = StringValue())
    case emoji(StringValue = StringValue(string: randomFoodEmoji()))
    case brand(StringValue = StringValue())
    case detail(StringValue = StringValue())
    case amount(DoubleValue = DoubleValue(unit: .serving))
    case serving(DoubleValue = DoubleValue(unit: .weight(.g)))
    case density(DensityValue = DensityValue())
    case energy(EnergyValue = EnergyValue())
    case macro(MacroValue)
    case micro(MicroValue)
    case size(SizeValue)
    case barcode(BarcodeValue)
}

extension FieldValue {
    struct SizeValue: Hashable, Codable {
        var size: FormSize
        var fill: Fill
    }
}

extension FieldValue {
    struct BarcodeValue: Hashable, Codable {
        var payloadString: String
        var symbology: VNBarcodeSymbology
        var fill: Fill
        
        init(payloadString: String, symbology: VNBarcodeSymbology, fill: Fill) {
            self.payloadString = payloadString
            self.symbology = symbology
            self.fill = fill
        }
    }
}

extension FieldValue {
    struct MicroValue: Hashable, Codable {
        var nutrientType: NutrientType
        var internalDouble: Double?
        var internalString: String
        var unit: NutrientUnit
        var fill: Fill
        var isIncluded: Bool

        init(nutrientType: NutrientType, double: Double? = nil, string: String = "", unit: NutrientUnit = .g, isIncluded: Bool = true, fill: Fill = .discardable) {
            self.nutrientType = nutrientType
            self.internalDouble = double
            self.internalString = string
            self.isIncluded = isIncluded
            self.unit = unit
            self.fill = fill
        }
        
        var double: Double? {
            get {
                return internalDouble
            }
            set {
                internalDouble = newValue
                internalString = newValue?.cleanAmount ?? ""
            }
        }
        
        var string: String {
            get {
                return internalString
            }
            set {
                guard !newValue.isEmpty else {
                    internalDouble = nil
                    internalString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.internalDouble = double
                self.internalString = newValue
            }
        }
        
        var unitDescription: String {
            unit.shortDescription
        }
        
        var isEmpty: Bool {
            double == nil
        }
        
        func textColor(for colorScheme: ColorScheme) -> Color {
//            Color(.tertiaryLabel)
            .gray
        }
    }
}

extension Fill {
    func usesImage(with id: UUID) -> Bool {
        switch self {
        case .scanned(let info):
            return info.imageText.imageId == id
        case .selection(let info):
            return info.usesImage(with: id)
        default:
            return false
        }
    }
}

extension NutrientType {
    var supportedNutrientUnits: [NutrientUnit] {
        var units = units.map {
            $0
        }
        /// Allow percentage values for `mineral`s and `vitamin`s
        if supportsPercentages {
            units.append(.p)
        }
        return units
    }

    //TODO: Do this on a per-group basis
    var supportsPercentages: Bool {
        group?.supportsPercentages ?? false
    }
}

extension NutrientTypeGroup {
    var supportsPercentages: Bool {
        self == .vitamins || self == .minerals
    }
}

//MARK: MacroValue
extension FieldValue {
    struct MacroValue: Hashable, Codable {
        var macro: Macro
        var internalDouble: Double?
        var internalString: String
        var fill: Fill

        init(macro: Macro, double: Double? = nil, string: String = "", fill: Fill = .discardable) {
            self.macro = macro
            self.internalDouble = double
            self.internalString = string
            self.fill = fill
        }
        
        var double: Double? {
            get {
                return internalDouble
            }
            set {
                internalDouble = newValue
                internalString = newValue?.cleanAmount ?? ""
            }
        }
        
        var string: String {
            get {
                return internalString
            }
            set {
                guard !newValue.isEmpty else {
                    internalDouble = nil
                    internalString = newValue
                    return
                }
                
                guard let double = Double(newValue) else {
                    return
                }
                self.internalDouble = double
                self.internalString = newValue
            }
        }
        
        var isEmpty: Bool {
            double == nil
        }
        
        var unitDescription: String {
            NutrientUnit.g.shortDescription
        }
        
        func textColor(for colorScheme: ColorScheme) -> Color {
            macro.textColor(for: colorScheme)
        }
    }
    

}

//MARK: EnergyValue
extension FieldValue {
    struct EnergyValue: Hashable, Codable {
        var internalDouble: Double?
        var internalString: String
        var unit: EnergyUnit
        var fill: Fill

        init(double: Double? = nil, string: String = "", unit: EnergyUnit = .kcal, fill: Fill = .discardable) {
            self.internalDouble = double
            self.internalString = string
            self.unit = unit
            self.fill = fill
        }
        
        var inKcal: Double {
            let double = self.double ?? 0
            return unit.convert(double, to: .kcal)
//            switch unit {
//            case .kcal:
//                return double
//            case .kJ:
//                return double * KcalsPerKilojule
//            }
        }
        
        var double: Double? {
            get {
                return internalDouble
            }
            set {
                internalDouble = newValue
                internalString = newValue?.cleanAmount ?? ""
            }
        }
        
        var string: String {
            get {
                return internalString
            }
            set {
                guard !newValue.isEmpty else {
                    internalDouble = nil
                    internalString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.internalDouble = double
                self.internalString = newValue
            }
        }
    
        var unitDescription: String {
            unit.shortDescription
        }
        
        var isEmpty: Bool {
            double == nil
        }
        
        func textColor(for colorScheme: ColorScheme) -> Color {
            .accentColor
        }
        
    }
}

//MARK: DoubleValue
extension FieldValue {
    struct DoubleValue: Hashable, Codable {
        var internalDouble: Double? = nil
        var internalString: String = ""
        var unit: FormUnit
        var fill: Fill

        init(double: Double? = nil, string: String = "", unit: FormUnit, fill: Fill = .discardable) {
            self.internalDouble = double
            self.internalString = string
            self.unit = unit
            self.fill = fill
        }
        
        var double: Double? {
            get {
                return internalDouble
            }
            set {
                internalDouble = newValue
                internalString = newValue?.cleanAmount ?? ""
            }
        }
        
        var string: String {
            get {
                return internalString
            }
            set {
                guard !newValue.isEmpty else {
                    internalDouble = nil
                    internalString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.internalDouble = double
                self.internalString = newValue
            }
        }
        
        var unitDescription: String {
            unit.shortDescription
        }
        
        var isEmpty: Bool {
            double == nil
        }
    }
}

//MARK: StringValue
extension FieldValue {
    struct StringValue: Hashable, Equatable, Codable {
        private var internalString: String
//        var string: String = ""
        var fill: Fill
        
        init(string: String = "", fill: Fill = .discardable) {
            self.internalString = string
            self.fill = fill
        }
        
        var string: String {
            get {
                switch fill {
                case .selection(let info):
                    return info.concatenatedComponentStrings
                case .prefill(let info):
                    return info.concatenated
                default:
                    return internalString
                }
            }
            set {
                guard newValue != string else {
                    return
                }
                withAnimation {
                    self = .init(string: newValue, fill: .userInput)
                }
            }
        }
        
        var isEmpty: Bool {
            string.isEmpty
        }
    }
}

//MARK: DensityValue
extension FieldValue {
    struct DensityValue: Hashable, Codable {
        var weight: DoubleValue
        var volume: DoubleValue
        var fill: Fill
        
        func description(weightFirst: Bool) -> String {
            if weightFirst {
                return "\(weight.description) ↔ \(volume.description)"
            } else {
                return " \(volume.description) ↔ \(weight.description)"
            }
        }
        
        init(weight: DoubleValue = DefaultWeight,
             volume: DoubleValue = DefaultVolume,
             fill: Fill = .discardable
        ) {
            self.weight = weight
            self.volume = volume
            self.fill = fill
        }
        
        static let DefaultWeight = DoubleValue(unit: .weight(.g))
        static let DefaultVolume = DoubleValue(unit: .volume(.cup))
        
        var isValid: Bool {
            guard let w = weight.double, let v = volume.double else {
                return false
            }
            return w > 0 && v > 0
            && weight.unit.unitType == .weight
            && volume.unit.unitType == .volume
        }
    }
}


//MARK: - Helpers

extension FieldValue {
    init(micronutrient: NutrientType, fill: Fill = .discardable) {
        let microValue = MicroValue(
            nutrientType: micronutrient,
            double: nil,
            string: "",
            unit: micronutrient.units.first ?? .g,
            isIncluded: false,
            fill: fill
        )
        self = .micro(microValue)
    }
}

extension FieldValue {
    var isEnergy: Bool {
        if case .energy = self {
            return true
        }
        return false
    }
    
    var isMacro: Bool {
        if case .macro = self {
            return true
        }
        return false
    }

    func isMacro(_ macro: Macro) -> Bool {
        if case .macro(let macroValue) = self {
            return macroValue.macro == macro
        }
        return false
    }

    
    var isMicro: Bool {
        if case .micro = self {
            return true
        }
        return false
    }
    
    var isBarcode: Bool {
        if case .barcode = self {
            return true
        }
        return false
    }

    func isMicro(_ nutrientType: NutrientType) -> Bool {
        if case .micro(let microValue) = self {
            return microValue.nutrientType == nutrientType
        }
        return false
    }

    var isServing: Bool {
        if case .serving = self {
            return true
        }
        return false
    }

    var isDensity: Bool {
        if case .density = self {
            return true
        }
        return false
    }

    var isAmount: Bool {
        if case .amount = self {
            return true
        }
        return false
    }

    var isSize: Bool {
        if case .size = self {
            return true
        }
        return false
    }
}

extension FieldValue: CustomStringConvertible {
    var description: String {
        switch self {
        case .name:
            return "Name"
        case .detail:
            return "Detail"
        case .emoji:
            return "Emoji"
        case .brand:
            return "Brand"
        case .barcode:
            return "Barcode"
        
        case .amount(let doubleValue):
            switch doubleValue.unit {
            case .weight:
                return "Weight"
            case .volume:
                return "Volume"
            case .serving:
                return "Servings"
            case .size(let size, let volumeUnit):
                return size.namePrefixed(with: volumeUnit)
            }
        case .serving:
            return "Serving Size"
        case .density:
            return "Unit Conversion"

        case .energy:
            return "Energy"
        case .macro(let macroValue):
            return macroValue.macro.description
        case .micro(let microValue):
            return microValue.nutrientType.description
        case .size(let sizeValue):
            return sizeValue.size.fullNameString
        }
    }
}

extension FieldValue {
    var isEmpty: Bool {
        switch self {
        case .name(let stringValue), .detail(let stringValue), .brand(let stringValue), .emoji(let stringValue):
            return stringValue.isEmpty
            
        case .amount(let doubleValue), .serving(let doubleValue):
            return doubleValue.isEmpty
            
        case .density(let density):
            return density == DensityValue()
            
        case .energy(let energyValue):
            return energyValue.isEmpty
            
        case .macro(let macroValue):
            return macroValue.isEmpty
        case .micro(let microValue):
            return microValue.isEmpty
            
        case .size(let sizeValue):
            return sizeValue.size.isEmpty
            
        case .barcode(let barcodeValue):
            return barcodeValue.payloadString.isEmpty
        }
    }
}


extension FieldValue {

    var amountColor: Color {
        isEmpty ? Color(.quaternaryLabel) : Color(.label)
    }
    
    var foodLabelUnit: FoodLabelUnit? {
        get {
            switch self {
            case .energy:
                return self.energyValue.unit.foodLabelUnit
            case .macro:
                return .g
            case .micro:
                return self.microValue.unit.foodLabelUnit
            case .amount(let doubleValue), .serving(let doubleValue):
                return doubleValue.foodLabelUnit
            default:
                return nil
            }
        }
        set {
            switch self {
            case .energy(let energyValue):
                self = .energy(EnergyValue(double: energyValue.double, string: energyValue.string, unit: newValue?.energyUnit ?? .kcal, fill: energyValue.fill))
            default:
                break
//            case .macro(let macroValue):
//                <#code#>
//            case .micro(let microValue):
//                <#code#>
//            case .name(let stringValue):
//                <#code#>
//            case .emoji(let stringValue):
//                <#code#>
//            case .brand(let stringValue):
//                <#code#>
//            case .barcode(let stringValue):
//                <#code#>
//            case .detail(let stringValue):
//                <#code#>
//            case .amount(let doubleValue):
//                <#code#>
//            case .serving(let doubleValue):
//                <#code#>
//            case .density(let densityValue):
//                <#code#>

            }
        }
    }
    
    var string: String {
        get {
            switch self {
            case .name(let stringValue), .emoji(let stringValue), .brand(let stringValue), .detail(let stringValue):
                
                return stringValue.string
                
            case .amount(let doubleValue), .serving(let doubleValue):
                return doubleValue.string
            case .density(_):
                return "(density description goes here)"
            case .energy(let energyValue):
                return energyValue.string
            case .macro(let macroValue):
                return macroValue.string
            case .micro(let microValue):
                return microValue.string
            case .size(let sizeValue):
                return sizeValue.size.name
            case .barcode(let barcodeValue):
                return barcodeValue.payloadString
            }
        }
        set {
            switch self {
            case .energy(let energyValue):
                var newEnergyValue = energyValue
                newEnergyValue.string = newValue
                self = .energy(newEnergyValue)
            case .macro(let macroValue):
                var newMacroValue = macroValue
                newMacroValue.string = newValue
                self = .macro(newMacroValue)
            case .micro(let microValue):
                var newMicrovalue = microValue
                newMicrovalue.string = newValue
                self = .micro(newMicrovalue)
            case .size(let sizeValue):
                var newSizeValue = sizeValue
                newSizeValue.size.name = newValue
                self = .size(newSizeValue)
            case .amount(let doubleValue):
                var newDoubleValue = doubleValue
                newDoubleValue.string = newValue
                self = .amount(newDoubleValue)
            case .serving(let doubleValue):
                var newDoubleValue = doubleValue
                newDoubleValue.string = newValue
                self = .serving(newDoubleValue)
                
            case .name(let stringValue):
                var newStringValue = stringValue
                newStringValue.string = newValue
                self = .name(newStringValue)

            case .detail(let stringValue):
                var newStringValue = stringValue
                newStringValue.string = newValue
                self = .detail(newStringValue)

            case .brand(let stringValue):
                var newStringValue = stringValue
                newStringValue.string = newValue
                self = .brand(newStringValue)
                
            case .barcode(let barcodeValue):
                var newBarcodeValue = barcodeValue
                newBarcodeValue.payloadString = newValue
                self = .barcode(newBarcodeValue)

//            case .emoji(let stringValue):
//                <#code#>
//            case .brand(let stringValue):
//                <#code#>
//            case .barcode(let stringValue):
//                <#code#>
//            case .detail(let stringValue):
//                <#code#>
//            case .amount(let doubleValue):
//                <#code#>
//            case .serving(let doubleValue):
//                <#code#>
//            case .density(let densityValue):
//                <#code#>
            default:
                break
            }
        }
    }
    var value: FoodLabelValue? {
        switch self {
        case .energy, .macro, .micro:
            guard let amount = double else { return nil }
            return FoodLabelValue(amount: amount, unit: foodLabelUnit)
        case .amount(let doubleValue), .serving(let doubleValue):
            return doubleValue.value
        default:
            return nil
        }
    }
    
    var double: Double? {
        get {
            switch self {
            case .energy(let energyValue):
                return energyValue.double
            case .macro(let macroValue):
                return macroValue.double
            case .micro(let microValue):
                return microValue.double
            case .amount(let doubleValue), .serving(let doubleValue):
                return doubleValue.double
            default:
                return nil
            }
        }
        set {
            switch self {
            case .energy(let energyValue):
                self = .energy(EnergyValue(double: newValue, string: newValue?.cleanAmount ?? "", unit: energyValue.unit, fill: energyValue.fill))
            default:
                break
//            case .macro(let macroValue):
//                <#code#>
//            case .micro(let microValue):
//                <#code#>
//            case .name(let stringValue):
//                <#code#>
//            case .emoji(let stringValue):
//                <#code#>
//            case .brand(let stringValue):
//                <#code#>
//            case .barcode(let stringValue):
//                <#code#>
//            case .detail(let stringValue):
//                <#code#>
//            case .amount(let doubleValue):
//                <#code#>
//            case .serving(let doubleValue):
//                <#code#>
//            case .density(let densityValue):
//                <#code#>
            }
        }
    }
    
    
    var iconImageName: String {
        switch self {
        case .energy:
            return "flame.fill"
        case .macro:
            return "circle.circle.fill"
        case .micro:
            return "circle.circle"
        case .density:
            return "arrow.triangle.swap"
//        case .amount(let doubleValue):
//            switch doubleValue.unit {
//            case .weight:
//                return "scalemass"
//            case .volume:
//                return "drop"
//            case .serving:
//                return "fork.knife"
//            case .size:
//                return "rectangle.3.group"
//            }
        default:
            return ""
        }
    }
    
    var amountString: String {
        switch self {
        case .energy(let energyValue):
            return energyValue.double?.cleanAmount ?? "Required"
        case .macro(let macroValue):
            return macroValue.double?.cleanAmount ?? "Required"
        case .micro(let microValue):
            return microValue.double?.cleanAmount ?? "Optional"
        case .amount(let doubleValue):
            return doubleValue.double?.cleanAmount ?? "Required"
        case .serving(let doubleValue):
            return doubleValue.double?.cleanAmount ?? "Optional"
        case .density(let densityValue):
            if densityValue.isValid {
                return densityValue.description(weightFirst: true)
            } else {
                return "Optional"
            }
        default:
            return ""
        }
    }

    var unitString: String {
        switch self {
        case .energy(let energyValue):
            return energyValue.unitDescription
        case .macro(let macroValue):
            return macroValue.unitDescription
        case .micro(let microValue):
            return microValue.unitDescription
        case .amount(let doubleValue), .serving(let doubleValue):
            return doubleValue.unitDescription
        default:
            return ""
        }
    }

    func labelColor(for colorScheme: ColorScheme) -> Color {
        guard !isEmpty else {
            return Color(.tertiaryLabel)
        }
        switch self {
        case .energy(let energyValue):
            return energyValue.textColor(for: colorScheme)
        case .macro(let macroValue):
            return macroValue.textColor(for: colorScheme)
        case .micro(let microValue):
            return microValue.textColor(for: colorScheme)
        case .amount, .serving, .density:
            return Color(.tertiaryLabel)

        default:
            return .gray
        }
    }

    var fill: Fill {
        get {
            switch self {
            case .energy(let energyValue):
                return energyValue.fill
            case .macro(let macroValue):
                return macroValue.fill
            case .micro(let microValue):
                return microValue.fill
            case .name(let stringValue), .emoji(let stringValue), .brand(let stringValue), .detail(let stringValue):
                return stringValue.fill
            case .amount(let doubleValue), .serving(let doubleValue):
                return doubleValue.fill
            case .density(let density):
                return density.fill
            case .size(let sizeValue):
                return sizeValue.fill
            case .barcode(let barcodeValue):
                return barcodeValue.fill
            }
        }
        set {
            switch self {
            case .name(let stringValue):
                self = .name(StringValue(string: stringValue.string, fill: newValue))
            case .emoji(let stringValue):
                self = .emoji(StringValue(string: stringValue.string, fill: newValue))
            case .brand(let stringValue):
                self = .brand(StringValue(string: stringValue.string, fill: newValue))
            case .detail(let stringValue):
                self = .detail(StringValue(string: stringValue.string, fill: newValue))
            case .barcode(let barcodeValue):
                self = .barcode(BarcodeValue(
                    payloadString: barcodeValue.payloadString,
                    symbology: barcodeValue.symbology,
                    fill: newValue)
                )
            case .amount(let doubleValue):
                self = .amount(DoubleValue(
                    double: doubleValue.double,
                    string: doubleValue.string,
                    unit: doubleValue.unit,
                    fill: newValue)
                )
            case .serving(let doubleValue):
                self = .serving(DoubleValue(
                    double: doubleValue.double,
                    string: doubleValue.string,
                    unit: doubleValue.unit,
                    fill: newValue)
                )
            case .density(let densityValue):
                self = .density(DensityValue(
                    weight: densityValue.weight,
                    volume: densityValue.volume,
                    fill: newValue)
                )
            case .energy(let energyValue):
                self = .energy(EnergyValue(
                    double: energyValue.double,
                    string: energyValue.string,
                    unit: energyValue.unit,
                    fill: newValue)
                )
            case .macro(let macroValue):
                self = .macro(MacroValue(
                    macro: macroValue.macro,
                    double: macroValue.double,
                    string: macroValue.string,
                    fill: newValue)
                )
            case .micro(let microValue):
                self = .micro(MicroValue(
                    nutrientType: microValue.nutrientType,
                    double: microValue.double,
                    string: microValue.string,
                    unit: microValue.unit,
                    fill: newValue)
                )
            case .size(let sizeValue):
                self = .size(SizeValue(size: sizeValue.size, fill: newValue))
            }
        }
    }
    
    var supportsSelectingText: Bool {
        switch self {
        case .size:
            return false
        default:
            return true
        }
    }
}


extension FieldValue {
    var doubleValue: DoubleValue {
        get {
            switch self {
            case .amount(let doubleValue), .serving(let doubleValue):
                return doubleValue
            default:
                return DoubleValue(unit: .weight(.g))
            }
        }
        set {
            switch self {
            case .amount:
                self = .amount(newValue)
            case .serving:
                self = .serving(newValue)
            default:
                break
            }
        }
    }
    
    var barcodeValue: BarcodeValue? {
        get {
            switch self {
            case .barcode(let barcodeValue):
                return barcodeValue
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch self {
            case .barcode:
                self = .barcode(newValue)
            default:
                break
            }
        }
    }
    
    var stringValue: StringValue {
        get {
            switch self {
            case .name(let stringValue), .detail(let stringValue), .brand(let stringValue), .emoji(let stringValue):
                return stringValue
            default:
                return StringValue()
            }
        }
        set {
            switch self {
            case .name:
                self = .name(newValue)
            case .brand:
                self = .brand(newValue)
            case .emoji:
                self = .emoji(newValue)
            case .detail:
                self = .detail(newValue)
            default:
                break
            }
        }
    }
    
    var energyValue: EnergyValue {
        get {
            switch self {
            case .energy(let energyValue):
                return energyValue
            default:
                return EnergyValue()
            }
        }
        set {
            switch self {
            case .energy:
                self = .energy(newValue)
            default:
                break
            }
        }
    }
    
    var macroValue: MacroValue {
        get {
            switch self {
            case .macro(let macroValue):
                return macroValue
            default:
                return MacroValue(macro: .carb)
            }
        }
        set {
            switch self {
            case .macro:
                self = .macro(newValue)
            default:
                break
            }
        }
    }

    var microValue: MicroValue {
        get {
            switch self {
            case .micro(let microValue):
                return microValue
            default:
                return MicroValue(nutrientType: .addedSugars)
            }
        }
        set {
            switch self {
            case .micro:
                self = .micro(newValue)
            default:
                break
            }
        }
    }

    var densityValue: DensityValue? {
        switch self {
        case .density(let densityValue):
            return densityValue
        default:
            return DensityValue()
        }
    }
    
    var weight: DoubleValue {
        get {
            switch self {
            case .density(let density):
                return density.weight
            default:
                return DensityValue.DefaultWeight
            }
        }
        set {
            switch self {
            case .density(let density):
                self = .density(
                    DensityValue(
                        weight: newValue,
                        volume: density.volume,
                        fill: density.fill
                    ))
            default:
                break
            }
        }
    }
    
    var volume: DoubleValue {
        get {
            switch self {
            case .density(let density):
                return density.volume
            default:
                return DensityValue.DefaultVolume
            }
        }
        set {
            switch self {
            case .density(let density):
                self = .density(DensityValue(weight: density.weight, volume: newValue, fill: density.fill))
            default:
                break
            }
        }
    }
    
    //MARK: - Helpers
    
    var usesValueBasedTexts: Bool {
        switch self {
        case .amount, .serving, .density, .energy, .macro, .micro, .size:
            return true
        default:
            return false
        }
    }
    
    /**
     Returns `true` if there can only be one of this field for any given food.
     
     This returns `true` for `.macro` and `.macro` as it considers them along with their `Macro` or `NutrientType` identifiers.
     */
    var isOneToOne: Bool {
        switch self {
        case .name, .emoji, .brand, .detail, .amount, .serving, .density, .energy, .macro, .micro:
            return true
        case .size, .barcode:
            return false
        }
    }
    
    var isOneToMany: Bool {
        !isOneToOne
    }
}

extension FieldValue: Equatable {
    static func ==(lhs: FieldValue, rhs: FieldValue) -> Bool {
        switch (lhs, rhs) {
        case (.name(let lhsValue), .name(let rhsValue)):
            return lhsValue == rhsValue
        case (.emoji(let lhsValue), .emoji(let rhsValue)):
            return lhsValue == rhsValue
        case (.brand(let lhsValue), .brand(let rhsValue)):
            return lhsValue == rhsValue
        case (.barcode(let lhsValue), .barcode(let rhsValue)):
            return lhsValue == rhsValue
        case (.detail(let lhsValue), .detail(let rhsValue)):
            return lhsValue == rhsValue
        case (.amount(let lhsValue), .amount(let rhsValue)):
            return lhsValue == rhsValue
        case (.serving(let lhsValue), .serving(let rhsValue)):
            return lhsValue == rhsValue
        case (.density(let lhsValue), .density(let rhsValue)):
            return lhsValue == rhsValue
        case (.energy(let lhsValue), .energy(let rhsValue)):
            return lhsValue == rhsValue
        case (.macro(let lhsValue), .macro(let rhsValue)):
            return lhsValue == rhsValue
        case (.micro(let lhsValue), .micro(let rhsValue)):
            return lhsValue == rhsValue
        case (.size(let lhsValue), .size(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

//MARK: - To be moved
func randomFoodEmoji() -> String {
    let foodEmojis = "🍇🍈🍉🍊🍋🍌🍍🥭🍎🍏🍐🍑🍒🍓🫐🥝🍅🫒🥥🥑🍆🥔🥕🌽🌶️🫑🥒🥬🥦🧄🧅🍄🥜🫘🌰🍞🥐🥖🫓🥨🥯🥞🧇🧀🍖🍗🥩🥓🍔🍟🍕🌭🥪🌮🌯🫔🥙🧆🥚🍳🥘🍲🫕🥣🥗🍿🧈🧂🥫🍱🍘🍙🍚🍛🍜🍝🍠🍢🍣🍤🍥🥮🍡🥟🥠🥡🦪🍦🍧🍨🍩🍪🎂🍰🧁🥧🍫🍬🍭🍮🍯🍼🥛☕🫖🍵🍶🍾🍷🍸🍹🍺🍻🥂🥃🫗🥤🧋🧃🧉🧊🥢🍽️🍴🥄"
    guard let character = foodEmojis.randomElement() else {
        return "🥕"
    }
    return String(character)
}

