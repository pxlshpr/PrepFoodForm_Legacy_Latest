import Foundation

extension FoodForm.Fields {
    func selectFillOption(for fieldValue: FieldValue, using sources: FoodForm.Sources) -> FillOption? {
        guard sources.hasAvailableTexts(for: fieldValue) else {
            return nil
        }
        return FillOption(
            string: "Select",
            systemImage: Fill.SystemImage.selection,
            isSelected: false, /// never selected as we only use this to pop up the `TextPicker`
            type: .select
        )
    }
    
    func selectionFillOptions(for fieldValue: FieldValue) -> [FillOption] {
        guard case .density = fieldValue else {
            return fieldValue.selectionFillOptions
        }

        guard case .selection(let info) = fieldValue.fill,
              let selectedText = info.imageText?.text,
              selectedText != firstExtractedText(for: fieldValue)
        else {
            return []
        }
        
        return [
            FillOption(
                string: fillButtonString(for: fieldValue),
                systemImage: Fill.SystemImage.selection,
                isSelected: true,
                type: .fill(fieldValue.fill)
            )
        ]
    }
}
