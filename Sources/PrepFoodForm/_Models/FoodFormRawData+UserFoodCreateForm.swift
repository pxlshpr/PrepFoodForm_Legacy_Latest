import Foundation
import MFPScraper
import PrepDataTypes

extension FoodFormFieldsAndSources {

    var createForm: UserFoodCreateForm? {
        guard let info = foodInfo else {
            return nil
        }
        return UserFoodCreateForm(
            id: UUID(),
            name: name,
            emoji: emoji,
            detail: detail,
            brand: brand,
            publishStatus: .hidden,
            info: info
        )
    }
    
    var foodInfo: FoodInfo? {
        guard let amountFoodValue = FoodValue(fieldValue: amount),
              let foodNutrients
        else {
            return nil
        }
        let servingFoodValue: FoodValue?
        if let serving {
            servingFoodValue = FoodValue(fieldValue: serving)
        } else {
            servingFoodValue = nil
        }
        return FoodInfo(
            amount: amountFoodValue,
            serving: servingFoodValue,
            nutrients: foodNutrients,
            sizes: foodSizes,
            density: foodDensity,
            linkUrl: link,
            prefilledUrl: prefilledFood?.sourceUrl,
            imageIds: images.map { $0.id },
            barcodes: foodBarcodes,
            spawnedUserFoodId: nil,
            spawnedPresetFoodId: nil
        )
    }
    
    var foodBarcodes: [FoodBarcode] {
        barcodes.compactMap { $0.foodBarcode }
    }
    
    var foodDensity: FoodDensity? {
        density?.densityValue?.foodDensity
    }
    
    var foodSizes: [FoodSize] {
        sizes.compactMap({ $0.size }).compactMap {
            guard let quantity = $0.quantity,
                  let value = $0.foodValue
            else {
                return nil
            }
            
            return FoodSize(
                name: $0.name,
                volumePrefixExplicitUnit: $0.volumePrefixUnit?.volumeUnit?.volumeExplicitUnit,
                quantity: quantity,
                value: value
            )
        }
    }
    
    var foodNutrients: FoodNutrients? {
        guard let energy = energy.energyInKcal,
              let carb = carb.macroDouble,
              let fat = fat.macroDouble,
              let protein = protein.macroDouble
        else {
            return nil
        }
              
        return FoodNutrients(
            energyInKcal: energy,
            carb: carb,
            protein: protein,
            fat: fat,
            micros: foodNutrientsArray
        )
    }
    
    var foodNutrientsArray: [FoodNutrient] {
        micronutrients.compactMap {
            let microValue = $0.microValue
            guard let value = microValue.double else {
                return nil
            }
            return FoodNutrient(
                nutrientType: microValue.nutrientType,
                value: value,
                nutrientUnit: microValue.unit
            )
        }
    }
}
