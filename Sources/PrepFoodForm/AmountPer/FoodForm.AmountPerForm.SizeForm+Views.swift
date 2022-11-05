import SwiftUI
import SwiftUISugar

extension FoodForm.AmountPerForm.SizeForm {

    @ViewBuilder
    var fillOptionsSections: some View {
        if fields.hasFillOptions(for: field.value) {
            FoodForm.FillInfo(
                field: field,
                shouldAnimate: $shouldAnimateOptions,
                didTapImage: {
                    
                },
                didTapFillOption: { fillOption in
                    didTapFillOption(fillOption)
                }
            )
            .environmentObject(fields)
        }
    }
    
    var volumePrefixSection: some View {
        var footer: some View {
            Text("This will let you log this food in volumes of different densities or thicknesses, like – ‘cups shredded’, ‘cups sliced’.")
                .foregroundColor(!formViewModel.showingVolumePrefix ? FormFooterEmptyColor : FormFooterFilledColor)
        }
        
        return FormStyledSection(footer: footer) {
            Toggle("Volume-prefixed name", isOn: $showingVolumePrefixToggle)
        }
    }

    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                closeButtonLabel
            }
        }
    }

    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            saveButton
        }
    }
    
    var saveButton: some View {
        Button(isEditing ? "Save" : "Add") {
            saveAndDismiss()
        }
        .disabled(!field.isValid || !isDirty)
        .id(refreshBool)
    }
    
    //TODO: Remove this after showing a warning for existing sizes
    var bottomElements: some View {
        
        @ViewBuilder
        var statusElement: some View {
            switch formViewModel.formState {
            case .okToSave:
                VStack {
//                    addButton
//                    if didAddSizeViewModel == nil && !isEditing {
//                        addAndAddAnotherButton
//                    }
                }
                .transition(.move(edge: .bottom))
            case .duplicate:
                Label("There already exists a size with this name.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(Color(.secondaryLabel))
                    .symbolRenderingMode(.multicolor)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .foregroundColor(Color(.tertiarySystemFill))
                    )
                    .padding(.top)
                    .transition(.move(edge: .bottom))
            default:
                EmptyView()
            }
        }
        
        return ZStack {
            Color(.systemGroupedBackground)
            statusElement
                .padding(.bottom, 34)
                .zIndex(1)
        }
        .edgesIgnoringSafeArea(.bottom)
        .fixedSize(horizontal: false, vertical: true)
    }
    
}
