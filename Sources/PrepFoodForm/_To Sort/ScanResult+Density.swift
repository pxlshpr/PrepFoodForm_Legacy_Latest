import FoodLabelScanner
import VisionSugar
import Foundation
import PrepDataTypes

extension ScanResult {

    var densityFieldValue: FieldValue? {
        /// Check if we have an equivalent serving size
        if let equivalentSizeDensityValue {
            return FieldValue.density(equivalentSizeDensityValue)
        }
        /// Otherwise check if we have a header equivalent size for any of the headers
        if let headerEquivalentSizeDensityValue {
            return FieldValue.density(headerEquivalentSizeDensityValue)
        }
        return nil
    }

    var servingBasedHeaderText: RecognizedText? {
        guard let headers else { return nil }
        if headers.header1Type == .perServing {
            return headers.headerText1?.text
        } else if headers.header2Type == .perServing {
            return headers.headerText2?.text
        }
        return nil
    }
    var equivalentSizeDensityValue: FieldValue.DensityValue? {
        guard let equivalentSize,
              let equivalentSizeUnit = equivalentSize.unit,
              let servingUnit,
              let servingAmount
        else {
            return nil
        }
        return FieldValue.DensityValue(
            text: equivalentSize.amountText.text,
            imageId: id,
            unit1: equivalentSizeUnit,
            amount1: equivalentSize.amount,
            unit2: servingUnit,
            amount2: servingAmount
        )
    }
    
    var equivalentSizeDensityValue_legacy: FieldValue.DensityValue? {
        guard let equivalentSize,
              let equivalentSizeUnit = equivalentSize.unit,
              let servingUnit, let servingAmount,
              servingUnit.isCompatibleForDensity(with: equivalentSizeUnit)
        else {
            return nil
        }
        
        let unitFill: Fill = Fill.scanned(ScannedFillInfo(
            imageText: ImageText(text: equivalentSize.amountText.text, imageId: id)
        ))
        let weight: FieldValue.DoubleValue
        let volume: FieldValue.DoubleValue
        
        if let weightUnit = equivalentSizeUnit.weightFormUnit {
            weight = FieldValue.DoubleValue(
                double: equivalentSize.amount,
                string: equivalentSize.amount.cleanAmount,
                unit: weightUnit,
                fill: unitFill)
            guard let volumeUnit = servingUnit.volumeFormUnit else {
                return nil
            }
            volume = FieldValue.DoubleValue(
                double: servingAmount,
                string: servingAmount.cleanAmount,
                unit: volumeUnit,
                fill: unitFill)
            
        } else if let weightUnit = servingUnit.weightFormUnit {
            
            weight = FieldValue.DoubleValue(
                double: servingAmount,
                string: servingAmount.cleanAmount,
                unit: weightUnit,
                fill: unitFill)
            guard let volumeUnit = equivalentSizeUnit.volumeFormUnit else {
                return nil
            }
            volume = FieldValue.DoubleValue(
                double: equivalentSize.amount,
                string: equivalentSize.amount.cleanAmount,
                unit: volumeUnit,
                fill: unitFill)
        } else {
            return nil
        }
        
        let fill: Fill = Fill.scanned(ScannedFillInfo(
            imageText: ImageText(text: equivalentSize.amountText.text, imageId: id),
            densityValue: FieldValue.DensityValue(weight: weight, volume: volume, fill: unitFill)
        ))
        return FieldValue.DensityValue(weight: weight, volume: volume, fill: fill)
    }
    
    var headerEquivalentSizeDensityValue: FieldValue.DensityValue? {
        guard let headerEquivalentSize,
              let headerEquivalentSizeUnit = headerEquivalentSize.unit,
              let headerServingUnit,
              let headerServingAmount,
              let servingBasedHeaderText
        else {
            return nil
        }
        
        return FieldValue.DensityValue(
            text: servingBasedHeaderText,
            imageId: id,
            unit1: headerEquivalentSizeUnit,
            amount1: headerEquivalentSize.amount,
            unit2: headerServingUnit,
            amount2: headerServingAmount
        )
    }
}

extension Array where Element == (amount: Double, unit: FoodLabelUnit) {
    
    func firstWeightValue(withFill fill: Fill) -> FieldValue.DoubleValue? {
        for tuple in self {
            guard let weightUnit = tuple.unit.weightFormUnit else { continue }
            return FieldValue.DoubleValue(
                double: tuple.amount,
                string: tuple.amount.cleanAmount,
                unit: weightUnit,
                fill: fill)
        }
        return nil
    }

    func firstVolumeValue(withFill fill: Fill) -> FieldValue.DoubleValue? {
        for tuple in self {
            guard let volumeUnit = tuple.unit.volumeFormUnit else { continue }
            return FieldValue.DoubleValue(
                double: tuple.amount,
                string: tuple.amount.cleanAmount,
                unit: volumeUnit,
                fill: fill)
        }
        return nil
    }
}

extension FieldValue.DensityValue {
    init?(
        text: RecognizedText, imageId: UUID,
        unit1: FoodLabelUnit, amount1: Double,
        unit2: FoodLabelUnit, amount2: Double
    ) {
        let tuples: [(amount: Double, unit: FoodLabelUnit)] = [(amount1, unit1), (amount2, unit2)]
        let unitFill: Fill = Fill.scanned(ScannedFillInfo(
            imageText: ImageText(text: text, imageId: imageId)
        ))
        
        guard let weight = tuples.firstWeightValue(withFill: unitFill),
              let volume = tuples.firstVolumeValue(withFill: unitFill)
        else {
            return nil
        }
        
        let fillDensityValue = FieldValue.DensityValue(weight: weight, volume: volume, fill: unitFill)
        let fill = Fill.scanned(ScannedFillInfo(
            imageText: ImageText(text: text, imageId: imageId),
            densityValue: fillDensityValue
        ))
        self = FieldValue.DensityValue(weight: weight, volume: volume, fill: fill)
    }
}
