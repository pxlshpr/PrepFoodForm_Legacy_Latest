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
//            pickedUnit: viewModel.unit,
//            includeServing: !viewModel.isServingSize,
            pickedUnit: .volume(.cup),
            includeServing: false,
            includeWeights: false,
            includeVolumes: true,
            sizes: [],
            allowAddSize: false,
            didPickUnit: { newUnit in
                withAnimation {
//                    Haptics.feedback(style: .soft)
//                    viewModel.unit = newUnit
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
            .disabled(viewModel.shouldDisableDoneForSize)
        }
    }
    
    var amountForm: some View {
        AmountForm(viewModel: viewModel)
    }
    
    var quantityForm: some View {
        QuantityForm(sizeFormViewModel: viewModel)
    }
    
    var nameForm: some View {
        NameForm(viewModel: viewModel)
    }
}
