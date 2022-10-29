import Foundation
import PrepDataTypes

extension FoodForm.Fields {
    
    /**
     Returns any `FieldValues` containing sizes that we don't already have, ignoring the current size being edited (if any).
     
     Also includes the `fieldValue` provided.
     */
    func newSizeFieldValues(from fieldValues: [FieldValue], including fieldToInclude: FieldValue) -> [FieldValue] {
        fieldValues
            .filter { $0.isSize }
            .filter { fieldValue in
                
                /// Always include the size that's being used by this fieldValue currently (so that we can see it toggled on)
                if fieldValue.size == fieldToInclude.size {
                    return true
                }
                
                /// Make sure we're not using it already
                guard let size = fieldValue.size else { return true }
                return !containsConflictingSize(to: size, ignoreSizeBeingEdited: true)
            }
    }
    
    var allSizesExceptSizeBeingEdited: [FormSize] {
        allSizes.filter { $0 != sizeBeingEdited }
    }
    
    /// Checks that we don't already have a size with the same name (and volume prefix unit) as what was provided
    func containsConflictingSize(to size: FormSize, ignoreSizeBeingEdited: Bool) -> Bool {
        let sizes = ignoreSizeBeingEdited ? allSizesExceptSizeBeingEdited : allSizes
        for existingSize in sizes {
            if existingSize.name.lowercased() == size.name.lowercased(),
               existingSize.volumePrefixUnit == size.volumePrefixUnit {
                return true
            }
        }
        return false
    }
    
    var allSizes: [FormSize] {
        standardSizes.compactMap({ $0.value.size })
        + volumePrefixedSizes.compactMap({ $0.value.size })
    }
}
