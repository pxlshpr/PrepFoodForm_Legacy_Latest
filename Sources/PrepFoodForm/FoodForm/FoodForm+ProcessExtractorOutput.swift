import SwiftUI
import PhotosUI
import FoodLabelExtractor
import FoodLabelScanner
import SwiftHaptics

extension FoodForm {
    
    func processExtractorOutput(_ output: ExtractorOutput) {
        let fieldValues = output.fieldValues
        withAnimation {
            fields.handleExtractedFieldsValues(fieldValues, from: output)
        }
        sources.add(output.image, with: output.scanResult)
        Haptics.successFeedback()
    }
    
}

extension ExtractorOutput {
    
    var fieldValues: [FieldValue] {
        var fieldValues = scanResult.nonNutrientFieldValues(at: selectedColumnIndex)
        fieldValues.append(contentsOf: nutrientFieldValues)
        return fieldValues
    }
    
    var nutrientFieldValues: [FieldValue] {
        extractedNutrients.compactMap { $0.fieldValue(scanResult.id) }
    }
}

extension ExtractedNutrient {
    func fieldValue(_ scanResultId: UUID) -> FieldValue? {
        
        let fill: Fill
        if let text = self.valueText, let value {
            let valueText = ValueText(value: value, text: text)
            fill = .scanned(.init(valueText: valueText, imageId: scanResultId))
        } else {
            fill = .userInput
        }
        
        let double = value?.amount
        let string = value?.amount.cleanAmount ?? ""
        
        if attribute == .energy {
            return FieldValue.energy(FieldValue.EnergyValue(
                double: double,
                string: string,
                unit: value?.unit?.energyUnit ?? .kcal,
                fill: fill
            ))
        } else if let macro = attribute.macro {
            return FieldValue.macro(FieldValue.MacroValue(
                macro: macro,
                double: double,
                string: string,
                fill: fill
            ))
        } else if let nutrientType = attribute.nutrientType {
            let unit = value?.unit?.nutrientUnit(for: nutrientType) ?? nutrientType.defaultUnit
            return FieldValue.micro(FieldValue.MicroValue(
                nutrientType: nutrientType,
                double: double,
                string: string,
                unit: unit,
                fill: fill)
            )
        }
        
        return nil

    }
}

extension ScanResult {
    func nonNutrientFieldValues(at column: Int) -> [FieldValue] {
        var fieldValues: [FieldValue?] = [
            amountFieldValue(for: column),
            servingFieldValue(for: column),
            densityFieldValue
        ]
        
        /// Sizes
        fieldValues.append(contentsOf: allSizeFieldValues(at: column))

        /// Barcodes
        fieldValues.append(contentsOf: barcodeFieldValues)

        return fieldValues.compactMap { $0 }
    }
}

import Foundation
import PrepDataTypes

extension FoodForm.Fields {
    
    func handleExtractedFieldsValues(_ fieldValues: [FieldValue], from output: ExtractorOutput) {
        
        for fieldValue in fieldValues.filter({ $0.isOneToOne }) {
            handleOneToOneExtractedNutrientFieldValue(fieldValue, from: output)
        }
        
        for sizeFieldValue in fieldValues.filter({ $0.isSize }) {
            let sizeField = Field(fieldValue: sizeFieldValue, from: output)
            /// If we were able to add this size view model (if it wasn't a duplicate) ...
            guard add(sizeField: sizeField) else {
                continue
            }
            /// ... then go ahead and add it to the `scannedFieldValues` array as well
            replaceOrSetExtractedFieldValue(sizeFieldValue)
        }

        /// Get Barcodes from all images
        for barcodeFieldValue in fieldValues.filter({ $0.isBarcode }) {
            let barcodeField = Field(fieldValue: barcodeFieldValue, from: output)
            guard add(barcodeField: barcodeField) else {
                continue
            }
            replaceOrSetExtractedFieldValue(barcodeField.value)
        }

        updateFormState()
        FoodForm.Sources.shared.markAllImageViewModelsAsProcessed()
    }
    
    func handleOneToOneExtractedNutrientFieldValue(_ fieldValue: FieldValue, from output: ExtractorOutput) {
        guard oneToOneFieldIsDiscardableOrNotPresent(for: fieldValue) else { return }
        fillOneToOneField(fieldValue, from: output)
    }

    func fillOneToOneField(_ fieldValue: FieldValue, from output: ExtractorOutput) {
        switch fieldValue {
        case .amount:
            amount.fill(fieldValue, from: output)
        case .serving:
            serving.fill(fieldValue, from: output)
        case .density:
            density.fill(fieldValue, from: output)
        case .energy:
            energy.fill(fieldValue, from: output)
        case .macro(let macroValue):
            switch macroValue.macro {
            case .carb: carb.fill(fieldValue, from: output)
            case .fat: fat.fill(fieldValue, from: output)
            case .protein: protein.fill(fieldValue, from: output)
            }
        case .micro:
            removeMicronutrient(for: fieldValue)
            addMicronutrient(fieldValue, from: output)
        default:
            break
        }
        //TODO: We probably don't need this anymore
        replaceOrSetExtractedFieldValue(fieldValue)
    }
    
    func addMicronutrient(_ fieldValue: FieldValue, from output: ExtractorOutput) {
        guard let group = fieldValue.microValue.nutrientType.group else { return }
        let field = Field(fieldValue: fieldValue, from: output)
        switch group {
        case .fats:         microsFats.append(field)
        case .fibers:       microsFibers.append(field)
        case .sugars:       microsSugars.append(field)
        case .minerals:     microsMinerals.append(field)
        case .vitamins:     microsVitamins.append(field)
        case .misc:         microsMisc.append(field)
        }
    }
}
