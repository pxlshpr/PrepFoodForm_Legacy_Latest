import Foundation
import PrepDataTypes
import VisionSugar
import MFPScraper
import FoodLabelScanner
import Vision
import AVKit
import SwiftUI

let FormFooterFilledColor = Color(.secondaryLabel)
let FormFooterEmptyColor = Color(.secondaryLabel)
let WizardAnimation = Animation.easeIn(duration: 0.2)

extension NutrientType {
    func matchesSearchString(_ string: String) -> Bool {
        description.lowercased().contains(string.lowercased())
    }
}

extension NutrientTypeGroup {
    var nutrients: [NutrientType] {
        NutrientType.allCases.filter({ $0.group == self })
    }
}

extension FieldValue.MicroValue {
    func matchesSearchString(_ string: String) -> Bool {
        nutrientType.matchesSearchString(string)
    }
}

/// This was created to populate fill options for sizes, but is currently unused
extension RecognizedText {
    /// Returns the first `Size` that can be extracted from this text
    var size: FormSize? {
        nil
//        servingArtefacts.count > 0
    }
}

import PrepDataTypes

extension RecognizedText {
    var densityValue: FieldValue.DensityValue? {
        string.detectedValues.densityValue
    }
}

extension Array where Element == FoodLabelValue {
    var firstWeightValue: FoodLabelValue? {
        first(where: { $0.unit?.unitType == .weight })
    }
    
    var firstVolumeValue: FoodLabelValue? {
        first(where: { $0.unit?.unitType == .volume })
    }

    var densityValue: FieldValue.DensityValue? {
        guard let weightDoubleValue, let volumeDoubleValue else {
            return nil
        }
        return FieldValue.DensityValue(
            weight: weightDoubleValue,
            volume: volumeDoubleValue,
            fill: .discardable
        )
    }
    
    var weightDoubleValue: FieldValue.DoubleValue? {
        firstWeightValue?.asDoubleValue
    }
    var volumeDoubleValue: FieldValue.DoubleValue? {
        firstVolumeValue?.asDoubleValue
    }
}

extension FoodLabelValue {
    var asDoubleValue: FieldValue.DoubleValue? {
        guard let formUnit = unit?.formUnit else { return nil }
        return FieldValue.DoubleValue(
            double: amount,
            string: amount.cleanAmount,
            unit: formUnit,
            fill: .discardable
        )
    }
}

extension FieldValue.MicroValue {
    var convertedFromPercentage: (amount: Double, unit: NutrientUnit)? {
        guard let double, unit == .p else {
            return nil
        }
        return nutrientType.convertRDApercentage(double)
    }
}


extension Array where Element == Field {
    func containsSizeNamed(_ name: String) -> Bool {
        contains(where: { $0.isSizeNamed(name) })
    }
}

extension Field {
    func isSizeNamed(_ name: String) -> Bool {
        size?.name == name
    }
}

extension Field {
    var doubleValueDescription: String {
        guard !value.isEmpty else {
            return ""
        }
        return "\(value.doubleValue.string) \(value.doubleValue.unitDescription)"
    }
}

extension FormSize {
    var asFieldViewModelForUserInput: Field {
        Field(fieldValue: .size(.init(size: self, fill: .userInput)))
    }
}

extension FieldValue {
    var size: FormSize? {
        get {
            switch self {
            case .size(let sizeValue):
                return sizeValue.size
            default:
                return nil
            }
        }
        set {
            guard let newValue else {
                return
            }
            switch self {
            case .size(let sizeValue):
                self = .size(.init(size: newValue, fill: sizeValue.fill))
            default:
                break
            }
        }
    }
}

extension FoodLabelUnit {
    var formUnit: FormUnit? {
        switch self {
        case .cup:
            return .volume(.cup)
        case .mg:
            return .weight(.mg)
        case .kj:
            return .weight(.kg)
        case .g:
            return .weight(.g)
        case .oz:
            return .weight(.oz)
        case .ml:
            return .volume(.mL)
        case .tbsp:
            return .volume(.tablespoon)
        default:
            return nil
        }
    }
}

extension ScanResult.Nutrients.Row {
    func valueText(at column: Int) -> ValueText? {
        column == 1 ? valueText1 : valueText2
    }
    
    func value(at column: Int) -> FoodLabelValue? {
        column == 1 ? value1 : value2
    }
}

extension FoodLabelUnit {
    func nutrientUnit(for nutrientType: NutrientType) -> NutrientUnit? {
        switch self {
        case .mcg:
            return .mcg
        case .mg:
            return .mg
        case .g:
            return .g
        case .p:
            return .p
//        case .iu:
//            return .IU
        default:
            return nil
        }
    }
    var energyUnit: EnergyUnit {
        switch self {
        case .kcal:
            return .kcal
        case .kj:
            return .kJ
        default:
            return .kcal
        }
    }
}

extension Attribute {
    var macro: Macro? {
        switch self {
        case .carbohydrate: return .carb
        case .fat: return .fat
        case .protein: return .protein
        default: return nil
        }
    }
}

extension Macro {
    var attribute: Attribute {
        switch self {
        case .carb:
            return .carbohydrate
        case .fat:
            return .fat
        case .protein:
            return .protein
        }
    }
}

//extension NutrientType {
//    var attribute: Attribute? {
//        switch self {
//        case .saturatedFat:
//            return .saturatedFat
//        case .monounsaturatedFat:
//            return .monounsaturatedFat
//        case .polyunsaturatedFat:
//            return .polyunsaturatedFat
//        case .transFat:
//            return .transFat
//        case .cholesterol:
//            return .cholesterol
//        case .dietaryFiber:
//            return .dietaryFibre
//        case .solubleFiber:
//            return .solubleFibre
//        case .insolubleFiber:
//            return .insolubleFibre
//        case .sugars:
//            return .sugar
//        case .addedSugars:
//            return .addedSugar
//        case .calcium:
//            return .calcium
//        case .chromium:
//            return .chromium
//        case .iodine:
//            return .iodine
//        case .iron:
//            return .iron
//        case .magnesium:
//            return .magnesium
//        case .manganese:
//            return .manganese
//        case .potassium:
//            return .potassium
//        case .selenium:
//            return .selenium
//        case .sodium:
//            return .sodium
//        case .zinc:
//            return .zinc
//        case .vitaminA:
//            return .vitaminA
//        case .vitaminB6:
//            return .vitaminB6
//        case .vitaminB12:
//            return .vitaminB12
//        case .vitaminC:
//            return .vitaminC
//        case .vitaminD:
//            return .vitaminD
//        case .vitaminE:
//            return .vitaminE
//        case .vitaminK:
//            return .vitaminK
//        case .biotin:
//            return .biotin
//        case .folate:
//            return .folate
//        case .niacin:
//            return .niacin
//        case .pantothenicAcid:
//            return .pantothenicAcid
//        case .riboflavin:
//            return .riboflavin
//        case .thiamin:
//            return .thiamin
//        case .vitaminB2:
//            return .vitaminB2
//        case .cobalamin:
//            return .cobalamin
//        case .folicAcid:
//            return .folicAcid
//        case .vitaminB1:
//            return .vitaminB1
//        case .vitaminB3:
//            return .vitaminB3
//        case .vitaminK2:
//            return .vitaminK2
//        case .caffeine:
//            return .caffeine
//        case .taurine:
//            return .taurine
//        case .polyols:
//            return .polyols
//        case .gluten:
//            return .gluten
//        case .starch:
//            return .starch
//        case .salt:
//            return .salt
//
//        default:
//            return nil
//        }
//    }
//}

import VisionSugar

let defaultUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
let defaulText = RecognizedText(id: defaultUUID, rectString: "", boundingBoxString: nil, candidates: [])

extension ScanResult {
    static var mockServing: ScanResult {
        
        let serving = ScanResult.Serving(
            amountText: DoubleText(double: 1,
                                   text: defaulText, attributeText: defaulText),
            unitText: nil,
            unitNameText: StringText(string: "pack",
                                     text: defaulText, attributeText: defaulText),
            equivalentSize: Serving.EquivalentSize(
                amountText: DoubleText(
                    double: 3,
                    text: defaulText, attributeText: defaulText),
                unitText: nil,
                unitNameText: StringText(
                    string: "pieces",
                    text: defaulText, attributeText: defaulText)
            ),
            perContainer: nil
        )
        
        return ScanResult(
            serving: serving,
            headers: nil,
            nutrients: Nutrients(rows: []),
            texts: [],
            barcodes: []
        )
    }
}

extension Field {
    var string: String {
        value.string
    }
    
    var stringIfNotEmpty: String? {
        string.isEmpty ? nil : string
    }
}

extension Field {
    var nutrientType: NutrientType? {
        value.microValue.nutrientType
    }
}

extension AmountUnit {
    func formUnit(withSize size: FormSize? = nil) -> FormUnit {
        switch self {
        case .weight(let weightUnit):
            return .weight(weightUnit)
        case .volume(let volumeUnit):
            return .volume(volumeUnit)
        case .serving:
            return .serving
        case .size:
            /// We should have had a size (pre-created from the actual `MFPProcessedFood.Size`) and passed into this function—otherwise fallback to a serving unit
            guard let size else {
                return .serving
            }
            return .size(size, nil)
        }
    }
}

extension ServingUnit {
    func formUnit(withSize size: FormSize? = nil) -> FormUnit {
        switch self {
        case .weight(let weightUnit):
            return .weight(weightUnit)
        case .volume(let volumeUnit):
            return .volume(volumeUnit)
        case .size:
            /// We should have had a size (pre-created from the actual `MFPProcessedFood.Size`) and passed into this function—otherwise fallback to a default unit
            guard let size else {
                return .weight(.g)
            }
            return .size(size, .cup)
        }
    }
}


//TODO: Write an extension on FieldValue or RecognizedText that provides alternative `FoodLabelValue`s for a specific type of `FieldValue`—so if its energy and we have a number, return it as the value with both units, or the converted value in kJ or kcal. If its simply a macro/micro value—use the stuff where we move the decimal place back or forward or correct misread values such as 'g' for '9', 'O' for '0' and vice versa.



extension Field {
    var barcodeValue: FieldValue.BarcodeValue? {
        value.barcodeValue
    }
}

extension VNBarcodeSymbology {

    var preferenceRank: Int {
        switch self {
        case .code128: return 1
        case .upce: return 1
        case .code39: return 1
        case .ean8: return 1
        case .ean13: return 1
        case .code93: return 1
        case .pdf417: return 1
        case .qr: return 2
        case .aztec: return 3
        default:
            return 4
        }
    }
    
    var objectType: AVMetadataObject.ObjectType {
        switch self {
        case .code128: return .code128
        case .upce: return .upce
        case .code39: return .code39
        case .ean8: return .ean8
        case .ean13: return .ean13
        case .code93: return .code93
        case .pdf417: return .pdf417
        case .qr: return .qr
        case .aztec: return .aztec
        default:
            return .code128
        }
    }
}

extension Field {
    var size: FormSize? {
        value.size
    }

    var fill: Fill {
        value.fill
    }

    var sizeVolumePrefixString: String {
        sizeVolumePrefixUnit.shortDescription
    }
    
    var sizeAmountUnitString: String {
        sizeAmountUnit.shortDescription
    }
    var sizeNameString: String {
        size?.name ?? ""
    }
    
    var sizeAmountDescription: String {
        guard let amount = size?.amount, amount > 0 else {
            return ""
        }
        return "\(amount.cleanAmount) \(sizeAmountUnitString)"
    }
    
    var sizeAmountString: String {
        get {
            size?.amountString ?? ""
        }
        set {
            guard let size = self.size else {
                return
            }
            var newSize = size
            newSize.amountString = newValue
            self.value = .size(.init(size: newSize, fill: value.fill))
        }
    }
    var sizeVolumePrefixUnit: FormUnit {
        size?.volumePrefixUnit ?? .volume(.cup)
    }
    
    var sizeQuantityString: String {
        get {
            size?.quantityString ?? "1"
        }
        set {
            guard let size = self.size else {
                return
            }
            var newSize = size
            newSize.quantityString = newValue
            self.value = .size(.init(size: newSize, fill: value.fill))
        }
    }
    
    var sizeQuantity: Double {
        get {
            size?.quantity ?? 1
        }
        set {
            guard let size = self.size else { return }
            var newSize = size
            newSize.quantity = newValue
            newSize.quantityString = newValue.cleanAmount
            self.value = .size(.init(size: newSize, fill: value.fill))
        }
    }
    
    var sizeAmountUnit: FormUnit {
        get {
            size?.unit ?? .serving
        }
        set {
            guard let size = self.size else { return }
            var newSize = size
            newSize.unit = newValue
            self.value = .size(.init(size: newSize, fill: value.fill))
        }
    }
    
    var sizeAmountIsValid: Bool {
        guard let amount = size?.amount, amount > 0 else {
            return false
        }
        return true
    }

}

extension ScanResult {
    var headerTitle1: String {
        guard let headerType = headers?.header1Type else {
            return "Column 1"
        }
        return headerType.description.replacingFirstOccurrence(of: "Per ", with: "")
    }
    var headerTitle2: String {
        guard let headerType = headers?.header2Type else {
            return "Column 2"
        }
        return headerType.description.replacingFirstOccurrence(of: "Per ", with: "")
    }
}

extension ScanResult {
    var dataPointsCount: Int {
        var count = nutrientsCount
        if serving?.amount != nil {
            count += 1
        }
        let count1 = allSizeViewModels(at: 1).count
        let count2 = allSizeViewModels(at: 2).count
        count += max(count1, count2)
//        if let serving {
//            if serving.amount != nil {
//                count += 1
//            }
//            if serving.perContainer != nil {
//                count += 1
//            }
//            if serving.equivalentSize != nil {
//                count += 1
//            }
//        }
//        if let headers {
//
//            if headers.header1Type != nil {
//                count += 1
//            }
//            if headers.header2Type != nil {
//                count += 1
//            }
//        }
        if densityFieldValue != nil {
            count += 1
        }
        count += barcodes.count
        return count
    }
}

extension ImageViewModel {    
    func writeImage(to directoryUrl: URL) async throws {
        guard let imageData else { return }
        let imageUrl = directoryUrl.appending(component: "\(id).jpg")
        try imageData.write(to: imageUrl)
    }
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
   
   let widthRatio  = targetSize.width  / size.width
   let heightRatio = targetSize.height / size.height
   
   // Figure out what our orientation is, and use that to form the rectangle
   var newSize: CGSize
   if(widthRatio > heightRatio) {
       newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
   } else {
       newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
   }
   
   // This is the rect that we've calculated out and this is what is actually used below
   let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
   
   // Actually do the resizing to the rect using the ImageContext stuff
   UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
   image.draw(in: rect)
   let newImage = UIGraphicsGetImageFromCurrentImageContext()
   UIGraphicsEndImageContext()
   
   return newImage!
}

import MFPScraper

extension FieldValue {
    var prefillFieldStrings: [PrefillFieldString] {
        guard case .prefill(let info) = fill, info.fieldStrings.count == 1 else {
            return []
        }
        return info.fieldStrings
    }
    
    func shouldSelectFieldValue(_ prefillFieldValue: FieldValue) -> Bool {
        
        /// If this is a size—check if they match up
        guard !self.isSize else {
            return self.size == prefillFieldValue.size
        }
        
        /// If this a value based text (which would only ever have one prefill)—return true if its a prefill fill
        guard !self.usesValueBasedTexts else {
            return fill.isPrefill
        }
        
        guard case .prefill(let info) = fill, let fieldString = prefillFieldValue.prefillFieldStrings.first
        else {
            return false
        }
        return info.fieldStrings.contains(fieldString)
    }
}

extension PrefillFieldString: Equatable {
    /// Doesn't care about text case when comparing
    static func ==(lhs: PrefillFieldString, rhs: PrefillFieldString) -> Bool {
        lhs.string.lowercased() == rhs.string.lowercased()
        && lhs.field == rhs.field
    }
}

extension Fill {
    func replacingSinglePrefillString(with string: String) -> Fill {
        guard isPrefill,
              case .prefill(let prefillFillInfo) = self,
              let fieldString = prefillFillInfo.fieldStrings.first
        else {
            return self
        }
        let copy = PrefillFieldString(string: string, field: fieldString.field)
        return Fill.prefill(.init(fieldStrings: [copy]))
    }
}
extension FieldValue {
    func replacingString(with string: String) -> FieldValue {
        var copy = self
        copy.string = string
        copy.fill = fill.replacingSinglePrefillString(with: string)
        return copy
    }
}

extension FieldValue {
    var stringComponentFieldValues: [FieldValue] {
        var fieldValues: [FieldValue] = []
        for component in string.selectionComponents {
            fieldValues.append(replacingString(with: component))
        }
        return fieldValues
    }
}

extension String {
    var selectionComponents: [String] {
        self
        .components(separatedBy: ",")
        .map {
            $0
                .trimmingWhitespaces
                .components(separatedBy: " ")
                .filter { !$0.isEmpty }
                .map { $0.capitalized.capitalizedIfUppercase }
        }
        .reduce([], +)
    }
}

import SwiftSugar

extension MFPProcessedFood {
    var stringBasedFieldValues: [FieldValue] {
        var componentFieldValues: [FieldValue] = []
        let fieldValues = [nameFieldValue, detailFieldValue, brandFieldValue].compactMap { $0 }
        for fieldValue in fieldValues {
            componentFieldValues.append(contentsOf: fieldValue.stringComponentFieldValues)
        }
        return componentFieldValues
    }
    
    var nameFieldStrings: [PrefillFieldString] {
        name
            .selectionComponents
            .map { PrefillFieldString(string: $0, field: .name) }
    }
    var nameFieldValue: FieldValue? {
        guard !name.isEmpty else {
            return nil
        }
//        let fieldString = PrefillFieldString(string: name, field: .name)
        let fill = Fill.prefill(.init(fieldStrings: nameFieldStrings))
        return FieldValue.name(FieldValue.StringValue(string: name, fill: fill))
    }
    
    var detailFieldValue: FieldValue? {
        guard let detail, !detail.isEmpty else {
            return nil
        }
        let fieldString = PrefillFieldString(string: detail, field: .detail)
        let fill = Fill.prefill(.init(fieldStrings: [fieldString]))
        return FieldValue.detail(FieldValue.StringValue(string: detail, fill: fill))
    }
    
    var brandFieldValue: FieldValue? {
        guard let brand, !brand.isEmpty else {
            return nil
        }
        let fieldString = PrefillFieldString(string: brand, field: .brand)
        let fill = Fill.prefill(.init(fieldStrings: [fieldString]))
        return FieldValue.brand(FieldValue.StringValue(string: brand, fill: fill))
    }

    var densityFieldValue: FieldValue? {
        guard let densitySize = sizes.first(where: { $0.isDensity }),
              let volumeUnit = densitySize.prefixVolumeUnit else  {
            return nil
        }
        
        return FieldValue.density(FieldValue.DensityValue(
            weight: .init(
                double: densitySize.amount,
                string: densitySize.amount.cleanAmount,
                unit: densitySize.amountUnit.formUnit,
                fill: .prefill()),
            volume: .init(
                double: densitySize.quantity,
                string: densitySize.quantity.cleanAmount,
                unit: volumeUnit.formUnit,
                fill: .prefill()),
            fill: .prefill()
        ))
    }
    
    var sizeFieldValues: [FieldValue] {
        sizes.compactMap { $0.sizeFieldValue }
    }
}

extension MFPProcessedFood.Size {
    var sizeFieldValue: FieldValue? {
        guard let prepSize else { return nil }
        return FieldValue.size(.init(
            size: prepSize,
            fill: .prefill(.init(size: prepSize))
        ))
    }
    
    var prepSize: FormSize? {
        guard !isDensity else { return nil }
        return FormSize(
            quantity: quantity,
            volumePrefixUnit: prefixVolumeUnit?.formUnit,
            name: name.lowercased(),
            amount: amount,
            unit: amountUnit.formUnit
        )
    }
}


extension MFPProcessedFood.Size {
    var size: FormSize {
        FormSize(
            quantity: quantity,
            volumePrefixUnit: prefixVolumeUnit?.formUnit,
            name: name.lowercased(),
            amount: amount,
            unit: amountUnit.formUnit
        )
    }
    
    var fieldValue: FieldValue {
        size.fieldValue
    }
    
    var isVolumePrefixed: Bool {
        prefixVolumeUnit != nil
    }
}

extension FormSize {
    var fieldValue: FieldValue {
        .size(FieldValue.SizeValue(
            size: self,
            fill: .prefill())
        )
    }
}

extension AmountUnit {
    var formUnit: FormUnit {
        switch self {
        case .weight(let weightUnit):
            return .weight(weightUnit)
        case .volume(let volumeUnit):
            return .volume(volumeUnit)
        case .serving:
            return .serving
        case .size(let processedSize):
            return .size(processedSize.size, nil)
        }
    }
    
    var weightUnit: WeightUnit? {
        switch self {
        case .weight(let weightUnit):
            return weightUnit
        default:
            return nil
        }
    }
}
extension VolumeUnit {
    var formUnit: FormUnit {
        .volume(self)
    }
}


extension ImageViewModel {
    func saveScanResultToJson() {
        guard let scanResult else {
            return
        }
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(scanResult)
            
            if var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                url.appendPathComponent("scanResult.json")
                try data.write(to: url)
                print("📝 Wrote scanResult to: \(url)")
            }
        } catch {
            print(error)
        }
    }
}

extension MFPProcessedFood {
    func saveToJson() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            
            if var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                url.appendPathComponent("mfpProcessedFood.json")
                try data.write(to: url)
                print("📝 Wrote mfpProcessedFood to: \(url)")
            }
        } catch {
            print(error)
        }
    }
}

extension FormSize {
    func conflictsWith(_ otherSize: FormSize) -> Bool {
        self.name.lowercased() == otherSize.name.lowercased()
        && self.volumePrefixUnit == otherSize.volumePrefixUnit
    }
}


extension String {
    var energyValue: FoodLabelValue? {
        let values = FoodLabelValue.detect(in: self)
        /// Returns the first energy value detected, otherwise the first value regardless of the unit
        let value = values.first(where: { $0.unit?.isEnergy == true }) ?? values.first
        
        if let value, value.unit != .kj {
            ///  Always set the unit to kcal as a fallback for energy values
            return FoodLabelValue(amount: value.amount, unit: .kcal)
        }
        
        /// This would either be `nil` for `FoodLabelValue` with an energy unit
        return value
    }
    
    var energyValueDescription: String {
        guard let energyValue else { return "" }
        
        /// If the found `energyValue` actually has an energy unit—return its entire description, otherwise only return the number
        if energyValue.unit?.isEnergy == true {
            return energyValue.description
        } else {
            return "\(energyValue.amount.cleanAmount) kcal"
        }
    }
}

extension FieldValue.DensityValue {
    /// Checks if two `DensityValue`s are equal, disregarding the `Fill`
    func equalsValues(of other: FieldValue.DensityValue) -> Bool {
        weight.equalsValues(of: other.weight)
        && volume.equalsValues(of: other.volume)
    }
}

extension FieldValue.DoubleValue {
    /// Checks if two `DoubleValue`s are equal, disregarding the `Fill`
    func equalsValues(of other: FieldValue.DoubleValue) -> Bool {
        double == other.double
        && unit == other.unit
    }
}


extension Fill {
    var densityValue: FieldValue.DensityValue? {
        switch self {
        case .scanned(let scannedFillInfo):
            return scannedFillInfo.densityValue
        case .selection(let selectionFillInfo):
            return selectionFillInfo.densityValue
        case .prefill(let prefillFillInfo):
            return prefillFillInfo.densityValue
        default:
            return nil
        }
    }
}

extension FillOption {
    var foodLabelValue: FoodLabelValue? {
        switch self.type {
        case .fill(let fill):
            return fill.value
        default:
            return nil
        }
    }
}

extension Array where Element == FillOption {
    func removingFillOptionValueDuplicates() -> [Element] {
        var uniqueDict = [FoodLabelValue: Bool]()

        return filter {
            guard let key = $0.foodLabelValue else { return true }
            return uniqueDict.updateValue(true, forKey: key) == nil
        }
    }

    mutating func removeFillOptionValueDuplicates() {
        self = self.removingFillOptionValueDuplicates()
    }
}

extension FieldValue {
    func equalsScannedFieldValue(_ other: FieldValue) -> Bool {
        switch self {
        case .amount, .serving, .energy, .macro, .micro:
            return value == other.fill.value
        case .density(let densityValue):
            return densityValue == other.densityValue
        case .size(let sizeValue):
            return sizeValue.size == other.size
        default:
            return false
        }
    }
}

import VisionSugar

extension UIImage {
    func cropped(boundingBox: CGRect) async -> UIImage? {
        let cropRect = boundingBox.rectForSize(size)
        let image = fixOrientationIfNeeded()
        return cropImage(imageToCrop: image, toRect: cropRect)
    }
    
    func cropImage(imageToCrop: UIImage, toRect rect: CGRect) -> UIImage? {
        guard let imageRef = imageToCrop.cgImage?.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: imageRef)
    }
}

extension CGRect {
    var zoomedOutBoundingBox: CGRect {
        let d = min(height, width)
        let x = max(0, minX-d)
        let y = max(0, minY-d)
        let width = min((maxX) + d, 1) - x
        let height = min((maxY) + d, 1) - y
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

import SwiftUI

struct AutofillInfoSheet: View {
    var body: some View {
        Text("Talk about autofill here")
    }
}


//MARK: - Upload related

extension FieldValue.DensityValue {
    var foodDensity: FoodDensity? {
        guard let weightAmount = weight.double,
              let volumeAmount = volume.double,
              let weightUnit = weight.unit.weightUnit,
              let volumeExplicitUnit = volume.unit.volumeUnit?.volumeExplicitUnit
        else {
            return nil
        }
        return FoodDensity(
            weightAmount: weightAmount,
            weightUnit: weightUnit,
            volumeAmount: volumeAmount,
            volumeExplicitUnit: volumeExplicitUnit
        )
    }
}

extension FormSize {
    
    var foodValue: FoodValue? {
        guard let amount else { return nil }
        return FoodValue(value: amount, formUnit: unit)
    }
}

extension FieldValue {
    var energyInKcal: Double? {
        guard let value = energyValue.double else { return nil }
        if energyValue.unit == .kcal {
            return value
        } else {
            return value * KcalsPerKilojule
        }
    }
    
    var macroDouble: Double? {
        macroValue.double
    }
    var foodBarcode: FoodBarcode? {
        guard let barcodeValue, let symbology = barcodeValue.barcodeSymbology else {
            return nil
        }
        return FoodBarcode(
            payload: barcodeValue.payloadString,
            symbology: symbology
        )
    }
}
extension FoodValue {

    init?(fieldValue: FieldValue) {
        let doubleValue = fieldValue.doubleValue
        let unit = doubleValue.unit
        guard let value = doubleValue.double else {
            return nil
        }
        self.init(value: value, formUnit: unit)
    }

    init(value: Double, formUnit: FormUnit) {
        let unitType = formUnit.unitType
        let weightUnit = formUnit.weightUnit
        let volumeExplicitUnit = formUnit.volumeUnit?.volumeExplicitUnit
        let sizeUnitId = formUnit.formSize?.id
        let sizeUnitVolumePrefixExplicitUnit = formUnit.sizeUnitVolumePrefixUnit?.volumeExplicitUnit
        
        self.init(
            value: value,
            unitType: unitType,
            weightUnit: weightUnit,
            volumeExplicitUnit: volumeExplicitUnit,
            sizeUnitId: sizeUnitId,
            sizeUnitVolumePrefixExplicitUnit: sizeUnitVolumePrefixExplicitUnit
        )
    }
}

extension FieldValue.BarcodeValue {
    var barcodeSymbology: PrepDataTypes.BarcodeSymbology? {
        switch symbology {
        case .aztec:
            return .aztec
        case .code39:
            return .code39
        case .code39Checksum:
            return .code39Checksum
        case .code39FullASCII:
            return .code39FullASCII
        case .code39FullASCIIChecksum:
            return .code39FullASCIIChecksum
        case .code93:
            return .code93
        case .code93i:
            return .code93i
        case .code128:
            return .code128
        case .dataMatrix:
            return .dataMatrix
        case .ean8:
            return .ean8
        case .ean13:
            return .ean13
        case .i2of5:
            return .i2of5
        case .i2of5Checksum:
            return .i2of5Checksum
        case .itf14:
            return .itf14
        case .pdf417:
            return .pdf417
        case .qr:
            return .qr
        case .upce:
            return .upce
        case .codabar:
            return .codabar
        case .gs1DataBar:
            return .gs1DataBar
        case .gs1DataBarExpanded:
            return .gs1DataBarExpanded
        case .gs1DataBarLimited:
            return .gs1DataBarLimited
        case .microPDF417:
            return .microPDF417
        case .microQR:
            return .microQR
        default:
            return nil
        }
    }
}

extension VolumeUnit {
    //TODO: Choose these based on user settings, to be provided to FoodViewModel upon creating the form
    var volumeExplicitUnit: VolumeExplicitUnit {
        switch self {
        case .gallon:
            return VolumeExplicitUnit.gallonUSLiquid
        case .quart:
            return VolumeExplicitUnit.quartUSLiquid
        case .pint:
            return VolumeExplicitUnit.pintUSLiquid
        case .cup:
            return VolumeExplicitUnit.cupUSLegal
        case .fluidOunce:
            return VolumeExplicitUnit.fluidOunceUSNutritionLabeling
        case .tablespoon:
            return VolumeExplicitUnit.tablespoonUS
        case .teaspoon:
            return VolumeExplicitUnit.teaspoonUS
        case .mL:
            return VolumeExplicitUnit.ml
        case .liter:
            return VolumeExplicitUnit.liter
        }
    }
}

