import SwiftUI
import VisionSugar
import FoodLabelScanner
import PrepDataTypes

public class ValuesPickerViewModel: ObservableObject {
    static var shared = ValuesPickerViewModel()
    @Published public var nutrients: [Nutrient] = []
    @Published public var currentAttribute: Attribute = .energy
    
    public init() {}
    
    public func reset() {
        self.currentAttribute = .energy
        self.nutrients = []
    }
    
    var currentNutrient: Nutrient? {
        nutrients.first(where: { $0.attribute == currentAttribute })
    }
    
    var currentAmountString: String {
        guard let amount = currentNutrient?.value?.amount else { return "" }
        return amount.cleanAmount
    }
    
    var currentUnitString: String {
        guard let unit = currentNutrient?.value?.unit else { return "" }
        return unit.description
    }
    
    func moveToNextAttribute() {
        guard let nextAttribute else { return }
        self.currentAttribute = nextAttribute
    }
    
    var currentAttributeText: RecognizedText? {
        guard let currentNutrient else { return nil }
        return currentNutrient.attributeText
    }
    
    var currentValueText: RecognizedText? {
        guard let currentNutrient else { return nil }
        return currentNutrient.valueText
    }

    var nextAttribute: Attribute? {
        nextAttribute(to: currentAttribute)
    }

    /// Returns the next element to `attribute` in `nutrients`,
    /// cycling back to the first once the end is reached.
    func nextAttribute(to attribute: Attribute) -> Attribute? {
        guard let index = nutrients.firstIndex(where: { $0.attribute == attribute })
        else { return nil }
        
        let nextIndex: Int
        if index >= nutrients.count - 1 {
            nextIndex = 0
        } else {
            nextIndex = index + 1
        }
        return nutrients[nextIndex].attribute
    }
}

public extension ValuesPickerViewModel {
    class Nutrient: ObservableObject, Identifiable {
        
        var attribute: Attribute
        var attributeText: RecognizedText? = nil
        @Published var isConfirmed: Bool = false
        @Published var value: FoodLabelValue? = nil
        @Published var valueText: RecognizedText? = nil
        
        init(
            attribute: Attribute,
            attributeText: RecognizedText? = nil,
            isConfirmed: Bool,
            value: FoodLabelValue? = nil,
            valueText: RecognizedText? = nil
        ) {
            self.attribute = attribute
            self.attributeText = attributeText
            self.isConfirmed = isConfirmed
            self.value = value
            self.valueText = valueText
        }
        
        public var id: Attribute {
            self.attribute
        }
    }
}

extension ValuesPickerViewModel.Nutrient: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(attribute)
        hasher.combine(attributeText)
        hasher.combine(isConfirmed)
        hasher.combine(value)
        hasher.combine(valueText)
    }
}

extension ValuesPickerViewModel.Nutrient: Equatable {
    public static func ==(lhs: ValuesPickerViewModel.Nutrient, rhs: ValuesPickerViewModel.Nutrient) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
