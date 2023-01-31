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
        
//        if let initialField {
//            internalTextfieldDouble = initialField.value.double ?? nil
//            internalTextfieldString = initialField.value.double?.cleanWithoutRounding ?? ""
//        }
//        self.unit = initialField?.value.doubleValue.unit ?? (isServingSize ? .weight(.g) : .serving)
    }

//
//    var isRequired: Bool {
//        !isServingSize
//    }
//
//    var returnTuple: (Double, FormUnit)? {
//        guard let internalTextfieldDouble else { return nil }
//        return (internalTextfieldDouble, unit)
//    }
//
    var amountDescription: String {
        guard let amount else { return "" }
        return "\(amount.cleanAmount) \(amountUnit.shortDescription)"
    }
    
    var shouldDisableDoneForSize: Bool {
        return true
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
