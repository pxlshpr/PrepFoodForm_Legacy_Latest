import SwiftUI
import PrepDataTypes
import FoodLabelScanner

class SizeFormViewModel: ObservableObject {
    
    let handleNewSize: (FormSize) -> ()
    let initialField: Field?
    
    @Published var showingVolumePrefix = false
    @Published var showingVolumePrefixToggle: Bool = false

    @Published var sizeQuantityString = "1"
    @Published var sizeVolumePrefixString = "cup"
    @Published var sizeNameString = "chopped"
    @Published var sizeAmountDescription = "150 g"
    
//    @Published var unit: FormUnit
//    @Published var internalTextfieldString: String = ""
//    @Published var internalTextfieldDouble: Double? = nil
    
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
    
    

//    var textFieldAmountString: String {
//        get { internalTextfieldString }
//        set {
//            guard !newValue.isEmpty else {
//                internalTextfieldDouble = nil
//                internalTextfieldString = newValue
//                return
//            }
//            guard let double = Double(newValue) else {
//                return
//            }
//            self.internalTextfieldDouble = double
//            self.internalTextfieldString = newValue
//        }
//    }
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
    var shouldDisableDone: Bool {
        true
//        if initialField?.value.double == internalTextfieldDouble
//            && initialField?.value.doubleValue.unit == unit
//        {
//            return true
//        }
//
//        if isRequired && internalTextfieldDouble == nil {
//            return true
//        }
//        return false
    }
//
//    var shouldShowClearButton: Bool {
//        !textFieldAmountString.isEmpty
//    }
//
//    func tappedClearButton() {
//        textFieldAmountString = ""
//    }
//
//    var title: String {
//        isServingSize ? "Serving Size" : "Nutrients Per"
//    }
    
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
