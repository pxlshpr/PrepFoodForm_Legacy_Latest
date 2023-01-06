import SwiftUI
import FoodLabel
import PrepDataTypes
import MFPScraper
import VisionSugar

let DefaultAmount = FieldValue.amount(FieldValue.DoubleValue(double: 1, string: "1", unit: .serving, fill: .discardable))

extension FoodForm {
    
    public class Fields: ObservableObject {
        
        static var shared = Fields()
        
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

        public init() {
            self.emoji = randomFoodEmoji()
            self.amount = .init(fieldValue: DefaultAmount)
            self.serving = .init(fieldValue: .serving())
            self.energy = .init(fieldValue: .energy())
            self.carb = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .carb)))
            self.fat = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .fat)))
            self.protein = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .protein)))
            self.density = .init(fieldValue: .density(FieldValue.DensityValue()))
        }
        
        convenience init(mockPrefilledFood mfpFood: MFPProcessedFood) {
            self.init()
            self.prefilledFood = mfpFood
            self.prefill(mfpFood)
            self.updateFormState()
        }
        
        /// Reset this by recreating what it would be with a fresh call to `init()` (for reuse as we have one `@StateObject` in the entire app
        public func reset() {
            
            name = ""
            emoji = randomFoodEmoji()
            detail = ""
            brand = ""
            
            amount = .init(fieldValue: DefaultAmount)
            serving = .init(fieldValue: .serving())
            energy = .init(fieldValue: .energy())
            carb = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .carb)))
            fat = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .fat)))
            protein = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .protein)))

            standardSizes = []
            volumePrefixedSizes = []
            density = .init(fieldValue: .density(FieldValue.DensityValue()))

            microsFats = []
            microsFibers = []
            microsSugars = []
            microsMinerals = []
            microsVitamins = []
            microsMisc = []
            
            barcodes = []

            shouldShowFoodLabel = false
            shouldShowDensity = false
            
            canBeSaved = false
            
            extractedFieldValues = []
            prefilledFood = nil

            sizeBeingEdited = nil
        }
    }
}
