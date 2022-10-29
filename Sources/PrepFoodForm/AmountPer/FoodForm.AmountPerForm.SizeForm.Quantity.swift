import SwiftUI

extension FoodForm.AmountPerForm.SizeForm {
    struct Quantity: View {
        @ObservedObject var field: Field
        
        @Environment(\.dismiss) var dismiss
        @FocusState var isFocused: Bool
    }
}

extension FoodForm.AmountPerForm.SizeForm.Quantity {
    
    var body: some View {
        Form {
            Section(header: header, footer: footer) {
                HStack {
                    textField
                    stepper
                }
            }
        }
        .navigationTitle("Quantity")
        .navigationBarTitleDisplayMode(.large)
        .scrollDismissesKeyboard(.never)
        .interactiveDismissDisabled(field.sizeQuantityString.isEmpty)
        .onAppear { isFocused = true }
    }
    
    //MARK: - Components
    
    var textField: some View {
        TextField("Required", text: $field.sizeQuantityString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .font(field.sizeQuantityString.isEmpty ? .body : .largeTitle)
            .frame(minHeight: 50)
    }

    var stepper: some View {
        Stepper("", value: $field.sizeQuantity, in: 1...100000)
            .labelsHidden()
    }

    var header: some View {
        Text("Quantity")
//        Text(viewModel.amountUnit.unitType.description.lowercased())
    }
    
    var footer: some View {
        Text("""
This is used when nutritional labels display nutrients for more than a single serving or size.

For e.g. when the serving size reads '5 cookies (57g)', you would enter 5 as the quantity here. This allows us determine the nutrients for a single cookie.
"""
        )
        .foregroundColor(field.sizeQuantityString.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
    }
    

//    var quantiativeName: String {
//        "\(viewModel.quantityString) \(viewModel.name.isEmpty ? "of this size" : viewModel.name.lowercased())"
//    }
//
//    var description: String {
//        switch viewModel.amountUnit {
//        case .volume:
//            return "the volume of \(quantiativeName)"
//        case .weight:
//            return "how much \(quantiativeName) weighs"
//        case .serving:
//            return "how many servings \(quantiativeName) equals"
//        case .size:
//            return "how much of (insert size name here) \(quantiativeName) equals"
//        }
//    }
}
