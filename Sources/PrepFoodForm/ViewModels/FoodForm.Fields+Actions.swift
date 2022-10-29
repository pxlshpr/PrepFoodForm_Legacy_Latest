import SwiftUI

extension FoodForm.Fields {
    
    func updateFormState() {
        updateShouldShowDensity()
        updateShouldShowFoodLabel()
        
        /// Should be called after setting `shouldShowFoodLabel`, as it depends on it
        updateCanBeSaved()
    }
    
    func updateCanBeSaved() {
        canBeSaved = !name.isEmpty && shouldShowFoodLabel
    }
    
    func updateShouldShowFoodLabel() {
        shouldShowFoodLabel = !energy.value.isEmpty
        && !amount.value.isEmpty
        && !carb.value.isEmpty
        && !fat.value.isEmpty
        && !protein.value.isEmpty
    }
    
    func updateShouldShowDensity() {
        withAnimation {
            shouldShowDensity =
            (amount.value.doubleValue.unit.isMeasurementBased && (amount.value.doubleValue.double ?? 0) > 0)
            ||
            (serving.value.doubleValue.unit.isMeasurementBased && (serving.value.doubleValue.double ?? 0) > 0)
        }
    }
    
    //TODO: AmountPerForm Test if this ever gets called
    func amountChanged() {
        updateFormState()
        if amount.value.doubleValue.unit != .serving {
            serving.value.doubleValue.double = nil
            serving.value.doubleValue.string = ""
            serving.value.doubleValue.unit = .weight(.g)
        }
    }
    
    //TODO: AmountPerForm Test if this ever gets called
    func servingChanged() {
        /// If we've got a serving-based unit for the serving size—modify it to make sure the values equate
        modifyServingUnitIfServingBased()
        updateFormState()
//        if !servingString.isEmpty && amountString.isEmpty {
//            amountString = "1"
//        }
    }
    
    //TODO: AmountPerForm Do this
    func modifyServingUnitIfServingBased() {
//        guard servingViewModel.fieldValue.doubleValue.unit.isServingBased, case .size(let size, _) = servingViewModel.fieldValue.doubleValue.unit else {
//            return
//        }
//        let newAmount: Double
//        if let quantity = size.quantity, let servingAmount = servingViewModel.fieldValue.doubleValue.double, servingAmount > 0 {
//            newAmount = quantity / servingAmount
//        } else {
//            newAmount = 0
//        }
        
        //TODO: We need to get access to it here—possibly need to add it to sizes to begin with so that we can modify it here
//        size.amountDouble = newAmount
//        updateSummary()
    }
    
    //MARK: - Sizes
    func edit(_ sizeField: Field, with newSizeField: Field) {
        guard let newSize = newSizeField.size, let oldSize = sizeField.size else {
            return
        }
        
        /// if this was a standard
        if oldSize.isVolumePrefixed == false {
            editStandardSize(sizeField, with: newSizeField)
        } else {
            editVolumePrefixedSize(sizeField, with: newSizeField)
        }
        
        /// if this size was used for either amount or serving—update it with the new size
        if amount.value.doubleValue.unit.size == oldSize {
            amount.value.doubleValue.unit.size = newSize
        }
        if serving.value.doubleValue.unit.size == oldSize {
            serving.value.doubleValue.unit.size = newSize
        }
    }
    
    func editStandardSize(_ sizeField: Field, with newSizeField: Field) {
        if newSizeField.size?.isVolumePrefixed == true {
            /// Remove it from the standard list
            standardSizes.removeAll(where: { $0.id == sizeField.id })
            
            /// Append the new one to the volume based list
            volumePrefixedSizes.append(newSizeField)
            //TODO: We'll also need to cases where other form fields are dependent on this here—requiring user confirmation first
        } else {
            guard let index = standardSizes.firstIndex(where: { $0.id == sizeField.id }) else {
                return
            }
            standardSizes[index].copyData(from: newSizeField)
            //TODO: We'll also need to cases where other form fields are dependent on this here—requiring user confirmation first
        }
    }
    
    func editVolumePrefixedSize(_ sizeField: Field, with newSizeField: Field) {
        if newSizeField.size?.isVolumePrefixed == false {
            /// Remove it from the standard list
            volumePrefixedSizes.removeAll(where: { $0.id == sizeField.id })
            
            /// Append the new one to the volume based list
            standardSizes.append(newSizeField)
            //TODO: We'll also need to cases where other form fields are dependent on this here—requiring user confirmation first
        } else {
            guard let index = volumePrefixedSizes.firstIndex(where: { $0.id == sizeField.id }) else {
                return
            }
            volumePrefixedSizes[index].copyData(from: newSizeField)
            //TODO: We'll also need to cases where other form fields are dependent on this here—requiring user confirmation first
        }
    }
}
