import SwiftUI

extension FoodForm.AmountPerForm {
    struct DensityView: View {
        @ObservedObject var field: Field
        @Binding var isWeightBased: Bool
        @Binding var shouldShowFillIcon: Bool
    }
}
extension FoodForm.AmountPerForm.DensityView {
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.triangle.swap")
                .foregroundColor(Color(.tertiaryLabel))
            if let densityValue = field.value.densityValue,
               densityValue.isValid,
               let description = densityValue.description(weightFirst: isWeightBased)
            {
                Text(description)
                    .foregroundColor(Color(.secondaryLabel))
            } else {
                Text("Optional")
                    .foregroundColor(Color(.quaternaryLabel))
            }
            Spacer()
            fillTypeIcon
        }
    }
    
    @ViewBuilder
    var fillTypeIcon: some View {
        if shouldShowFillIcon, field.value.densityValue?.isValid == true {
            Image(systemName: field.value.fill.iconSystemImage)
                .foregroundColor(Color(.secondaryLabel))
        }
    }
}
