import SwiftUI
import PrepDataTypes

extension FoodForm {
    struct FieldForm<UnitView: View, SupplementaryView: View>: View {
        
        @EnvironmentObject var fields: Fields
        @EnvironmentObject var sources: Sources

        var unitView: UnitView?
        var supplementaryView: SupplementaryView?
        var supplementaryViewFooterString: String?
        var supplementaryViewHeaderString: String?
        let headerString: String?
        let footerString: String?
        let titleString: String?
        let placeholderString: String
        
        @ObservedObject var existingField: Field
        
        /// This stores a copy of the data from field until we're ready to persist the change
        @ObservedObject var field: Field
        
        @Environment(\.dismiss) var dismiss
        @FocusState var isFocused: Bool
        @State var showingTextPicker = false
        @State var doNotRegisterUserInput: Bool
        @State var uiTextField: UITextField? = nil
        @State var hasBecomeFirstResponder: Bool = false
        
        /// We're using this to delay animations to the `FlowLayout` used in the `FillOptionsGrid` until after the view appears—otherwise, we get a noticeable animation of its height expanding to fit its contents during the actual presentation animation—which looks a bit jarring.
        @State var shouldAnimateOptions = false
        
        /// Bring this back if we're having issues with tap targets on buttons, as mentioned here: https://developer.apple.com/forums/thread/131404?answerId=612395022#612395022
        //    @Environment(\.presentationMode) var presentation
        
        let setNewValue: ((FoodLabelValue) -> ())?
        let tappedPrefillFieldValue: ((FieldValue) -> ())?
        let didSave: (() -> ())?
        
        init(field: Field,
             existingField: Field,
             unitView: UnitView,
             headerString: String? = nil,
             footerString: String? = nil,
             titleString: String? = nil,
             placeholderString: String = "Required",
             supplementaryView: SupplementaryView,
             supplementaryViewHeaderString: String?,
             supplementaryViewFooterString: String?,
             didSave: (() -> ())? = nil,
             tappedPrefillFieldValue: ((FieldValue) -> ())? = nil,
             setNewValue: ((FoodLabelValue) -> ())? = nil
        ) {
            _doNotRegisterUserInput = State(initialValue: !existingField.value.string.isEmpty)
            
            self.existingField = existingField
            self.field = field
            self.unitView = unitView
            self.headerString = headerString
            self.footerString = footerString
            self.titleString = titleString
            self.placeholderString = placeholderString
            self.supplementaryView = supplementaryView
            self.supplementaryViewHeaderString = supplementaryViewHeaderString
            self.supplementaryViewFooterString = supplementaryViewFooterString
            self.didSave = didSave
            self.tappedPrefillFieldValue = tappedPrefillFieldValue
            self.setNewValue = setNewValue
        }
    }
}

extension FoodForm.FieldForm where UnitView == EmptyView {
    init(field: Field,
         existingField: Field,
         headerString: String? = nil,
         footerString: String? = nil,
         titleString: String? = nil,
         placeholderString: String = "Required",
         supplementaryView: SupplementaryView,
         supplementaryViewHeaderString: String?,
         supplementaryViewFooterString: String?,
         didSave: (() -> ())? = nil,
         tappedPrefillFieldValue: ((FieldValue) -> ())? = nil,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !existingField.value.string.isEmpty)
        
        self.existingField = existingField
        self.field = field
        self.unitView = nil
        self.headerString = headerString
        self.footerString = footerString
        self.titleString = titleString
        self.placeholderString = placeholderString
        self.supplementaryView = supplementaryView
        self.supplementaryViewHeaderString = supplementaryViewHeaderString
        self.supplementaryViewFooterString = supplementaryViewFooterString
        self.didSave = didSave
        self.tappedPrefillFieldValue = tappedPrefillFieldValue
        self.setNewValue = setNewValue
    }
}

extension FoodForm.FieldForm where SupplementaryView == EmptyView {
    init(field: Field,
         existingField: Field,
         unitView: UnitView,
         headerString: String? = nil,
         footerString: String? = nil,
         titleString: String? = nil,
         placeholderString: String = "Required",
         didSave: (() -> ())? = nil,
         tappedPrefillFieldValue: ((FieldValue) -> ())? = nil,
         didSelectImageTextsHandler: (([ImageText]) -> ())? = nil,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !existingField.value.string.isEmpty)
        
        self.existingField = existingField
        self.field = field
        self.unitView = unitView
        self.headerString = headerString
        self.footerString = footerString
        self.titleString = titleString
        self.placeholderString = placeholderString
        self.supplementaryView = nil
        self.supplementaryViewHeaderString = nil
        self.supplementaryViewFooterString = nil
        self.didSave = didSave
        self.tappedPrefillFieldValue = tappedPrefillFieldValue
        self.setNewValue = setNewValue
    }
}

extension FoodForm.FieldForm where UnitView == EmptyView, SupplementaryView == EmptyView {
    init(field: Field,
         existingField: Field,
         headerString: String? = nil,
         footerString: String? = nil,
         titleString: String? = nil,
         placeholderString: String = "Required",
         didSave: (() -> ())? = nil,
         tappedPrefillFieldValue: ((FieldValue) -> ())? = nil,
         didSelectImageTextsHandler: (([ImageText]) -> ())? = nil,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !existingField.value.string.isEmpty)
        self.existingField = existingField
        self.field = field
        self.unitView = nil
        self.headerString = headerString
        self.footerString = footerString
        self.titleString = titleString
        self.placeholderString = placeholderString
        self.supplementaryView = nil
        self.supplementaryViewHeaderString = nil
        self.supplementaryViewFooterString = nil
        self.didSave = didSave
        self.tappedPrefillFieldValue = tappedPrefillFieldValue
        self.setNewValue = setNewValue
    }
}

