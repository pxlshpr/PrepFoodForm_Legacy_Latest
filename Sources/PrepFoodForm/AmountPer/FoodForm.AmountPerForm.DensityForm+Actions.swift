import Foundation
import SwiftHaptics

extension FoodForm.AmountPerForm.DensityForm {

    func appeared() {
        focusedField = weightFirst ? .weight : .volume
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            shouldAnimateOptions = true
            
            /// Wait a while before unlocking the `doNotRegisterUserInput` flag in case it was set (due to a value already being present)
            doNotRegisterUserInput = false
        }
    }
    
    func didSelectImageTexts(_ imageTexts: [ImageText]) {
        
        guard let imageText = imageTexts.first else {
            return
        }

        guard let densityValue = imageText.text.string.detectedValues.densityValue else {
            return
        }
        
        let fill = fill(for: imageText, with: densityValue)

        doNotRegisterUserInput = true
        
        //Now set this fill on the density value
        setDensityValue(densityValue)
        field.value.fill = fill
        field.isCropping = true        
    }

    func didTapImage() {
        showTextPicker()
    }
    
    func didTapFillOption(_ fillOption: FillOption) {
        switch fillOption.type {
        case .select:
            didTapSelect()
        case .fill(let fill):
            Haptics.feedback(style: .rigid)
            
            doNotRegisterUserInput = true
            switch fill {
            case .prefill(let info):
                guard let densityValue = info.densityValue else {
                    return
                }
                setDensityValue(densityValue, fill: .prefill(info))
            case .scanned(let info):
                guard let densityValue = info.densityValue else {
                    return
                }
                setDensityValue(densityValue)
                field.assignNewScannedFill(fill)
            default:
                break
            }
            doNotRegisterUserInput = true
            dismiss()
//            saveAndDismiss()
        }
    }
    
    func didTapSelect() {
        showTextPicker()
    }
    
    func showTextPicker() {
        Haptics.feedback(style: .soft)
        doNotRegisterUserInput = true
        focusedField = nil
        showingTextPicker = true
    }

    func setDensityValue(_ densityValue: FieldValue.DensityValue, fill: Fill = .userInput) {
        field.value.weight.double = densityValue.weight.double
        field.value.weight.unit = densityValue.weight.unit
        field.value.volume.double = densityValue.volume.double
        field.value.volume.unit = densityValue.volume.unit
        field.value.fill = fill
        fields.updateFormState()
    }
    
//    func saveAndDismiss() {
//        doNotRegisterUserInput = true
//        existingField.copyData(from: field)
//        dismiss()
//    }
}
