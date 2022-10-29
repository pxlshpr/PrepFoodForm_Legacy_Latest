import SwiftUI
import FoodLabel
import PrepDataTypes
import PrepViews

extension FoodForm {
    var foodLabel: FoodLabel {
        let energyBinding = Binding<FoodLabelValue>(
            get: { fields.energy.value.value ?? .init(amount: 0, unit: .kcal)  },
            set: { _ in }
        )

        let carbBinding = Binding<Double>(
            get: { fields.carb.value.double ?? 0  },
            set: { _ in }
        )

        let fatBinding = Binding<Double>(
            get: { fields.fat.value.double ?? 0  },
            set: { _ in }
        )

        let proteinBinding = Binding<Double>(
            get: { fields.protein.value.double ?? 0  },
            set: { _ in }
        )
        
        let microsBinding = Binding<[NutrientType : FoodLabelValue]>(
            get: { fields.microsDict },
            set: { _ in }
        )
        
        let amountBinding = Binding<String>(
            get: { fields.amount.doubleValueDescription },
            set: { _ in }
        )

        return FoodLabel(
            energyValue: energyBinding,
            carb: carbBinding,
            fat: fatBinding,
            protein: proteinBinding,
            nutrients: microsBinding,
            amountPerString: amountBinding
        )
    }
    
    var foodAmountPerView: some View {
        
        let amountDescription = Binding<String>(
            get: { fields.amount.doubleValueDescription },
            set: { _ in }
        )

        let servingDescription = Binding<String?>(
            get: { fields.serving.value.isEmpty ? nil : fields.serving.doubleValueDescription },
            set: { _ in }
        )

        let numberOfSizes = Binding<Int>(
            get: { fields.allSizes.count },
            set: { _ in }
        )

        return FoodAmountPerView(
            amountDescription: amountDescription,
            servingDescription: servingDescription,
            numberOfSizes: numberOfSizes
        )
    }
}
