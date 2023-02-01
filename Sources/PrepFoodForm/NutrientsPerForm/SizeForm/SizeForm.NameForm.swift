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
            FormStyledVStack(customVerticalSpacing: 0) {
                topRow
                textFieldSection
                doneButtonRow
                Spacer()
            }
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: isFocused, perform: isFocusedChanged)
            .safeAreaInset(edge: .bottom) { bottomSafeAreaContent }
        }
        .presentationDetents([.height(170 + 50.0 + 20)])
//        .presentationDetents([.height(100)])
        .presentationDragIndicator(.hidden)
    }
    
    var topRow: some View {
        var title: some View {
            Text("Name")
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
                dismissAfterSetting(viewModel.internalString)
            } label: {
                Text("Done")
                    .bold()
                    .foregroundColor(foregroundColor)
                    .frame(width: 100, height: 38)
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
    
    var leadingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismissAfterSetting(viewModel.internalString)
            } label: {
                Text("Done")
                    .bold()
            }
            .disabled(viewModel.shouldDisableDone)
        }
    }
    
    var trailingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                Haptics.feedback(style: .soft)
                dismiss()
            } label: {
                miniFormCloseLabel
            }
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
    
    @ViewBuilder
    var clearButton: some View {
        Button {
            viewModel.internalString = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    Color(.tertiaryLabel),
                    Color(.tertiarySystemFill)
                )

        }
        .opacity(!viewModel.internalString.isEmpty ? 1 : 0)
        .buttonStyle(.borderless)
        .padding(.trailing, 5)
    }
}

let SizeNameSuggestions = ["bottle", "box", "biscuit", "cookie", "container", "pack", "sleeve"]
