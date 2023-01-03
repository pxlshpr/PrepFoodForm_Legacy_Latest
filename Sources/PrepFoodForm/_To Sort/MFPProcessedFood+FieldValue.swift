import MFPScraper
import PrepDataTypes

extension MFPProcessedFood {
    var energyFieldValue: FieldValue {
        .energy(FieldValue.EnergyValue(double: energy, string: energy.cleanAmount, unit: .kcal, fill: .prefill()))
    }
    
    func macroFieldValue(macro: Macro, double: Double) -> FieldValue {
        .macro(FieldValue.MacroValue(macro: macro, double: double, string: double.cleanAmount, fill: .prefill()))
    }

    func macroFieldValue(for macro: Macro) -> FieldValue {
        switch macro {
        case .carb:
            return carbFieldValue
        case .fat:
            return fatFieldValue
        case .protein:
            return proteinFieldValue
        }
    }

    var carbFieldValue: FieldValue {
        macroFieldValue(macro: .carb, double: carbohydrate)
    }
    var fatFieldValue: FieldValue {
        macroFieldValue(macro: .fat, double: fat)
    }

    var proteinFieldValue: FieldValue {
        macroFieldValue(macro: .protein, double: protein)
    }
    
    func microFieldValue(for nutrientType: NutrientType) -> FieldValue? {
        nutrient(for: nutrientType)?.fieldValue
    }
    
    var microFieldValues: [FieldValue] {
        nutrients.map { $0.fieldValue }
    }
    
    var amountFieldValue: FieldValue? {
        guard amount > 0 else {
            return nil
        }
        
        let size: FormSize?
        if case .size(let mfpSize) = amountUnit {
            size = mfpSize.size
        } else {
            size = nil
        }
        
        return FieldValue.amount(FieldValue.DoubleValue(
            double: amount,
            string: amount.cleanAmount,
            unit: amountUnit.formUnit(withSize: size),
            fill: .prefill())
        )
    }
    var servingFieldValue: FieldValue? {
        guard servingAmount > 0, let servingUnit = servingUnit else {
            return nil
        }
        
        let size: FormSize?
        if case .size(let mfpSize) = servingUnit {
            size = mfpSize.size
        } else {
            size = nil
        }
        
        return FieldValue.serving(FieldValue.DoubleValue(
            double: servingAmount,
            string: servingAmount.cleanAmount,
            unit: servingUnit.formUnit(withSize: size),
            fill: .prefill())
        )
    }
}


extension MFPProcessedFood {
    func nutrient(for nutrientType: NutrientType) -> Nutrient? {
        nutrients.first(where: { $0.type == nutrientType })
    }
}

extension MFPProcessedFood.Nutrient {
    var fieldValue: FieldValue {
        .micro(FieldValue.MicroValue(
            nutrientType: type,
            double: amount,
            string: amount.cleanAmount,
            unit: unit,
            fill: .prefill())
        )
    }
}
