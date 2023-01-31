import SwiftUI
import SwiftHaptics
import PrepViews

extension SizeForm {
    struct NameForm: View {

        @EnvironmentObject var fields: FoodForm.Fields
        @ObservedObject var viewModel: SizeFormViewModel

        @Environment(\.dismiss) var dismiss
        @Environment(\.colorScheme) var colorScheme
        @FocusState var isFocused: Bool
        
        @State var hasFocusedOnAppear: Bool = false
        @State var hasCompletedFocusedOnAppearAnimation: Bool = false
    }
}

extension SizeForm.NameForm {
    
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
            .navigationTitle("Name")
            .toolbar { leadingContent }
            .toolbar { trailingContent }
            .onChange(of: isFocused, perform: isFocusedChanged)
            .safeAreaInset(edge: .bottom) { bottomSafeAreaContent }
        }
        .presentationDetents([.height(170 + 50.0)])
        .presentationDragIndicator(.hidden)
    }
    
    var bottomSafeAreaContent: some View {
        suggestionsBar
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
                            Haptics.feedback(style: .soft)
                            dismiss()
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

let SizeNameSuggestions = ["Bottle", "Box", "Biscuit", "Cookie", "Container", "Pack", "Sleeve"]
