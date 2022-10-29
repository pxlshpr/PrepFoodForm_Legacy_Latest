import MFPScraper
import PrepDataTypes

extension FoodForm.Fields {

    func prefill(_ food: MFPProcessedFood) {
        
        prefillDetails(from: food)
        
        /// Create sizes first as we might have one as the amount or serving unit
        prefillSizes(from: food)
        
        prefillDensity(from: food)
        
        prefillAmountPer(from: food)
        prefillNutrients(from: food)

        updateFormState()
        
        prefilledFood = food
    }
    
    func prefillDetails(from food: MFPProcessedFood) {
        if let fieldValue = food.nameFieldValue {
            name = fieldValue.string
        }
        if let fieldValue = food.detailFieldValue {
            detail = fieldValue.string
        }
        if let fieldValue = food.brandFieldValue {
            brand = fieldValue.string
        }
    }
    
    func prefillSizes(from food: MFPProcessedFood) {
        for size in food.sizes.filter({ !$0.isDensity }) {
            prefillSize(size)
        }
    }
    
    func prefillSize(_ processedSize: MFPProcessedFood.Size) {
        let field: Field = .init(fieldValue: processedSize.fieldValue)
        if processedSize.isVolumePrefixed {
            volumePrefixedSizes.append(field)
        } else {
            standardSizes.append(field)
        }
    }
    
    func prefillSize(_ size: FormSize) {
        let field: Field = .init(fieldValue: size.fieldValue)
        if size.isVolumePrefixed {
            volumePrefixedSizes.append(field)
        } else {
            standardSizes.append(field)
        }
    }

    func prefillDensity(from food: MFPProcessedFood) {
        guard let fieldValue = food.densityFieldValue else { return }
        density = .init(fieldValue: fieldValue)
    }

    func prefillAmountPer(from food: MFPProcessedFood) {
        prefillAmount(from: food)
        prefillServing(from: food)
    }
    
    func prefillAmount(from food: MFPProcessedFood) {
        guard let fieldValue = food.amountFieldValue else {
            return
        }
        
//        /// If the amount had a size as a unit—prefill that too
//        if case .size(let size, _) = fieldValue.doubleValue.unit {
//            prefillSize(size)
//        }
        
        amount.value = fieldValue
    }
    
    func prefillServing(from food: MFPProcessedFood) {
        guard let fieldValue = food.servingFieldValue else {
            return
        }
        
//        /// If the serving had a size as a unit—prefill that too
//        if case .size(let size, _) = fieldValue.doubleValue.unit {
//            prefillSize(size)
//        }
        
        serving = .init(fieldValue: fieldValue)
    }
    
    func prefillNutrients(from food: MFPProcessedFood) {
        energy = .init(fieldValue: food.energyFieldValue)
        carb = .init(fieldValue: food.carbFieldValue)
        fat = .init(fieldValue: food.fatFieldValue)
        protein = .init(fieldValue: food.proteinFieldValue)
        
        prefillMicros(food.microFieldValues)
    }
    
    func prefillMicros(_ fieldValues: [FieldValue]) {
        for fieldValue in fieldValues {
            addMicronutrient(fieldValue)
        }
    }
    
    func addMicronutrient(_ fieldValue: FieldValue) {
        guard let group = fieldValue.microValue.nutrientType.group else {
            return
        }
        let field = Field(fieldValue: fieldValue)
        field.resetAndCropImage()
        switch group {
        case .fats:         microsFats.append(field)
        case .fibers:       microsFibers.append(field)
        case .sugars:       microsSugars.append(field)
        case .minerals:     microsMinerals.append(field)
        case .vitamins:     microsVitamins.append(field)
        case .misc:     	microsMisc.append(field)
        }
    }
}
