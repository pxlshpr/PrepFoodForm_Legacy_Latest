import VisionSugar
import PrepDataTypes

extension RecognizedText {
    
    /**
     Returns the first detected `FoodLabelValue` in the string and all its candidates, if present.
     */
    var firstFoodLabelValue: FoodLabelValue? {
        string.detectedValues.first ?? (candidates.first(where: { !$0.detectedValues.isEmpty }))?.detectedValues.first
    }
    
    /**
     Returns true if the string or any of the other candidates contains `FoodLabelValues` in them.
     */
    var hasFoodLabelValues: Bool {
        !string.detectedValues.isEmpty
        || candidates.contains(where: { !$0.detectedValues.isEmpty })
    }
}

