import SwiftUI
import PrepDataTypes
import FoodLabelScanner
import SwiftHaptics
import SwiftUISugar

struct AttributeForm: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
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
                    clearButton
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
            Button {
                Haptics.feedback(style: .soft)
                dismiss()
            } label: {
                miniFormCloseLabel
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
    
    var unitPicker: some View {
        
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
        
        func unitPicker(for nutrientType: NutrientType) -> some View {
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
                    ForEach(nutrientType.supportedFoodLabelUnits, id: \.self) {
                        Text($0.description).tag($0)
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
                    unitPicker(for: nutrientType)
                } else {
                    unitText(nutrientType.supportedFoodLabelUnits.first?.description ?? "g")
                }
            } else {
                unitText("g")
            }
        }
    }
    
    @ViewBuilder
    var clearButton: some View {
        Button {
            viewModel.tappedClearButton()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    Color(.tertiaryLabel),
                    Color(.tertiarySystemFill)
                )

        }
        .opacity(viewModel.shouldShowClearButton ? 1 : 0)
        .buttonStyle(.borderless)
        .padding(.trailing, 5)
    }
}

var miniFormCloseLabel: some View {
    CloseButtonLabel_Temp()
//    closeButtonLabel
//    Text("Cancel")
}

public struct CloseButtonLabel_Temp: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    public init() { }
    
    public var body: some View {
        Image(systemName: "xmark.circle.fill")
            .font(.system(size: 30))
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                Color(hex: colorScheme == .light ? "838388" : "A0A0A8"),      /// 'x' symbol
//                Color(hex: colorScheme == .light ? "EEEEEF" : "313135") /// background
                Color(.quaternaryLabel).opacity(0.5)
            )
    }
}
