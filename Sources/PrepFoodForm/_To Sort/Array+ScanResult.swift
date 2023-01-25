import FoodLabelScanner
import SwiftSugar
import PrepDataTypes

extension ScanResult {
    func fieldValue(for fieldValue: FieldValue, at column: Int) -> FieldValue? {
        switch fieldValue {
        case .amount:
            return amountFieldValue(for: column)
        case .serving:
            return servingFieldValue(for: column)
        case .density:
            return densityFieldValue
        case .energy:
            return energyFieldValue(at: column)
        case .macro(let macroValue):
            return macroFieldValue(for: macroValue.macro, at: column)
        case .micro(let microValue):
            return microFieldValue(for: microValue.nutrientType, at: column)
        default:
            return nil
        }
    }
}

enum FieldType {
    case amount, serving, density, energy, macro, micro
}

extension Array where Element == ScanResult {

    func bestFieldValues(at column: Int) -> [FieldValue] {
        
        /// Single fields
        var fieldValues: [FieldValue?] = [
            bestAmountFieldValue(at: column),
            bestServingFieldValue(at: column),
            bestDensityFieldValue,
            bestEnergyFieldValue(at: column)
        ]

        /// Macros
        for macro in Macro.allCases {
            fieldValues.append(bestMacroFieldValue(macro, at: column))
        }
        
        /// Micronutrients
        for nutrientType in NutrientType.allCases {
            fieldValues.append(bestMicroFieldValue(nutrientType, at: column))
        }
        
        /// Sizes
        fieldValues.append(contentsOf: allSizeFieldValues(at: column))

        /// Barcodes
        fieldValues.append(contentsOf: allBarcodeFieldValues)

        return fieldValues.compactMap { $0 }
    }
    
    func bestFieldValue(for fieldValue: FieldValue, at column: Int) -> FieldValue? {
        switch fieldValue {
        case .amount:
            return bestAmountFieldValue(at: column)
        case .serving:
            return bestServingFieldValue(at: column)
        case .density:
            return bestDensityFieldValue
        case .energy:
            return bestEnergyFieldValue(at: column)
        case .macro(let macroValue):
            return bestMacroFieldValue(macroValue.macro, at: column)
        case .micro(let microValue):
            return bestMicroFieldValue(microValue.nutrientType, at: column)
        default:
            return nil
        }
    }
    
    func bestAmountFieldValue(at column: Int) -> FieldValue? {
        filter { $0.amountFieldValue(for: column) != nil }
            .bestScanResult?
            .amountFieldValue(for: column)
    }
    
    func bestServingFieldValue(at column: Int) -> FieldValue? {
        filter { $0.servingFieldValue(for: column) != nil }
            .bestScanResult?
            .servingFieldValue(for: column)
    }
    
    var bestDensityFieldValue: FieldValue? {
        filter { $0.densityFieldValue != nil }
            .bestScanResult?
            .densityFieldValue
    }
    
    func bestEnergyFieldValue(at column: Int) -> FieldValue? {
        filter { $0.containsValue(for: .energy, at: column) }
            .bestScanResult?
            .energyFieldValue(at: column)
    }
    
    func bestMacroFieldValue(_ macro: Macro, at column: Int) -> FieldValue? {
        filter { $0.containsValue(for: macro.attribute, at: column) }
            .bestScanResult?
            .macroFieldValue(for: macro, at: column)
    }
    
    func bestMicroFieldValue(_ nutrientType: NutrientType, at column: Int) -> FieldValue? {
        guard let attribute = nutrientType.attribute else { return nil }
        return filter { $0.containsValue(for: attribute, at: column) }
            .bestScanResult?
            .microFieldValue(for: nutrientType, at: column)
    }
}

extension Array where Element == ScanResult {
    
    var allBarcodeFieldValues: [FieldValue] {
        reduce([]) { partialResult, scanResult in
            partialResult + scanResult.barcodeFieldValues
        }
    }

    func allSizeFieldValues(at column: Int) -> [FieldValue] {
        guard let bestScanResult else { return [] }
        var fieldValues: [FieldValue] = []
        
        /// Start by adding the best `ScanResult`'s size view models (as it gets first preference)
        fieldValues.append(contentsOf: bestScanResult.allSizeFieldValues(at: column))
        
        /// Now go through the remaining `ScanResult`s and add those
        for scanResult in filter({ $0.id != bestScanResult.id }) {
            fieldValues.append(contentsOf: scanResult.allSizeFieldValues(at: column))
        }
        
        return fieldValues
    }

    var allBarcodeFields: [Field] {
        allBarcodeFieldValues.map { Field(fieldValue: $0) }
    }
    
    func allSizeViewModels(at column: Int) -> [Field] {
        allSizeFieldValues(at: column)
            .map { Field(fieldValue: $0) }
    }
    
    /**
     First gets the `bestScanResult` (with the greatest `nutrientCount`).
     
     Then filters this array to only include those that have the same number of columns as this best result, and matches the headers, *if present*.
     */
    var candidateScanResults: [ScanResult] {
        guard let bestScanResult else { return [] }
        return filter {
            $0.columnCount == bestScanResult.columnCount
            && $0.hasCompatibleHeadersWith(bestScanResult)
        }
    }
    
    /// Returns the scan result with the most number of nutrient rows
    var bestScanResult: ScanResult? {
        sorted(by: { $0.nutrientCount > $1.nutrientCount })
            .first
    }
    
    /// Returns true if any of the `ScanResult` in this array is tabular
    var hasTabularScanResult: Bool {
        contains(where: { $0.isTabular })
    }
    
    /**
     Returns the column number with the most number of non-nil nutrients in all the ScanResults.
     
     Remember that the column numbers aren't 0-based, so they start at 1.
     Returns 1 if they are both equal.
     */
//    var columnWithTheMostNutrients: Int {
//        map { $0.columnWithTheMostNutrients}
//            .mostFrequent ?? 1
//    }

    func imageTextsForColumnSelection(at column: Int) -> [ImageText] {
        var fieldValues: [FieldValue?] = []
        fieldValues.append(bestEnergyFieldValue(at: column))
        for macro in Macro.allCases {
            fieldValues.append(bestMacroFieldValue(macro, at: column))
        }
        for nutrientType in NutrientType.allCases {
            fieldValues.append(bestMicroFieldValue(nutrientType, at: column))
        }
        return fieldValues.compactMap({ $0?.fill.imageText })
    }
    
    /** Minimum number of columns */
    var minimumNumberOfColumns: Int {
        allSatisfy({ $0.columnCount == 2 }) ? 2 : 1
    }
}

extension ScanResult {
    
    func imageTextsForColumnSelection(at column: Int) -> [ImageText] {
        var fieldValues: [FieldValue?] = []
        fieldValues.append(energyFieldValue(at: column))
        for macro in Macro.allCases {
            fieldValues.append(macroFieldValue(for: macro, at: column))
        }
        for nutrientType in NutrientType.allCases {
            fieldValues.append(microFieldValue(for: nutrientType, at: column))
        }
        return fieldValues.compactMap({ $0?.fill.imageText })
    }
}
