import SwiftUI
import SwiftHaptics
import PrepViews

extension SizeForm {
    struct AmountForm: View {

        @EnvironmentObject var fields: FoodForm.Fields
        @ObservedObject var viewModel: SizeFormViewModel

        @Environment(\.dismiss) var dismiss
        @Environment(\.colorScheme) var colorScheme
        @FocusState var isFocused: Bool
        
        @State var showingUnitPicker = false
        @State var hasFocusedOnAppear: Bool = false
        @State var hasCompletedFocusedOnAppearAnimation: Bool = false
    }
}

extension SizeForm.AmountForm {
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    textField
                    clearButton
                    unitPickerButton
                }
            }
            .navigationTitle("Amount")
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
//                viewModel.handleNewValue(viewModel.returnTuple)
                dismiss()
            } label: {
                Text("Done")
                    .bold()
            }
//            .disabled(viewModel.shouldDisableDone)
        }
    }
    
    var textField: some View {
//        let binding = Binding<String>(
//            get: { viewModel.textFieldAmountString },
//            set: { newValue in
//                withAnimation {
//                    viewModel.textFieldAmountString = newValue
//                }
//            }
//        )

        return TextField("Required", text: .constant(""))
            .focused($isFocused)
            .multilineTextAlignment(.leading)
//            .font(binding.wrappedValue.isEmpty ? .body : .largeTitle)
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
//            pickedUnit: viewModel.unit,
//            includeServing: !viewModel.isServingSize,
            pickedUnit: .weight(.g),
            includeServing: true,
            includeWeights: true,
            includeVolumes: true,
            sizes: fields.allSizes,
            allowAddSize: false,
            didPickUnit: { newUnit in
                withAnimation {
//                    Haptics.feedback(style: .soft)
//                    viewModel.unit = newUnit
                }
            }
        )
    }
    
    var unitPickerButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            showingUnitPicker = true
        } label: {
            HStack(spacing: 2) {
                Text("g")
//                Text(viewModel.unit.shortDescription)
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
//            .animation(.none, value: viewModel.unit)
        }
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    var clearButton: some View {
        Button {
//            viewModel.tappedClearButton()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    Color(.tertiaryLabel),
                    Color(.tertiarySystemFill)
                )

        }
//        .opacity(viewModel.shouldShowClearButton ? 1 : 0)
        .buttonStyle(.borderless)
        .padding(.trailing, 5)
    }
}
