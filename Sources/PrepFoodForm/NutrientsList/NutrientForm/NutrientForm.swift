import SwiftUI
import PrepDataTypes
import FoodLabelScanner
import SwiftHaptics
import SwiftUISugar


struct NutrientForm: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @FocusState var isFocused: Bool
    
    @State var hasFocusedOnAppear: Bool = false
    @State var hasCompletedFocusedOnAppearAnimation: Bool = false

    @StateObject var viewModel: NutrientFormViewModel
    
    init(
        nutrient: Nutrient,
        initialValue: FoodLabelValue? = nil,
        handleNewValue: @escaping (FoodLabelValue?) -> ()
    ) {
        _viewModel = StateObject(wrappedValue: .init(
            nutrient: nutrient,
            initialValue: initialValue,
            handleNewValue: handleNewValue
        ))
    }
    
    var placeholder: String {
        viewModel.isRequired ? "Required" : "Optional"
    }
    
    var body: some View {
        NavigationStack {
            QuickForm(title: viewModel.nutrient.description) {
                textFieldSection
            }
            .onChange(of: isFocused, perform: isFocusedChanged)
        }
        .presentationDetents([.height(140)])
        .presentationDragIndicator(.hidden)
    }

    var textFieldSection: some View {
        HStack(spacing: 0) {
            FormStyledSection(horizontalOuterPadding: 0) {
                HStack {
                    textField
                    unitPickerButton
                }
                .frame(maxHeight: 50)
            }
            .padding(.leading, 20)
            doneButton
                .padding(.horizontal, 20)
        }
    }
    
    var doneButton: some View {
        FormInlineDoneButton(disabled: viewModel.shouldDisableDone) {
            Haptics.successFeedback()
            viewModel.handleNewValue(viewModel.value)
            dismiss()
        }
    }
    
    func isFocusedChanged(_ newValue: Bool) {
        if !isFocused {
            dismiss()
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
            .frame(height: 50)
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
    
    var unitPickerButton: some View {
        
        func unitText(_ string: String) -> some View {
            Text(string)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 15)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color(.tertiarySystemFill))
                )
        }
        
        var unitPickerForEnergy: some View {
//            Picker("", selection: $viewModel.unit) {
//                ForEach(
//                    [FoodLabelUnit.kcal, FoodLabelUnit.kj],
//                    id: \.self
//                ) { unit in
//                    Text(unit.description).tag(unit)
//                }
//            }
//            .pickerStyle(.segmented)
            unitPicker(for: nil)
        }
        
        func unitPicker(for nutrientType: NutrientType?) -> some View {
            let binding = Binding<FoodLabelUnit>(
                get: { viewModel.unit },
                set: { newUnit in
                    withAnimation {
                        Haptics.feedback(style: .soft)
                        viewModel.unit = newUnit
                    }
                }
            )
            return Menu {
                Picker(selection: binding, label: EmptyView()) {
                    if let nutrientType {
                        ForEach(nutrientType.supportedFoodLabelUnits, id: \.self) {
                            Text($0.description).tag($0)
                        }
                    } else {
                        ForEach([FoodLabelUnit.kcal, FoodLabelUnit.kj], id: \.self) {
                            Text($0.description).tag($0)
                        }
                    }
                }
            } label: {
                HStack(spacing: 2) {
                    Text(viewModel.unit.description)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                }
                .foregroundColor(.accentColor)
                .padding(.horizontal, 15)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color.accentColor.opacity(
                            colorScheme == .dark ? 0.1 : 0.15
                        ))
                )
                .animation(.none, value: viewModel.unit)
            }
            .contentShape(Rectangle())
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
        }
        
        return Group {
            if viewModel.nutrient.isEnergy {
                unitPickerForEnergy
            } else if let nutrientType = viewModel.nutrient.nutrientType {
                if nutrientType.supportedFoodLabelUnits.count > 1 {
                    unitPicker(for: nutrientType)
                } else {
                    unitText(nutrientType.supportedFoodLabelUnits.first?.description ?? "g")
                }
            } else {
                unitText("g")
            }
        }
    }
}
