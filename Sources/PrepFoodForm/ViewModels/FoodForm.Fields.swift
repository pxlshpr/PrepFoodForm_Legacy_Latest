import SwiftUI
import FoodLabel
import PrepDataTypes
import MFPScraper
import VisionSugar

let DefaultAmount = FieldValue.amount(FieldValue.DoubleValue(double: 1, string: "1", unit: .serving, fill: .discardable))

extension FoodForm {
    
    class Fields: ObservableObject {
        
        var sources: Sources
        
        @Published var name: String = ""
        @Published var emoji: String = ""
        @Published var detail: String = ""
        @Published var brand: String = ""
        
        @Published var amount: Field
        @Published var serving: Field
        @Published var energy: Field
        @Published var carb: Field
        @Published var fat: Field
        @Published var protein: Field
        
        @Published var standardSizes: [Field] = []
        @Published var volumePrefixedSizes: [Field] = []
        @Published var density: Field

//        @Published var micronutrients: [MicroGroupTuple] = DefaultMicronutrients()
        
        @Published var microsFats: [Field] = []
        @Published var microsFibers: [Field] = []
        @Published var microsSugars: [Field] = []
        @Published var microsMinerals: [Field] = []
        @Published var microsVitamins: [Field] = []
        @Published var microsMisc: [Field] = []
        
        @Published var barcodes: [Field] = []

        @Published var shouldShowFoodLabel: Bool = false
        @Published var shouldShowDensity = false
        
        @Published var canBeSaved: Bool = false
        
        /**
         These are the last extracted `FieldValues` returned from the `FieldsExtractor`,
         which would have analysed and picked the best values from all available `ScanResult`s
         (after the user selects a column if applicable).
         */
        var extractedFieldValues: [FieldValue] = []
        var prefilledFood: MFPProcessedFood? = nil

        var sizeBeingEdited: FormSize? = nil

        init(sources: Sources) {
            self.sources = sources
            self.emoji = randomFoodEmoji()
            self.amount = .init(fieldValue: DefaultAmount, sources: sources)
            self.serving = .init(fieldValue: .serving(), sources: sources)
            self.energy = .init(fieldValue: .energy(), sources: sources)
            self.carb = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .carb)), sources: sources)
            self.fat = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .fat)), sources: sources)
            self.protein = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .protein)), sources: sources)
            self.density = .init(fieldValue: .density(FieldValue.DensityValue()), sources: sources)
        }
        
//        convenience init(mockPrefilledFood mfpFood: MFPProcessedFood) {
//            self.init(sources: sources)
//            self.prefilledFood = mfpFood
//            self.prefill(mfpFood)
//            self.updateFormState()
//        }
    }
}
