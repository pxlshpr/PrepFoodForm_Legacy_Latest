import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar
import FoodLabelScanner

extension FoodForm {
    struct NutrientsList: View {
        @EnvironmentObject var fields: FoodForm.Fields
        @EnvironmentObject var sources: FoodForm.Sources

        @StateObject var viewModel = ViewModel()
        
        @State var showingMicronutrientsPicker = false
        @State var showingImages = true
        @State var showingAttributeForm = false
    }
}

extension FoodForm.NutrientsList {
    class ViewModel: ObservableObject {
        @Published var attributeBeingEdited: Attribute? = nil
    }
}

extension FoodForm.NutrientsList {
    
    public var body: some View {
        scrollView
            .toolbar { navigationTrailingContent }
            .navigationTitle("Nutrition Facts")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingMicronutrientsPicker) { micronutrientsPicker }
            .sheet(isPresented: $showingAttributeForm) { attributeForm }
    }
    
    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                energyCell
                macronutrientsGroup
                micronutrientsGroup
            }
            .padding(.horizontal, 20)
            .safeAreaInset(edge: .bottom) {
                Spacer()
                    .frame(height: 60)
            }
        }
        .scrollContentBackground(.hidden)
        .background(
            FormBackground()
                .edgesIgnoringSafeArea(.all)
        )
//        .background(Color(.systemGroupedBackground))
    }
    
    @ViewBuilder
    var attributeForm: some View {
        if let attribute = viewModel.attributeBeingEdited {
            NutrientForm(
                attribute: attribute,
                handleNewValue: { newValue in
                    
                }
            )
        }
    }
}

class NutrientFormViewModel: ObservableObject {
    
    let attribute: Attribute
    let handleNewValue: (FoodLabelValue) -> ()
    let initialValue: FoodLabelValue?
    
    @Published var unit: FoodLabelUnit
    @Published var internalTextfieldString: String = ""
    @Published var internalTextfieldDouble: Double? = nil
    
    init(
        attribute: Attribute,
        initialValue: FoodLabelValue?,
        handleNewValue: @escaping (FoodLabelValue) -> Void
    ) {
        self.attribute = attribute
        self.handleNewValue = handleNewValue
        self.initialValue = initialValue
        
        self.unit = attribute.defaultUnit ?? .g
    }

    var textFieldAmountString: String {
        get { internalTextfieldString }
        set {
            guard !newValue.isEmpty else {
                internalTextfieldDouble = nil
                internalTextfieldString = newValue
                return
            }
            guard let double = Double(newValue) else {
                return
            }
            self.internalTextfieldDouble = double
            self.internalTextfieldString = newValue
        }
    }
    
    var isRequired: Bool {
        attribute == .energy || attribute.macro != nil
    }
}

/// ** Next tasks **
/// [ ] Support unit picker for micros too—consider feeding this with an attribute and it choosing the title and unit picker—making it reusable so we may use it again on the Extractor without much changes
/// [ ] Support isDirty checking and only allowing tapping "Done" if its a different value from the initial
/// [ ] Now plug this into energy by feeding it in from the `Fields` object and writing back to it once tapped done
/// [ ] Make sure when saving it—we always register it as userInput as we'll only be going from AutoFilled / Selected - userInput
/// [ ] Start using same icon for Autofilled and user input
/// [ ] Consider having no icon for user input fields
/// [ ] Now plug in for macros and micros
/// [ ] Now take unit picker to extractor
/// [ ] Now add the clear button extractor
/// [ ] Consider adding a clear button here too
/// [ ] Now plug the extractor in
/// [ ] Now revisit the UX with the sources etc and take it from there!

struct NutrientForm: View {
    
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    @State var hasFocusedOnAppear: Bool = false
    @State var hasCompletedFocusedOnAppearAnimation: Bool = false

    @StateObject var viewModel: NutrientFormViewModel
    
    init(
        attribute: Attribute,
        initialValue: FoodLabelValue? = nil,
        handleNewValue: @escaping (FoodLabelValue) -> ()
    ) {
        _viewModel = StateObject(wrappedValue: .init(
            attribute: attribute,
            initialValue: initialValue,
            handleNewValue: handleNewValue
        ))
    }
    
    var placeholder: String {
        viewModel.isRequired ? "Required" : "Optional"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    textField
                    unitPicker
                }
            }
            .navigationTitle(viewModel.attribute.description)
            .toolbar { leadingContent }
            .toolbar { trailingContent }
            .onChange(of: isFocused, perform: isFocusedChanged)
        }
        .presentationDetents([.height(170)])
        .presentationDragIndicator(.hidden)
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
                viewModel.handleNewValue(.init(amount: 1))
                dismiss()
            } label: {
                Text("Done")
                    .bold()
            }
        }
    }
    
    var textField: some View {
        let binding = Binding<String>(
            get: { viewModel.textFieldAmountString },
            set: { newValue in
                withAnimation {
                    viewModel.textFieldAmountString = newValue
                }
            }
        )

        return TextField(placeholder, text: binding)
            .focused($isFocused)
            .multilineTextAlignment(.leading)
            .font(binding.wrappedValue.isEmpty ? .body : .largeTitle)
            .keyboardType(.decimalPad)
            .frame(minHeight: 50)
            .scrollDismissesKeyboard(.never)
            .introspectTextField { uiTextField in
                if !hasFocusedOnAppear {
                    uiTextField.becomeFirstResponder()
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
    var unitPicker: some View {
        if viewModel.attribute == .energy {
            Picker("", selection: $viewModel.unit) {
                ForEach(
                    [FoodLabelUnit.kcal, FoodLabelUnit.kj],
                    id: \.self
                ) { unit in
                    Text(unit.description).tag(unit)
                }
            }
            .pickerStyle(.segmented)
        } else if let nutrientType = viewModel.attribute.nutrientType {
            if nutrientType.supportedFoodLabelUnits.count > 1 {
                Picker("", selection: $viewModel.unit) {
                    ForEach(nutrientType.supportedFoodLabelUnits, id: \.self) { unit in
                        Text(unit.description).tag(unit)
                    }
                }
                .pickerStyle(.menu)
            } else {
                Text(nutrientType.supportedFoodLabelUnits.first?.description ?? "g")
                    .foregroundColor(.secondary)
            }
        } else {
            Text("g")
                .foregroundColor(.secondary)
        }
    }
}

extension NutrientType {
    var supportedFoodLabelUnits: [FoodLabelUnit] {
        supportedNutrientUnits.map {
            $0.foodLabelUnit ?? .g
        }
    }
}
