import SwiftUI
import PrepDataTypes
import FoodLabelScanner
import SwiftHaptics

/// ** Next tasks **
/// [x] Support unit picker for micros too—consider feeding this with an attribute and it choosing the title and unit picker—making it reusable so we may use it again on the Extractor without much changes
/// [x] Support isDirty checking and only allowing tapping "Done" if its a different value from the initial
/// [x] Now plug this into energy by feeding it in from the `Fields` object and writing back to it once tapped done
/// [x] Make sure when saving it—we always register it as userInput as we'll only be going from AutoFilled / Selected - userInput
/// [x] Start using same icon for Autofilled and user input
/// [x] Consider having no icon for user input fields
/// [x] Now plug in for macros and micros
/// [x] Pre-select textfield if we have initial value / Consider doing this in Extractor as well
/// [ ] Have clear button in AttributeForm too / Also rename NutrientForm to AttributeForm
/// [ ] Now plug the extractor in / first do its save stuff
/// [ ] Now take unit picker to extractor
/// [ ] Now add the clear button extractor
/// [ ] Consider adding a clear button here too
/// [ ] Now revisit the UX with the sources etc and take it from there!

struct AttributeForm: View {
    
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    @State var hasFocusedOnAppear: Bool = false
    @State var hasCompletedFocusedOnAppearAnimation: Bool = false

    @StateObject var viewModel: AttributeFormViewModel
    
    init(
        attribute: Attribute,
        initialValue: FoodLabelValue? = nil,
        handleNewValue: @escaping (FoodLabelValue?) -> ()
    ) {
        _viewModel = StateObject(wrappedValue: .init(
            attribute: attribute,
            initialValue: initialValue,
            handleNewValue: handleNewValue
        ))
    }
    
    var placeholder: String {
        viewModel.isRequired ? "Required" : "Optional"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    textField
                    unitPicker
                }
            }
            .navigationTitle(viewModel.attribute.description)
            .toolbar { leadingContent }
            .toolbar { trailingContent }
            .onChange(of: isFocused, perform: isFocusedChanged)
        }
        .presentationDetents([.height(170)])
        .presentationDragIndicator(.hidden)
    }
    
    func isFocusedChanged(_ newValue: Bool) {
        if !isFocused {
            dismiss()
        }
    }
    
    var leadingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                Haptics.feedback(style: .soft)
                dismiss()
            }
        }
    }

    var trailingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                Haptics.successFeedback()
                viewModel.handleNewValue(viewModel.value)
                dismiss()
            } label: {
                Text("Done")
                    .bold()
            }
            .disabled(viewModel.shouldDisableDone)
        }
    }
    
    var textField: some View {
        let binding = Binding<String>(
            get: { viewModel.textFieldAmountString },
            set: { newValue in
                withAnimation {
                    viewModel.textFieldAmountString = newValue
                }
            }
        )

        return TextField(placeholder, text: binding)
            .focused($isFocused)
            .multilineTextAlignment(.leading)
            .font(binding.wrappedValue.isEmpty ? .body : .largeTitle)
            .keyboardType(.decimalPad)
            .frame(minHeight: 50)
            .scrollDismissesKeyboard(.never)
            .introspectTextField { uiTextField in
                if !hasFocusedOnAppear {
                    uiTextField.becomeFirstResponder()
                    uiTextField.selectedTextRange = uiTextField.textRange(from: uiTextField.beginningOfDocument, to: uiTextField.endOfDocument)

                    hasFocusedOnAppear = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeIn) {
                            hasCompletedFocusedOnAppearAnimation = true
                        }
                    }
                }
            }
    }
    
    @ViewBuilder
    var unitPicker: some View {
        if viewModel.attribute == .energy {
            Picker("", selection: $viewModel.unit) {
                ForEach(
                    [FoodLabelUnit.kcal, FoodLabelUnit.kj],
                    id: \.self
                ) { unit in
                    Text(unit.description).tag(unit)
                }
            }
            .pickerStyle(.segmented)
        } else if let nutrientType = viewModel.attribute.nutrientType {
            if nutrientType.supportedFoodLabelUnits.count > 1 {
                Picker("", selection: $viewModel.unit) {
                    ForEach(nutrientType.supportedFoodLabelUnits, id: \.self) { unit in
                        Text(unit.description).tag(unit)
                    }
                }
                .pickerStyle(.menu)
            } else {
                Text(nutrientType.supportedFoodLabelUnits.first?.description ?? "g")
                    .foregroundColor(.secondary)
            }
        } else {
            Text("g")
                .foregroundColor(.secondary)
        }
    }
}
