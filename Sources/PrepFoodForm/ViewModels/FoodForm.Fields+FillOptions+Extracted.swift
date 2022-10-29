import Foundation

extension FoodForm.Fields {
    
    func extractedFillOptions(for fieldValue: FieldValue) -> [FillOption] {
        let extractedFieldValues = extractedFieldValues(for: fieldValue)
        var fillOptions: [FillOption] = []
        
        for scannedFieldValue in extractedFieldValues {
            guard case .scanned(let info) = scannedFieldValue.fill else {
                continue
            }
            
            fillOptions.append(
                FillOption(
                    string: fillButtonString(for: scannedFieldValue),
                    systemImage: Fill.SystemImage.scanned,
                    isSelected: fieldValue.equalsScannedFieldValue(scannedFieldValue),
                    type: .fill(scannedFieldValue.fill)
                )
            )
            
            /// Show alts if selected (only check the text because it might have a different value attached to it)
            for altValue in scannedFieldValue.altValues {
                fillOptions.append(
                    FillOption(
                        string: altValue.fillOptionString,
                        systemImage: Fill.SystemImage.scanned,
                        isSelected: fieldValue.value == altValue && fieldValue.fill.isImageAutofill,
                        type: .fill(.scanned(info.withAltValue(altValue)))
                    )
                )
            }
        }
                
        return fillOptions
    }
    
    func extractedFieldValues(for fieldValue: FieldValue) -> [FieldValue] {
        switch fieldValue {
        case .energy:
            return extractedFieldValues.filter({ $0.isEnergy })
        case .macro(let macroValue):
            return extractedFieldValues.filter({ $0.isMacro && $0.macroValue.macro == macroValue.macro })
        case .micro(let microValue):
            return extractedFieldValues.filter({ $0.isMicro && $0.microValue.nutrientType == microValue.nutrientType })
        case .amount:
            return extractedFieldValues.filter({ $0.isAmount })
        case .serving:
            return extractedFieldValues.filter({ $0.isServing })
        case .density:
            return extractedFieldValues.filter({ $0.isDensity })
        case .size:
            return extractedSizeFieldValues(for: fieldValue)
        default:
            return []
        }
    }
    
    func extractedSizeFieldValues(for fieldValue: FieldValue) -> [FieldValue] {
        newSizeFieldValues(from: extractedFieldValues, including: fieldValue)
    }
}
