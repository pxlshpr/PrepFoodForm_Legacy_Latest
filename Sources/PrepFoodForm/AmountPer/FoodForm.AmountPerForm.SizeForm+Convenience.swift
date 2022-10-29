import Foundation

extension FoodForm.AmountPerForm.SizeForm {
    
    var selectedImageIndex: Int? {
        FoodForm.Sources.shared.imageViewModels.firstIndex(where: { $0.id == field.fill.imageId })
    }
    
    var detentHeight: CGFloat {
        fields.hasFillOptions(for: field.value) ? 600 : 400
    }
    
    var isEmpty: Bool {
        field.value.isEmpty
    }
    
    var isEditing: Bool {
        existingField != nil
    }
    
    var isDirty: Bool {
        existingField?.value != field.value
    }
    
}
