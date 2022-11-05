import Foundation
import PrepDataTypes

extension FoodForm.Fields {
    
    func handleExtractedFieldsValues(_ fieldValues: [FieldValue], using sources: FoodForm.Sources, shouldOverwrite: Bool) {
        
        for fieldValue in fieldValues.filter({ $0.isOneToOne }) {
            handleOneToOneExtractedNutrientFieldValue(fieldValue, shouldOverwrite: shouldOverwrite)
        }
        
        for sizeFieldValue in fieldValues.filter({ $0.isSize }) {
            let sizeField = Field(fieldValue: sizeFieldValue)
            /// If we were able to add this size view model (if it wasn't a duplicate) ...
            guard add(sizeField: sizeField) else {
                continue
            }
            sizeField.resetAndCropImage()
            /// ... then go ahead and add it to the `scannedFieldValues` array as well
            replaceOrSetExtractedFieldValue(sizeFieldValue)
        }
        
        /// Get Barcodes from all images
        for barcodeField in sources.allScanResults.allBarcodeFields {
            guard add(barcodeField: barcodeField) else {
                continue
            }
            barcodeField.resetAndCropImage()
            replaceOrSetExtractedFieldValue(barcodeField.value)
        }
        
        updateFormState()

        sources.markAllImageViewModelsAsProcessed()
    }
    
    func add(barcodeField: Field) -> Bool {
        guard !contains(barcodeField: barcodeField) else { return false }
        barcodes.append(barcodeField)
        return true
    }

    func contains(barcodeField: Field) -> Bool {
        guard let string = barcodeField.barcodeValue?.payloadString else { return false }
        return contains(barcode: string)
    }
    
    func contains(barcode string: String) -> Bool {
        barcodes.contains(where: {
            $0.barcodeValue?.payloadString == string
        })
    }

    /// Returns true if the size was added
    func add(sizeField: Field) -> Bool {
        guard let size = sizeField.size else { return false }
        
        if size.isVolumePrefixed {
            ///Make sure we don't already have one with the name
            guard !volumePrefixedSizes.containsSizeNamed(size.name) else {
                return false
            }
            volumePrefixedSizes.append(sizeField)
        } else {
            ///Make sure we don't already have one with the name
            guard !standardSizes.containsSizeNamed(size.name) else {
                return false
            }
            standardSizes.append(sizeField)
        }
        return true
    }
    
    func handleOneToOneExtractedNutrientFieldValue(_ fieldValue: FieldValue, shouldOverwrite: Bool) {
        guard shouldOverwrite || oneToOneFieldIsDiscardableOrNotPresent(for: fieldValue) else {
            return
        }
        fillOneToOneField(with: fieldValue)
    }
    
    func fillOneToOneField(with fieldValue: FieldValue) {
        switch fieldValue {
        case .amount:
            amount.fill(with: fieldValue)
        case .serving:
            serving.fill(with: fieldValue)
        case .density:
            density.fill(with: fieldValue)
        case .energy:
            energy.fill(with: fieldValue)
        case .macro(let macroValue):
            switch macroValue.macro {
            case .carb: carb.fill(with: fieldValue)
            case .fat: fat.fill(with: fieldValue)
            case .protein: protein.fill(with: fieldValue)
            }
        case .micro:
            removeMicronutrient(for: fieldValue)
            addMicronutrient(fieldValue)
//            fillMicroFieldValue(fieldValue, for: microValue.nutrientType)
        default:
            break
        }
        replaceOrSetExtractedFieldValue(fieldValue)
    }
    
//    func fillMicroFieldValue(_ fieldValue: FieldValue, for nutrientType: NutrientType) {
//        micronutrientField(for: nutrientType)?.fill(with: fieldValue)
//        //TODO: Next
//
//    }
    
    func replaceOrSetExtractedFieldValue(_ fieldValue: FieldValue) {
        /// First remove any existing `FieldValue` for this type (or a duplicate in the 1-many cases)
        switch fieldValue {
        case .amount:
            extractedFieldValues.removeAll(where: { $0.isAmount })
        case .serving:
            extractedFieldValues.removeAll(where: { $0.isServing })
        case .density:
            extractedFieldValues.removeAll(where: { $0.isDensity })
        case .energy:
            extractedFieldValues.removeAll(where: { $0.isEnergy })
        case .macro(let macroValue):
            extractedFieldValues.removeAll(where: { $0.isMacro(macroValue.macro)})
        case .micro(let microValue):
            extractedFieldValues.removeAll(where: { $0.isMicro(microValue.nutrientType)})
        case .size(let sizeValue):
            /// Make sure we never have two sizes with the same name and volume-prefix in the `scannedFieldValues` array at any given time
            extractedFieldValues.removeAll(where: {
                guard let size = $0.size else { return false }
                return size.conflictsWith(sizeValue.size)
            })
        case .barcode(let barcodeValue):
            /// Make sure we never have two barcodes with the same payload string **and** symbology in `scannedFieldValues`
            extractedFieldValues.removeAll(where: {
                guard let otherBarcodeValue = $0.barcodeValue else { return false }
                return barcodeValue.payloadString == otherBarcodeValue.payloadString
                && barcodeValue.symbology == otherBarcodeValue.symbology
            })
        default:
            break
        }
        
        /// Then add the provided `FieldValue`
        extractedFieldValues.append(fieldValue)
    }
    
}
