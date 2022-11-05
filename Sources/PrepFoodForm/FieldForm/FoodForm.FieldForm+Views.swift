import SwiftUI
import SwiftUISugar

extension FoodForm.FieldForm {
    var body: some View {
        content
            .navigationTitle(titleString ?? fieldValue.description)
            .fullScreenCover(isPresented: $showingTextPicker) {
                textPicker
            }
            .onAppear {
                isFocused = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    shouldAnimateOptions = true
                    /// Wait a while before unlocking the `doNotRegisterUserInput` flag in case it was set (due to a value already being present)
                    doNotRegisterUserInput = false
                }
            }
    }
    
    var content: some View {
        FormStyledScrollView {
            textFieldSection
            supplementaryViewSection
            fillInfo
        }
    }
    
    //MARK: - TextField Section
    
    var textFieldSection: some View {
        @ViewBuilder
        var footer: some View {
            if let footerString {
                Text(footerString)
            } else {
                defaultFooter
            }
        }
        
        return Group {
            if let headerString {
                FormStyledSection(header: Text(headerString), footer: footer) {
                    HStack {
                        textField
                        unitView
                    }
                }
            } else {
                FormStyledSection(footer: footer) {
                    HStack {
                        textField
                        unitView
                    }
                }
            }
        }
    }
    
    var defaultFooter: some View {
        Group {
            if !isForDecimalValue {
                EmptyView()
            } else {
                Text("Enter \(fields.hasFillOptions(for: field.value) ? "or autofill " : "")a value")
            }
        }
    }
    
    //MARK: - TextField
    
    var textField: some View {
        let binding = Binding<String>(
            get: { fieldValue.string },
            set: {
                if !doNotRegisterUserInput, isFocused, $0 != field.value.string {
                    withAnimation {
                        field.registerUserInput()
                    }
                }
                field.value.string = $0
                
                fields.updateFormState()
            }
        )
        
        return TextField(placeholderString, text: binding)
            .multilineTextAlignment(.leading)
            .focused($isFocused)
            .font(textFieldFont)
            .if(isForDecimalValue) { view in
                view
                    .keyboardType(.decimalPad)
                    .frame(minHeight: 50)
            }
            .if(!isForDecimalValue) { view in
                view
                    .lineLimit(1...3)
            }
            .scrollDismissesKeyboard(.interactively)
    }
    
    //MARK: - Supplementary Section
    
    var supplementaryViewSection: some View {
        
        @ViewBuilder
        var footer: some View {
            if supplementaryView != nil, let supplementaryViewFooterString {
                Text(supplementaryViewFooterString)
            }
        }
        
        @ViewBuilder
        var header: some View {
            if supplementaryView != nil, let supplementaryViewHeaderString {
                Text(supplementaryViewHeaderString)
            }
        }
        
        return Group {
            if let supplementaryView {
                FormStyledSection(header: header, footer: footer) {
                    supplementaryView
                }
            }
        }
    }
    
    //MARK: - Fill Options Sections
    
    @ViewBuilder
    var fillInfo: some View {
        if fields.hasFillOptions(for: field.value) {
            FoodForm.FillInfo(
                field: field,
                shouldAnimate: $shouldAnimateOptions,
                didTapImage: {
                    showTextPicker()
                }, didTapFillOption: { fillOption in
                    didTapFillOption(fillOption)
                })
            .environmentObject(fields)
        }
    }
    
    //MARK: - Text Picker
    var textPicker: some View {
        TextPicker(
            imageViewModels: sources.imageViewModels,
            mode: textPickerMode
        )
        .onDisappear {
            guard field.isCropping else {
                return
            }
            field.cropFilledImage()
            doNotRegisterUserInput = false
        }
    }
    
    var textPickerMode: TextPickerMode {
        if isForDecimalValue {
            return .singleSelection(
                filter: .textsWithFoodLabelValues,
                selectedImageText: fieldValue.fill.imageText) { imageText in
                    didSelectImageTexts([imageText])
                }
        } else {
            return .multiSelection(
                filter: .textsWithoutFoodLabelValues,
                selectedImageTexts: fieldValue.fill.imageTexts) { imageTexts in
                    didSelectImageTexts(imageTexts)
                }
        }
    }
    
    //MARK: - Buttons
    
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                /// Do nothing to revert the values as the original `FieldViewModel` is still untouched
                doNotRegisterUserInput = true
                dismiss()
            }
        }
    }
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            saveButton
        }
    }
    
    @ViewBuilder
    var saveButton: some View {
        Button("Save") {
            saveAndDismiss()
        }
        .disabled(!isDirty)
    }
}
