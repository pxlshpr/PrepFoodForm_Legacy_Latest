import SwiftUI
import SwiftHaptics
import SwiftUISugar

extension FoodForm {
    struct DetailsForm: View {
        enum FocusedField {
            case name, detail, brand
        }
        
        @Environment(\.dismiss) var dismiss
        @FocusState private var focusedField: FocusedField?
        
        @EnvironmentObject var fields: FoodForm.Fields
        
        @State var name: String = ""
        @State var detail: String = ""
        @State var brand: String = ""
        
        @State var fieldFocus: [Bool] = [false, false, false]
        @State var hasBecomeFirstResponder: Bool = false
        @State var returnedOnLastField: Bool = false
    }
}

extension FoodForm.DetailsForm {

    var body: some View {
        form
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.large)
            .scrollDismissesKeyboard(.interactively)
            .interactiveDismissDisabled()
            .onAppear {
                name = fields.name
                detail = fields.detail
                brand = fields.brand
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    fieldFocus[0] = true
                }
            }
            .onChange(of: returnedOnLastField) { newValue in
                if newValue {
                    dismiss()
                }
            }
            .onChange(of: name) {
                fields.name = $0
                fields.updateCanBeSaved()
            }
            .onChange(of: detail) {
                fields.detail = $0
            }
            .onChange(of: brand) {
                fields.brand = $0
            }
    }
    
    var form: some View {
        Form {
            Section("Name") {
//                HStack {
//                    FormTextField (
//                        placeholder: "Required",
//                        text: $name,
//                        focusable: $fieldFocus,
//                        returnedOnLastField: $returnedOnLastField,
//                        returnKeyType: .next,
//                        autocapitalizationType: .words,
//                        keyboardType: .default,
//                        tag: 0
//                    )
//                    Button {
//                        Haptics.feedback(style: .rigid)
//                        name = ""
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(Color(.quaternaryLabel))
//                    }
//                    .opacity((fieldFocus[0] && !name.isEmpty) ? 1 : 0)
//                    .animation(.default, value: name)
//                }
                field(textField: nameTextField, text: $name, fieldIndex: 0)
            }
            Section("Detail") {
                field(textField: detailTextField, text: $detail, fieldIndex: 1)
            }
            Section("Brand") {
                field(textField: brandTextField, text: $brand, fieldIndex: 2)
            }
        }
        .scrollContentBackground(.hidden)
        .background(
            FormBackground()
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    func field(textField: some View, text: Binding<String>, fieldIndex: Int) -> some View {
        HStack {
            textField
            clearButton(text: text, fieldIndex: fieldIndex)
        }
        .listRowBackground(FormCellBackground())
    }
    
    func clearButton(text: Binding<String>, fieldIndex: Int) -> some View {
        Button {
            Haptics.feedback(style: .rigid)
            text.wrappedValue = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(Color(.quaternaryLabel))
        }
        .opacity((fieldFocus[fieldIndex] && !text.wrappedValue.isEmpty) ? 1 : 0)
        .animation(.default, value: text.wrappedValue)
    }

    var nameTextField: some View {
        FormTextField (
            placeholder: "Required",
            text: $name,
            focusable: $fieldFocus,
            returnedOnLastField: $returnedOnLastField,
            returnKeyType: .next,
            autocapitalizationType: .words,
            keyboardType: .default,
            tag: 0
        )
    }
    
    var detailTextField: some View {
        FormTextField (
            placeholder: "Optional",
            text: $detail,
            focusable: $fieldFocus,
            returnedOnLastField: $returnedOnLastField,
            returnKeyType: .next,
            autocapitalizationType: .words,
            keyboardType: .default,
            tag: 1
        )
    }
    
    var brandTextField: some View {
        FormTextField (
            placeholder: "Optional",
            text: $brand,
            focusable: $fieldFocus,
            returnedOnLastField: $returnedOnLastField,
            returnKeyType: .done,
            autocapitalizationType: .words,
            keyboardType: .default,
            tag: 2
        )
    }
}
