import FoodLabelScanner
import PrepDataTypes
import VisionSugar
import SwiftUI

extension ScanResult {
        
    func amountFieldValue(for column: Int) -> FieldValue? {
        guard headerType(for: column) != .perServing else {
            guard let valueText = amountValueText(for: column) else { return nil }
            return FieldValue.amount(FieldValue.DoubleValue(
                double: 1, string: "1", unit: .serving, fill: scannedFill(
                    for: valueText,
                    value: FoodLabelValue(amount: 1, unit: nil)
                ))
            )
        }
        
        guard let doubleValue = headerDoubleValue(for: column) else {
            return nil
        }
        return FieldValue.amount(doubleValue)
    }
    
    func servingFieldValue(for column: Int) -> FieldValue? {
        /// If we have a header type for the column and it's not `.perServing`, return `nil` immediately
        if let headerType = headerType(for: column) {
            guard headerType == .perServing else {
                return nil
            }
        }
        
        if let servingAmount, let servingAmountValueText {
            return FieldValue.serving(FieldValue.DoubleValue(
                double: servingAmount,
                string: servingAmount.cleanAmount,
                unit: servingFormUnit,
                fill: scannedFill(
                    for: servingAmountValueText,
                    value: FoodLabelValue(
                        amount: servingAmount,
                        unit: servingFormUnit.foodLabelUnit
                    )
                )
            ))
        }
        //        else if headerType(for: column) == .perServing {
        //            return headerFieldValue(for: column)
        //        } else {
        //            return nil
        //        }
        else if let doubleValue = headerDoubleValue(for: column) {
            return FieldValue.serving(doubleValue)
        }
        return nil
    }
    
    var barcodeFieldValues: [FieldValue] {
        barcodes.map {
            //TODO: Clean this up by first moving text creator into FoodLabelScanner embedding it into RecognizedBarcode
            //TODO: Eventually though—make .scanned Fills support a bounding box alone (not necessarily a ValueText)—but do this when we have the rest in place.
            let text = RecognizedText(
                observation: .init(boundingBox: $0.boundingBox),
                rect: $0.boundingBox.rectForSize(UIScreen.main.bounds.size),
                boundingBox: $0.boundingBox)
            let valueText = ValueText(value: .zero, text: text)
            return FieldValue.barcode(.init(
                payloadString: $0.string,
                symbology: $0.symbology,
                fill: .scanned(.init(valueText: valueText, imageId: id))
            ))
        }
    }
    
    func energyFieldValue(at column: Int) -> FieldValue? {
        guard let row = row(for: .energy),
              let valueText = row.valueText(at: column),
              let value = row.value(at: column),
              valueText.text.id != defaultUUID /// Ignores all calculated values without an attached `RecognizedText`
        else {
            return nil
        }
        return FieldValue.energy(FieldValue.EnergyValue(
            double: value.amount,
            string: value.amount.cleanAmount,
            unit: value.unit?.energyUnit ?? .kcal,
            fill: .scanned(.init(valueText: valueText, imageId: id))
        ))
    }
    
    func macroFieldValue(for macro: Macro, at column: Int) -> FieldValue? {
        guard let row = row(for: macro.attribute),
              let valueText = row.valueText(at: column),
              let value = row.value(at: column),
              valueText.text.id != defaultUUID /// Ignores all calculated values without an attached `RecognizedText`
        else {
            return nil
        }
        
        return FieldValue.macro(FieldValue.MacroValue(
            macro: macro,
            double: value.amount,
            string: value.amount.cleanAmount,
            fill: .scanned(.init(valueText: valueText, imageId: id))
        ))
    }

    func microFieldValue(for nutrientType: NutrientType, at column: Int) -> FieldValue? {
        guard let attribute = nutrientType.attribute,
              let row = row(for: attribute),
              let valueText = row.valueText(at: column),
              let value = row.value(at: column),
              valueText.text.id != defaultUUID /// Ignores all calculated values without an attached `RecognizedText`
        else {
            return nil
        }
        
        let fill = Fill.scanned(.init(valueText: valueText, imageId: id))
        let unit = value.unit?.nutrientUnit(for: nutrientType) ?? nutrientType.defaultUnit
        
        return FieldValue.micro(FieldValue.MicroValue(
            nutrientType: nutrientType,
            double: value.amount,
            string: value.amount.cleanAmount,
            unit: unit,
            fill: fill)
        )
    }

    
    func row(for attribute: Attribute) -> ScanResult.Nutrients.Row? {
        nutrients.rows.first(where: { $0.attribute == attribute })
    }
}
