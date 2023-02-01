import SwiftUI
import SwiftHaptics
import PrepViews
import SwiftUISugar

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
            FormStyledVStack(customVerticalSpacing: 0) {
                topRow
                textFieldSection
                doneButtonRow
                Spacer()
            }
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: isFocused, perform: isFocusedChanged)
        }
        .presentationDetents([.height(190)])
        .presentationDragIndicator(.hidden)
    }
    
    var topRow: some View {
        var title: some View {
            Text("Quantity")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxHeight: .infinity, alignment: .center)
        }
        
        var closeButton: some View {
            Button {
                Haptics.feedback(style: .soft)
                dismiss()
            } label: {
                miniFormCloseLabel
            }
        }
        
        return HStack {
            title
                .padding(.top, 5)
            Spacer()
            closeButton
        }
        .frame(height: 30)
        .padding(.leading, 20)
        .padding(.trailing, 14)
        .padding(.top, 12)
        .padding(.bottom, 18)
    }
    
    var doneButtonRow: some View {
        
        var foregroundColor: Color {
            (colorScheme == .light && viewModel.shouldDisableDone)
            ? .black
            : .white
        }
        
        return HStack {
            Spacer()
            Button {
                Haptics.feedback(style: .rigid)
                sizeFormViewModel.quantity = viewModel.internalDouble ?? 1
                dismiss()
            } label: {
                Image(systemName: "checkmark")
//                Text("Done")
                    .bold()
                    .foregroundColor(foregroundColor)
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 19)
                            .foregroundStyle(Color.accentColor.gradient)
                            .shadow(color: Color(.black).opacity(0.2), radius: 2, x: 0, y: 2)
                    )
            }
            .disabled(viewModel.shouldDisableDone)
            .opacity(viewModel.shouldDisableDone ? 0.2 : 1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    var textFieldSection: some View {
        FormStyledSection {
            HStack {
                textField
                clearButton
            }
        }
    }
    
    func isFocusedChanged(_ newValue: Bool) {
        if !isFocused {
            dismiss()
        }
    }
    
    var leadingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                Haptics.feedback(style: .rigid)
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
