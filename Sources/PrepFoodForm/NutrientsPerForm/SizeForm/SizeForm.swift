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
    
    @State var showingQuantity = false
    @State var showingAmount = false

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
            .navigationTitle("Size")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: isFocused, perform: isFocusedChanged)
            .onChange(of: viewModel.showingVolumePrefixToggle,
                      perform: viewModel.changedShowingVolumePrefixToggle
            )
        }
        .presentationDetents([.height(350)])
        .presentationDragIndicator(.hidden)
        .sheet(isPresented: $showingAmount) { amountForm }
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
            .disabled(viewModel.shouldDisableDone)
        }
    }
    
    var amountForm: some View {
        AmountForm(viewModel: viewModel)
    }
}
