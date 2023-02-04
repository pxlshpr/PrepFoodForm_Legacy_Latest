import SwiftUI
import PrepDataTypes
import FoodLabelScanner
import SwiftHaptics
import PrepViews
import SwiftUISugar

public struct SizeForm: View {
    
    @EnvironmentObject var fields: FoodForm.Fields
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @FocusState var isFocused: Bool
    
    @State var showingUnitPicker = false
    @State var hasFocusedOnAppear: Bool = false
    @State var hasCompletedFocusedOnAppearAnimation: Bool = false

    @StateObject var viewModel: SizeFormViewModel
    
    @State var showingQuantityForm = false
    @State var showingAmountForm = false
    @State var showingNameForm = false
    @State var showingVolumePrefixUnitPicker = false

    public init(
        initialField: Field? = nil,
        handleNewSize: @escaping (FormSize) -> ()
    ) {
        _viewModel = StateObject(wrappedValue: .init(
            initialField: initialField,
            handleNewSize: handleNewSize
        ))
    }

    public var body: some View {
        NavigationStack {
            QuickForm(
                title: "New Size",
                info: saveInfoBinding,
                saveAction: saveActionBinding,
                deleteAction: deleteActionBinding
            ) {
                fieldSection
                Spacer().frame(height: 8)
                toggleSection
            }
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: isFocused, perform: isFocusedChanged)
            .onChange(of: viewModel.showingVolumePrefixToggle,
                      perform: viewModel.changedShowingVolumePrefixToggle
            )
            .sheet(isPresented: $showingAmountForm) { amountForm }
            .sheet(isPresented: $showingQuantityForm) { quantityForm }
            .sheet(isPresented: $showingNameForm) { nameForm }
            .sheet(isPresented: $showingVolumePrefixUnitPicker) { unitPicker }
        }
        .presentationDetents([.height(330)])
        .presentationDragIndicator(.hidden)
    }
    
    var unitPicker: some View {
        UnitPickerGridTiered(
            pickedUnit: .volume(viewModel.volumePrefixUnit),
            includeServing: false,
            includeWeights: false,
            includeVolumes: true,
            sizes: [],
            allowAddSize: false,
            didPickUnit: { newUnit in
                withAnimation {
                    Haptics.feedback(style: .rigid)
                    viewModel.volumePrefixUnit = newUnit.volumeUnit ?? .cup
                }
            }
        )
    }
    
    var title: some View {
        Text("New Size")
            .font(.title2)
            .fontWeight(.bold)
            .frame(maxHeight: .infinity, alignment: .center)
    }
    
    func isFocusedChanged(_ newValue: Bool) {
        if !isFocused {
            dismiss()
        }
    }
    
    var amountForm: some View {
        AmountForm(sizeFormViewModel: viewModel)
    }
    
    var quantityForm: some View {
        QuantityForm(sizeFormViewModel: viewModel)
    }
    
    var nameForm: some View {
        NameForm(sizeFormViewModel: viewModel)
    }
}

extension SizeForm {
    
    var saveActionBinding: Binding<FormConfirmableAction?> {
        Binding<FormConfirmableAction?>(
            get: {
                .init(
                    confirmationButtonTitle: "Add",
                    isDisabled: viewModel.shouldDisableDone,
                    handler: {
                        
                    }
                )
            },
            set: { _ in }
        )
    }

    var deleteActionBinding: Binding<FormConfirmableAction?> {
        Binding<FormConfirmableAction?>(
            get: {
                .init(
                    shouldConfirm: true,
                    confirmationMessage: nil,
                    isDisabled: false,
                    buttonImage: "trash.fill",
                    handler: {
                        
                    }
                )
            },
            set: { _ in }
        )
    }
    
    var saveInfoBinding: Binding<FormSaveInfo?> {
        Binding<FormSaveInfo?>(
            get: {
                nil
            },
            set: { _ in }
        )
    }

}
