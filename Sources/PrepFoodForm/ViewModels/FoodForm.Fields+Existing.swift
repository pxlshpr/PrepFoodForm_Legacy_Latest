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

        for size in standardSizes {
            
        }
    }
}
