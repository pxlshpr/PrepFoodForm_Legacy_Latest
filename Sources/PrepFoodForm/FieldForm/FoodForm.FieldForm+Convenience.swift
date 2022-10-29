import SwiftUI

extension FoodForm.FieldForm {
    
    /// Returns true if any of the fields have changed from what they initially were
    var isDirty: Bool {
        field.value != existingField.value
        || field.fill != existingField.fill
    }

    var isForDecimalValue: Bool {
        fieldValue.usesValueBasedTexts
    }
    
    var textFieldFont: Font {
        guard isForDecimalValue else {
            return .body
        }
        return field.value.string.isEmpty ? .body : .largeTitle
    }

    
    var fieldValue: FieldValue {
        field.value
    }
    
    var selectedImageIndex: Int? {
        sources.imageViewModels.firstIndex(where: { $0.id == fieldValue.fill.imageId })
    }    
}
