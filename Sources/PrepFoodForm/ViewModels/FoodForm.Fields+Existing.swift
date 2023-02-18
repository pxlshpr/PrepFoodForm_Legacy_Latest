import Foundation
import PrepDataTypes

extension FoodForm.Fields {
    public func fillWithExistingFood(_ food: Food) {
        
        name = food.name
        emoji = food.emoji
        detail = food.detail ?? ""
        brand = food.brand ?? ""
        
        if let amount = food.amountQuantity {
            self.amount = Field(fieldValue: .amount(.init(
                double: amount.value,
                string: amount.value.cleanAmount,
                unit: amount.unit.formUnit,
                fill: .userInput
            )))
        }
        
        if let serving = food.servingQuantity {
            self.serving = Field(fieldValue: .serving(.init(
                double: serving.value,
                string: serving.value.cleanAmount,
                unit: serving.unit.formUnit,
                fill: .userInput
            )))
        }

        self.energy = Field.init(fieldValue: .energy(.init(
            double: food.info.nutrients.energyInKcal,
            string: food.info.nutrients.energyInKcal.cleanAmount,
            unit: .kcal,
            fill: .userInput
        )))

        self.carb = Field.init(fieldValue: .macro(.init(
            macro: .carb,
            double: food.info.nutrients.carb,
            string: food.info.nutrients.carb.cleanAmount,
            fill: .userInput
        )))

        self.fat = Field.init(fieldValue: .macro(.init(
            macro: .fat,
            double: food.info.nutrients.fat,
            string: food.info.nutrients.fat.cleanAmount,
            fill: .userInput
        )))

        self.protein = Field.init(fieldValue: .macro(.init(
            macro: .protein,
            double: food.info.nutrients.protein,
            string: food.info.nutrients.protein.cleanAmount,
            fill: .userInput
        )))

        for formSize in food.formSizes {
            let fieldSize: Field = .init(fieldValue: .size(.init(
                size: formSize,
                fill: .userInput
            )))
            if formSize.isVolumePrefixed {
                self.volumePrefixedSizes.append(fieldSize)
            } else {
                self.standardSizes.append(fieldSize)
            }
        }
        
        for nutrient in food.info.nutrients.micros {
            guard let nutrientType = nutrient.nutrientType else { continue }
            let field = Field.init(fieldValue: .micro(.init(
                nutrientType: nutrientType,
                double: nutrient.value,
                string: nutrient.value.cleanAmount,
                unit: nutrient.nutrientUnit,
                isIncluded: true,
                fill: .userInput
            )))
            switch nutrientType.group {
            case .fats:
                microsFats.append(field)
            case .fibers:
                microsFibers.append(field)
            case .sugars:
                microsSugars.append(field)
            case .minerals:
                microsMinerals.append(field)
            case .vitamins:
                microsVitamins.append(field)
            case .misc:
                microsMisc.append(field)
            default:
                break
            }
        }
        
        for barcode in food.info.barcodes {
            let field = Field.init(fieldValue: .barcode(.init(
                payloadString: barcode.payload,
                symbology: barcode.symbology.vnBarcodeSymbology,
                fill: .userInput
            )))
            self.barcodes.append(field)
        }
    }
}

import Vision
import PrepDataTypes

extension PrepDataTypes.BarcodeSymbology {
    var vnBarcodeSymbology: VNBarcodeSymbology {
        switch self {
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
        }
    }
}
