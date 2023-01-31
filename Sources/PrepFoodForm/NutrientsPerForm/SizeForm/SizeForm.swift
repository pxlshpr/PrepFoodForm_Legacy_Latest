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

    @State var showingDeleteConfirmation = false

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
            VStack {
                fieldSection
                toggleSection
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                FormBackground()
                    .edgesIgnoringSafeArea(.all) /// requireds to cover the area that would be covered by the keyboard during its dismissal animation
            )
            .toolbar { leadingContent }
            .toolbar { trailingContent }
            .navigationTitle("New Size")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: isFocused, perform: isFocusedChanged)
            .onChange(of: viewModel.showingVolumePrefixToggle,
                      perform: viewModel.changedShowingVolumePrefixToggle
            )
            .sheet(isPresented: $showingAmountForm) { amountForm }
            .sheet(isPresented: $showingQuantityForm) { quantityForm }
            .sheet(isPresented: $showingNameForm) { nameForm }
            .sheet(isPresented: $showingVolumePrefixUnitPicker) { unitPicker }
        }
        .presentationDetents([.height(400)])
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
        Text("Size")
            .font(.largeTitle)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
    }
    
    func isFocusedChanged(_ newValue: Bool) {
        if !isFocused {
            dismiss()
        }
    }
        
    var leadingContent: some ToolbarContent {
        func deleteButton(_ action: FormConfirmableAction) -> some View {
            var shadowSize: CGFloat { 2 }

            var confirmationActions: some View {
                Button(action.buttonTitle ?? "Delete", role: .destructive) {
//                    action.handler()
//                    cancelAction.handler()
                }
            }

            var confirmationMessage: some View {
                Text(action.message ?? "Are you sure?")
            }
            
            var label: some View {
                HStack {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 20))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            Color.red.opacity(0.75),
                            Color(.quaternaryLabel)
                                .opacity(0.5)
                        )
//                        .symbolRenderingMode(.multicolor)
//                        .foregroundColor(.red)
//                        .imageScale(.medium)
//                        .fontWeight(.medium)
//                        .padding(.leading, 5)
//                    Text("Delete")
//                        .padding(.trailing, 7)
                }
//                .frame(width: 38, height: 38)
//                .frame(width: 105, height: 38)
//                .background(
//                    RoundedRectangle(cornerRadius: 19)
//                        .foregroundStyle(.ultraThinMaterial)
//                        .shadow(color: Color(.black).opacity(0.2), radius: shadowSize, x: 0, y: shadowSize)
//                )
                .confirmationDialog(
                    "",
                    isPresented: $showingDeleteConfirmation,
                    actions: { confirmationActions },
                    message: { confirmationMessage }
                )
            }
            
            return Button {
                if action.shouldConfirm {
                    Haptics.warningFeedback()
//                    if let preconfirmationAction {
//                        preconfirmationAction()
//                        DispatchQueue.main.asyncAfter(deadline: FormSaveLayerPreConfirmationDelay) {
//                            showingDeleteConfirmation = true
//                        }
//                    } else {
                        showingDeleteConfirmation = true
//                    }
                } else {
//                    if let preconfirmationAction {
//                        preconfirmationAction()
//                        DispatchQueue.main.asyncAfter(deadline: FormSaveLayerPreConfirmationDelay) {
//                            action.handler()
//                        }
//                    } else {
                        action.handler()
//                    }
                }
            } label: {
                label
            }
        }
        
        return ToolbarItemGroup(placement: .navigationBarLeading) {
            Button {
                Haptics.feedback(style: .soft)
                dismiss()
            } label: {
                miniFormCloseLabel
            }
            deleteButton(.init(
                shouldConfirm: true,
                message: "Are you sure you want to remove this size?",
                buttonTitle: "Remove",
                handler: {
                    //TODO: Handle deletion
                }
            ))
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
            .disabled(viewModel.shouldDisableDone)
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
