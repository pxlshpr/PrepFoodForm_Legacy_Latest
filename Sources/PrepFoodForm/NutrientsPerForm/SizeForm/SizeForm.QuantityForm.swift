import SwiftUI
import SwiftHaptics
import PrepViews

extension SizeForm {
    struct QuantityForm: View {

        @EnvironmentObject var fields: FoodForm.Fields
        
        @ObservedObject var sizeFormViewModel: SizeFormViewModel
        @StateObject var viewModel: ViewModel

        @Environment(\.dismiss) var dismiss
        @Environment(\.colorScheme) var colorScheme
        @FocusState var isFocused: Bool
        
        @State var hasFocusedOnAppear: Bool = false
        @State var hasCompletedFocusedOnAppearAnimation: Bool = false
        
        init(sizeFormViewModel: SizeFormViewModel) {
            self.sizeFormViewModel = sizeFormViewModel
            let viewModel = ViewModel(initialDouble: sizeFormViewModel.quantity)
            _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        class ViewModel: ObservableObject {
            let initialDouble: Double
            @Published var internalString: String = ""
            @Published var internalDouble: Double? = nil

            init(initialDouble: Double) {
                self.initialDouble = initialDouble
                self.internalDouble = initialDouble
                self.internalString = initialDouble.cleanAmount
            }
            
            var textFieldString: String {
                get { internalString }
                set {
                    guard !newValue.isEmpty else {
                        internalDouble = nil
                        internalString = newValue
                        return
                    }
                    guard let double = Double(newValue) else {
                        return
                    }
                    self.internalDouble = double
                    self.internalString = newValue
                }
            }
            
            var shouldDisableDone: Bool {
                if initialDouble == internalDouble {
                    return true
                }

                if internalDouble == nil {
                    return true
                }
                return false
            }
        }
    }
}

extension SizeForm.QuantityForm {
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        textField
                        clearButton
                    }
                }
            }
            .navigationTitle("Quantity")
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
                sizeFormViewModel.quantity = viewModel.internalDouble ?? 1
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
            get: { viewModel.textFieldString },
            set: { newValue in
                withAnimation {
                    viewModel.textFieldString = newValue
                }
            }
        )

        return TextField("e.g. \'5\' if \"5 cookies (50g)\"", text: binding)
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
    var clearButton: some View {
        Button {
            viewModel.textFieldString = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    Color(.tertiaryLabel),
                    Color(.tertiarySystemFill)
                )

        }
        .opacity(!viewModel.textFieldString.isEmpty ? 1 : 0)
        .buttonStyle(.borderless)
        .padding(.trailing, 5)
    }
}
