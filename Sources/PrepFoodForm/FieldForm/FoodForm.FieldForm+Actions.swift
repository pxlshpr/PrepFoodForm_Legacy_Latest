import SwiftUI
import SwiftHaptics
import VisionSugar

extension FoodForm.FieldForm {
    
    func saveAndDismiss() {
        doNotRegisterUserInput = true
        /// Copy the data across from the transient `FieldViewModel` we were using here to persist the data
        existingField.copyData(from: field)
        if let didSave {
            didSave()
        }
        dismiss()
    }
    
    func didTapSelect() {
        showTextPicker()
    }
    
    func showTextPicker() {
        Haptics.feedback(style: .soft)
        doNotRegisterUserInput = true
        isFocused = false
        showingTextPicker = true
    }
    
    //MARK: - Fill Related
    
    func didTapFillOption(_ fillOption: FillOption) {
        switch fillOption.type {
        case .select:
            didTapSelect()
        case .fill(let fill):
            Haptics.feedback(style: .rigid)
            
            doNotRegisterUserInput = true
            
            switch fill {
            case .selection(let info):
                tappedSelectionFill(info)
            case .scanned(let info):
                tappedScannedFill(info)
            case .prefill(let info):
                tappedPrefill(info)
            default:
                break
            }

            if fieldValue.usesValueBasedTexts {
                field.assignNewScannedFill(fill)
                doNotRegisterUserInput = false
                saveAndDismiss()
            }
        }
    }
    
    func tappedScannedFill(_ info: ScannedFillInfo) {
        if let value = info.altValue ?? info.value, let setNewValue {
            setNewValue(value)
        }
    }
    
    func tappedSelectionFill(_ info: SelectionFillInfo) {
        if fieldValue.usesValueBasedTexts {
            guard let imageText = info.imageText, let value = info.altValue ?? imageText.text.string.detectedValues.first else {
                return
            }
            if let setNewValue {
                setNewValue(value)
            }
        } else {
            guard let componentText = info.componentTexts?.first else {
                doNotRegisterUserInput = false
                return
            }
            
            withAnimation {
                field.toggleComponentText(componentText)
            }
            doNotRegisterUserInput = false
        }
    }
    
    func tappedPrefill(_ info: PrefillFillInfo) {
        if let tappedPrefillFieldValue {
            /// Tapped a prefill or calculated value
            guard let prefillFieldValue = fields.prefillFieldValues(for: fieldValue).first else {
                return
            }

            tappedPrefillFieldValue(prefillFieldValue)
        } else {
            if !fieldValue.usesValueBasedTexts, let fieldString = info.fieldStrings.first {
                withAnimation {
                    field.toggle(fieldString)
                }
            }
        }
    }

    
    func fill(for text: RecognizedText, onImageWithId imageId: UUID) -> Fill {
        if let fill = fields.firstExtractedFill(for: fieldValue, with: text) {
            return fill
        } else {
            return .selection(.init(imageText: ImageText(text: text, imageId: imageId)))
        }
    }
    
    func didSelectImageTexts(_ imageTexts: [ImageText]) {
        
        guard fieldValue.usesValueBasedTexts else {
            for imageText in imageTexts {
                field.appendComponentTexts(for: imageText)
            }
            return
        }
        
        //TODO: Handle serving and amount
        
        /// This is the generic handler which works for single pick fields such as energy, macro, micro
        guard let imageText = imageTexts.first, let value = imageText.text.firstFoodLabelValue else {
            return
        }
        
        let newFillType = fill(for: imageText.text, onImageWithId: imageText.imageId)
        doNotRegisterUserInput = true
        
        if let setNewValue {
            setNewValue(value)
            field.value.fill = newFillType
            field.isCropping = true
        }
    }
}
