import SwiftUI
import PrepDataTypes
import FoodLabelScanner
import SwiftHaptics
import PrepViews
import SwiftUISugar

struct ServingForm: View {
    
    @EnvironmentObject var fields: FoodForm.Fields
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @FocusState var isFocused: Bool
    
    @State var showingUnitPicker = false
    @State var hasFocusedOnAppear: Bool = false
    @State var hasCompletedFocusedOnAppearAnimation: Bool = false

    @StateObject var viewModel: ServingFormViewModel
    
    init(
        isServingSize: Bool,
        initialField: Field? = nil,
        handleNewValue: @escaping ((Double, FormUnit)?) -> ()
    ) {
        _viewModel = StateObject(wrappedValue: .init(
            isServingSize: isServingSize,
            initialField: initialField,
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
                    unitPickerButton
                }
            }
            .navigationTitle(viewModel.title)
            .toolbar { leadingContent }
            .toolbar { trailingContent }
            .onChange(of: isFocused, perform: isFocusedChanged)
        }
        .presentationDetents([.height(170)])
        .presentationDragIndicator(.hidden)
        .sheet(isPresented: $showingUnitPicker) { unitPicker }
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
                viewModel.handleNewValue(viewModel.returnTuple)
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
        UnitPickerGridTiered(
            pickedUnit: viewModel.unit,
            includeServing: !viewModel.isServingSize,
            includeWeights: true,
            includeVolumes: true,
            sizes: fields.allSizes,
//            servingDescription: "",
            allowAddSize: false,
            didPickUnit: { newUnit in
                withAnimation {
                    Haptics.feedback(style: .soft)
                    viewModel.unit = newUnit
                }
            }
        )
    }
    
    var unitPicker_legacy: some View {
        UnitPicker_Legacy(
            pickedUnit: viewModel.unit,
            includeServing: !viewModel.isServingSize,
            allowAddSize: false
        ) { newUnit in
            withAnimation {
                Haptics.feedback(style: .soft)
                viewModel.unit = newUnit
            }
        }
        .environmentObject(fields)
    }
    
    var unitPickerButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            showingUnitPicker = true
        } label: {
            HStack(spacing: 2) {
                Text(viewModel.unit.shortDescription)
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
