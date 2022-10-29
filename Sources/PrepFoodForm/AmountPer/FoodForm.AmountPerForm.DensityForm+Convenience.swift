import Foundation

extension FoodForm.AmountPerForm.DensityForm {

    func fill(for imageText: ImageText, with densityValue: FieldValue.DensityValue) -> Fill {
        if let fill = fields.firstExtractedFill(for: field.value, with: densityValue) {
            return fill
        } else {
            return .selection(.init(
                imageText: imageText,
                densityValue: densityValue
            ))
        }
    }

    var selectedImageIndex: Int? {
        FoodForm.Sources.shared.imageViewModels.firstIndex(where: { $0.id == field.fill.imageId })
    }
    
    var topFieldIsFocused: Bool {
        if weightFirst {
            return focusedField == .weight
        } else {
            return focusedField == .volume
        }
    }

    var bottomFieldIsFocused: Bool {
        if weightFirst {
            return focusedField == .volume
        } else {
            return focusedField == .weight
        }
    }
}
