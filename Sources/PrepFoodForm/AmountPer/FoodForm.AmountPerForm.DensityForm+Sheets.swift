import SwiftUI

extension FoodForm.AmountPerForm.DensityForm {
    var weightUnitPicker: some View {
        UnitPicker(
            pickedUnit: field.value.weight.unit,
            filteredType: .weight)
        { unit in
            field.value.weight.unit = unit
            field.value.fill = .userInput
        }
        .environmentObject(fields)
    }
    
    var volumeUnitPicker: some View {
        UnitPicker(
            pickedUnit: field.value.volume.unit,
            filteredType: .volume)
        { unit in
            field.value.volume.unit = unit
            field.value.fill = .userInput
        }
        .environmentObject(fields)
    }
    
    var textPicker: some View {
        TextPicker(
            imageViewModels: FoodForm.Sources.shared.imageViewModels,
            mode: .singleSelection(
                filter: .textsWithDensities,
                selectedImageText: field.fill.imageText,
                handler: { imageText in
                    didSelectImageTexts([imageText])
                })
        )
        .onDisappear {
            guard field.isCropping else {
                return
            }
            field.cropFilledImage()
            doNotRegisterUserInput = false
        }
    }
}
