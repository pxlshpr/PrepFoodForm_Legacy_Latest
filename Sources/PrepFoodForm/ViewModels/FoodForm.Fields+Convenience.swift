import Foundation
import VisionSugar

extension FoodForm.Fields {
    func oneToOneFieldIsDiscardableOrNotPresent(for fieldValue: FieldValue) -> Bool {
        guard let existingField = existingOneToOneField(for: fieldValue) else {
            /// not present
            return true
        }
        return existingField.isDiscardable
    }
    
    func existingOneToOneField(for fieldValue: FieldValue) -> Field? {
        switch fieldValue {
        case .amount:
            return amount
        case .serving:
            return serving
        case .density:
            return density
        case .energy:
            return energy
        case .macro(let macroValue):
            switch macroValue.macro {
            case .carb: return carb
            case .protein: return protein
            case .fat: return fat
            }
        case .micro(let microValue):
            return micronutrientField(for: microValue.nutrientType)
        default:
            return nil
        }
    }
    
    var shouldShowSizes: Bool {
        !amount.value.isEmpty
    }

    var shouldShowServing: Bool {
        !amount.value.isEmpty && amountIsServing
    }

    var amountIsServing: Bool {
        amount.value.doubleValue.unit == .serving
    }

    var isWeightBased: Bool {
        amount.value.doubleValue.unit.isWeightBased
        || serving.value.doubleValue.unit.isWeightBased
    }
    
    var isVolumeBased: Bool {
        amount.value.doubleValue.unit.isVolumeBased
        || serving.value.doubleValue.unit.isVolumeBased
    }

    var hasSquareBarcodes: Bool {
        barcodes.contains {
            $0.barcodeValue?.symbology.isSquare == true
        }
    }
    
    var hasServing: Bool {
        amount.value.doubleValue.unit == .serving
    }
    
    //MARK: Density
    
    var hasValidDensity: Bool {
        density.isValid
    }

    var densityWeightAmount: Double {
        density.value.weight.double ?? 0
    }

    var densityVolumeAmount: Double {
        density.value.volume.double ?? 0
    }
    
    //MARK: Fills
    
    var hasNonUserInputFills: Bool {
        for field in allFieldValues {
            if !(field.fill == .userInput || field.fill == .discardable) {
                return true
            }
        }
        
        for model in allSizeFields {
            if !(model.value.fill == .userInput || model.value.fill == .discardable) {
                return true
            }
        }
        return false
    }

    var containsFieldWithFillImage: Bool {
        allFieldValues.contains(where: { $0.fill.usesImage })
    }
    
    var hasAmount: Bool {
        !amount.value.isEmpty
    }
    
    //MARK: Fields
    
    var allSingleFields: [Field] {
        [amount, serving, density, energy, carb, fat, protein]
    }

    var allMicronutrientFieldValues: [FieldValue] {
        allMicronutrientFields.map { $0.value }
    }

    var allMicronutrientFields: [Field] {
        microsFats + microsFibers + microsSugars + microsMinerals + microsVitamins + microsMisc
    }

    var allFieldValues: [FieldValue] {
        allFields.map { $0.value }
    }

    var allFields: [Field] {
        allSingleFields
        + allMicronutrientFields
        + standardSizes
        + volumePrefixedSizes
        + barcodes
    }
    
    var allSizeFields: [Field] {
        standardSizes + volumePrefixedSizes
    }
    
    //MARK: - Extracted Fields Convenience
    
    func firstExtractedText(for fieldValue: FieldValue) -> RecognizedText? {
        guard let fill = extractedFieldValues(for: fieldValue).first?.fill else {
            return nil
        }
        return fill.text
    }
    
    func firstExtractedFill(for fieldValue: FieldValue, with densityValue: FieldValue.DensityValue) -> Fill? {
        guard let fill = extractedFieldValues(for: fieldValue).first?.fill,
              let fillDensityValue = fill.densityValue,
              fillDensityValue.equalsValues(of: densityValue) else {
            return nil
        }
        return fill
    }

    func firstExtractedFill(for fieldValue: FieldValue, with text: RecognizedText) -> Fill? {
        guard let fill = extractedFieldValues(for: fieldValue).first?.fill,
              fill.text == text else {
            return nil
        }
        return fill
    }
}
