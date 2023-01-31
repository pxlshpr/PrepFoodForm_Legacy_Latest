import SwiftUI
import PrepDataTypes
import FoodLabelScanner

class SizeFormViewModel: ObservableObject {
    
    let handleNewSize: (FormSize) -> ()
    let initialField: Field?
    
    @Published var showingVolumePrefix = false
    @Published var showingVolumePrefixToggle: Bool = false

    @Published var quantity: Double = 1
    @Published var volumePrefixUnit: VolumeUnit = .cup
    @Published var name: String = ""
    @Published var amount: Double? = nil
    @Published var amountUnit: FormUnit = .weight(.g)

    init(
        initialField: Field?,
        handleNewSize: @escaping (FormSize) -> Void
    ) {
        self.handleNewSize = handleNewSize
        self.initialField = initialField
        
        if let initialField, let initialSize = initialField.size {
            self.quantity = initialSize.quantity ?? 1
            if let volumePrefixUnit = initialSize.volumePrefixUnit?.volumeUnit {
                self.volumePrefixUnit = volumePrefixUnit
                showingVolumePrefix = true
                showingVolumePrefixToggle = true
            }
            self.name = initialSize.name
            self.amount = initialSize.amount
            self.amountUnit = initialSize.unit
        }
    }

    var amountDescription: String {
        guard let amount else { return "" }
        return "\(amount.cleanAmount) \(amountUnit.shortDescription)"
    }
    
    var matchesInitialField: Bool {
        guard let initialSize = initialField?.size else { return false }
        return initialSize.name.lowercased() == name.lowercased()
        && initialSize.quantity == quantity
        && initialSize.volumePrefixUnit?.volumeUnit == volumePrefixUnit
        && initialSize.amount == amount
        && initialSize.unit == amountUnit
    }
    
    var hasMissingRequiredFields: Bool {
        amount == nil
        || name.isEmpty
    }
    
    var shouldDisableDone: Bool {
        if matchesInitialField {
            return true
        }
        
        if hasMissingRequiredFields {
            return true
        }
        return false
    }
    
    func changedShowingVolumePrefixToggle(to newValue: Bool) {
        withAnimation {
            showingVolumePrefix = showingVolumePrefixToggle
            //TODO: Rewrite this
//            /// If we've turned it on and there's no volume prefix for the size—set it to cup
//            if viewModel.showingVolumePrefixToggle {
//                if field.value.size?.volumePrefixUnit == nil {
//                    field.value.size?.volumePrefixUnit = .volume(.cup)
//                }
//            } else {
//                field.value.size?.volumePrefixUnit = nil
//            }
        }
    }

}
