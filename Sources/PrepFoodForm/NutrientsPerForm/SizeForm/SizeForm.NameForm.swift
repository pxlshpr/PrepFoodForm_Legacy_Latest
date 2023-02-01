import SwiftUI
import SwiftHaptics
import PrepViews
import SwiftUISugar

extension SizeForm {
    struct NameForm: View {

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
            let viewModel = ViewModel(initialString: sizeFormViewModel.name)
            _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        class ViewModel: ObservableObject {
            let initialString: String
            @Published var internalString: String = ""

            init(initialString: String) {
                self.initialString = initialString
                self.internalString = initialString
            }
            
            var shouldDisableDone: Bool {
                if initialString == internalString {
                    return true
                }

                if internalString.isEmpty {
                    return true
                }
                return false
            }
        }
    }
}

extension SizeForm.NameForm {
    
    var body: some View {
        NavigationStack {
            QuickForm(title: "Name") {
                textFieldSection
            }
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: isFocused, perform: isFocusedChanged)
            .safeAreaInset(edge: .bottom) { bottomSafeAreaContent }
        }
        .presentationDetents([.height(140 + 50.0)])
//        .presentationDetents([.height(100)])
        .presentationDragIndicator(.hidden)
    }
    
    var doneButton: some View {
        FormInlineDoneButton(disabled: viewModel.shouldDisableDone) {
            dismissAfterSetting(viewModel.internalString)
        }
    }
    
    var textFieldSection: some View {
        HStack(spacing: 0) {
            FormStyledSection(horizontalOuterPadding: 0) {
                HStack {
                    textField
                    clearButton
                }
            }
            .padding(.leading, 20)
            doneButton
                .padding(.horizontal, 20)
        }
    }
    
    var bottomSafeAreaContent: some View {
        suggestionsBar
    }
    
    func dismissAfterSetting(_ string: String) {
        Haptics.feedback(style: .rigid)
        sizeFormViewModel.name = string.lowercased()
        dismiss()
    }
    
    var suggestionsBar: some View {
        var keyboardColor: Color {
            colorScheme == .light ? Color(hex: K.ColorHex.keyboardLight) : Color(hex: "313133")
        }

        return ZStack {
            keyboardColor
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(SizeNameSuggestions, id: \.self) { suggestion in
                        Button {
                            dismissAfterSetting(suggestion)
                        } label: {
                            Text(suggestion.lowercased())
                                .foregroundColor(.secondary)
                                .padding(.vertical, 7)
                                .padding(.horizontal, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                                        .fill(colorScheme == .dark
                                              ? Color(.secondarySystemFill)
                                              : Color(.secondarySystemBackground)
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            .frame(height: 45)
            .padding(.top, 5)
//            .background(.green)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
    }
    
    func isFocusedChanged(_ newValue: Bool) {
        if !isFocused {
            dismiss()
        }
    }

    var textField: some View {
        let binding = Binding<String>(
            get: { viewModel.internalString },
            set: { newValue in
                withAnimation {
                    viewModel.internalString = newValue.lowercased()
                }
            }
        )

        return TextField("Required", text: binding)
            .focused($isFocused)
            .multilineTextAlignment(.leading)
            .font(binding.wrappedValue.isEmpty ? .body : .largeTitle)
            .keyboardType(.asciiCapable)
            .autocorrectionDisabled()
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
    
    var clearButton: some View {
        FormTextFieldClearButton(isEmpty: viewModel.internalString.isEmpty) {
            viewModel.internalString = ""
        }
    }
}

let SizeNameSuggestions = ["bottle", "box", "biscuit", "cookie", "container", "pack", "sleeve"]
