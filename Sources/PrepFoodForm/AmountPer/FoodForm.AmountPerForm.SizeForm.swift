import SwiftUI
import NamePicker
import SwiftUISugar
import SwiftHaptics
import VisionSugar
import PrepDataTypes

extension FoodForm.AmountPerForm {
    struct SizeForm: View {
        
        enum Route: Hashable {
            case quantity
            case name
            case amount
        }
        
        @State var path: [Route] = []

        @Environment(\.dismiss) var dismiss
        @EnvironmentObject var fields: FoodForm.Fields

        let existingField: Field?
        
        /// This stores a copy of the data from fieldViewModel until we're ready to persist the change
        @StateObject var field: Field
        
        @StateObject var formViewModel: SizeFormViewModel_Legacy
        @State var showingVolumePrefixToggle: Bool

        @State var shouldAnimateOptions = false
        @State var doNotRegisterUserInput: Bool = true

        @State var refreshBool = false

        @State var showingUnitPickerForVolumePrefix = false
//        @State var showingQuantityForm = false
//        @State var showingNamePicker = false
//        @State var showingAmountForm = false

        var didAddSizeViewModel: ((Field) -> ())?

        init(field: Field? = nil,
             includeServing: Bool = true,
             allowAddSize: Bool = true,
             didAddSizeViewModel: ((Field) -> ())? = nil
        ) {
            let formViewModel = SizeFormViewModel_Legacy(
                includeServing: includeServing,
                allowAddSize: allowAddSize,
                formState: field == nil ? .empty : .noChange
            )
            _formViewModel = StateObject(wrappedValue: formViewModel)

            self.existingField = field
            
            if let field {
                _showingVolumePrefixToggle = State(initialValue: field.size?.isVolumePrefixed ?? false)
                _field = StateObject(wrappedValue: field.copy)
            } else {
                _showingVolumePrefixToggle = State(initialValue: false)
                _field = StateObject(wrappedValue: Field.emptySize)
            }
            
            self.didAddSizeViewModel = didAddSizeViewModel
        }
    }
}

extension FoodForm.AmountPerForm.SizeForm {

    var body: some View {
        NavigationStack(path: $path) {
            form
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("\(isEditing ? "Edit" : "New") Size")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { navigationTrailingContent }
            .toolbar { navigationLeadingContent }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .quantity:     quantityForm
                case .name:         nameForm
                case .amount:       amountForm
                }
            }
        }
        .onAppear(perform: appeared)
        .onDisappear(perform: disappeared)
        .onChange(of: showingVolumePrefixToggle, perform: changedShowingVolumePrefixToggle)
        .onChange(of: field.sizeAmountUnit, perform: sizeChanged)
        .interactiveDismissDisabled(isDirty && !isEmpty)
        .sheet(isPresented: $showingUnitPickerForVolumePrefix) { unitPickerForVolumePrefix }
    }
    
    var form: some View {
        FormStyledScrollView {
            FormStyledSection {
                Editor(
                    field: field,
                    path: $path,
                    showingUnitPickerForVolumePrefix: $showingUnitPickerForVolumePrefix
                )
                    .environmentObject(formViewModel)
            }
            if field.sizeAmountUnit.unitType == .weight || !field.sizeAmountIsValid {
                volumePrefixSection
            }
            fillOptionsSections
        }
    }
}

