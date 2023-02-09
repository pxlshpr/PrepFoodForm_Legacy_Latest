import SwiftUI
import FoodLabel
import PrepDataTypes
import PrepViews

extension FoodForm {
    var foodLabel: FoodLabel {
        let dataBinding = Binding<FoodLabelData>(
            get: {
                FoodLabelData(
                    energyValue: fields.energy.value.value ?? .init(amount: 0, unit: .kcal),
                    carb: fields.carb.value.double ?? 0,
                    fat: fields.fat.value.double ?? 0,
                    protein: fields.protein.value.double ?? 0,
                    nutrients: fields.microsDict,
                    quantityValue: fields.amount.value.double ?? 0,
                    quantityUnit: fields.amount.value.doubleValue.unitDescription
                )
            },
            set: { _ in }
        )

        return FoodLabel(data: dataBinding)
    }
    
    var servingsAndSizesCell: some View {
        ServingsAndSizesCell()
            .environmentObject(fields)
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
