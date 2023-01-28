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
                initialValue: fields.value(for: attribute),
                handleNewValue: { newValue in
                    handleNewValue(newValue, for: attribute)
                }
            )
        }
    }
    
    func handleNewValue(_ value: FoodLabelValue?, for attribute: Attribute) {
        func handleNewEnergyValue(_ value: FoodLabelValue) {
            fields.energy.value.energyValue.string = value.amount.cleanAmount
            if let unit = value.unit, unit.isEnergy {
                fields.energy.value.energyValue.unit = unit.energyUnit
            } else {
                fields.energy.value.energyValue.unit = .kcal
            }
            fields.energy.registerUserInput()
        }
        
        func handleNewMacroValue(_ value: FoodLabelValue, for macro: Macro) {
            
            let field = fields.field(for: macro)
            field.value.macroValue.string = value.amount.cleanAmount
            field.registerUserInput()

//            switch macro {
//            case .carb:
//                fields.carb.value.macroValue.string = value.amount.cleanAmount
//                fields.carb.registerUserInput()
//            case .fat:
//                fields.fat.value.macroValue.string = value.amount.cleanAmount
//                fields.fat.registerUserInput()
//            case .protein:
//                fields.protein.value.macroValue.string = value.amount.cleanAmount
//                fields.protein.registerUserInput()
//            }
        }
        
        func handleNewMicroValue(_ value: FoodLabelValue?, for nutrientType: NutrientType) {
            guard let field = fields.field(for: nutrientType) else { return }
            if let value {
                field.value.microValue.string = value.amount.cleanAmount
                if let unit = value.unit?.nutrientUnit(
                    for: field.value.microValue.nutrientType)
//                    , supportedUnits.contains(unit)
                {
                    field.value.microValue.unit = unit
                } else {
                    field.value.microValue.unit = nutrientType.defaultUnit
                }
                field.registerUserInput()
            } else {
                field.value.microValue.double = nil
                field.registerUserInput()
            }
        }
        
        if attribute == .energy {
            guard let value else { return }
            handleNewEnergyValue(value)
        } else if let macro = attribute.macro {
            guard let value else { return }
            handleNewMacroValue(value, for: macro)
        } else if let nutrientType = attribute.nutrientType {
            handleNewMicroValue(value, for: nutrientType)
        }
        fields.updateFormState()
    }
}

extension Field {
    var foodLabelValue: FoodLabelValue? {
        switch value {
        case .energy(let energyValue):
            guard let amount = energyValue.double else { return nil }
            let unit = energyValue.unit.foodLabelUnit ?? .kcal
            return FoodLabelValue(amount: amount , unit: unit)
        case .macro(let macroValue):
            guard let amount = macroValue.double else { return nil }
            return FoodLabelValue(amount: amount, unit: .g)
        case .micro(let microValue):
            guard let amount = microValue.double else { return nil }
            let unit = microValue.unit.foodLabelUnit ?? .g
            return FoodLabelValue(amount: amount, unit: unit)
        default:
            return nil
        }
    }
}

extension FoodForm.Fields {
    func value(for attribute: Attribute) -> FoodLabelValue? {
        field(for: attribute)?.foodLabelValue
    }
    
    func field(for attribute: Attribute) -> Field? {
        if attribute == .energy {
            return energy
        } else if let macro = attribute.macro {
            return field(for: macro)
        } else if let nutrientType = attribute.nutrientType {
            return field(for: nutrientType)
        }
        return nil
    }
    
    func field(for macro: Macro) -> Field {
        switch macro {
        case .carb:
            return carb
        case .fat:
            return fat
        case .protein:
            return protein
        }
    }
    
    func fieldsArray(for nutrientType: NutrientType) -> [Field]? {
        switch nutrientType.group {
        case .fats:
            return microsFats
        case .fibers:
            return microsFibers
        case .sugars:
            return microsSugars
        case .minerals:
            return microsMinerals
        case .vitamins:
            return microsVitamins
        case .misc:
            return microsMisc

        default:
            return nil
        }
    }
    func field(for nutrientType: NutrientType) -> Field? {
        guard let array = fieldsArray(for: nutrientType) else { return nil }
        return array.first(where: { $0.nutrientType == nutrientType } )
//        switch nutrientType.group {
//        case .fats:
//            return microsFats.first(where: { $0.nutrientType == nutrientType })
//        case .fibers:
//            return microsFibers.first(where: { $0.nutrientType == nutrientType })
//        case .sugars:
//            return microsSugars.first(where: { $0.nutrientType == nutrientType })
//        case .minerals:
//            return microsMinerals.first(where: { $0.nutrientType == nutrientType })
//        case .vitamins:
//            return microsVitamins.first(where: { $0.nutrientType == nutrientType })
//        case .misc:
//            return microsMisc.first(where: { $0.nutrientType == nutrientType })
//
//        default:
//            return nil
//        }
    }
}

class NutrientFormViewModel: ObservableObject {
    
    let attribute: Attribute
    let handleNewValue: (FoodLabelValue?) -> ()
    let initialValue: FoodLabelValue?
    
    @Published var unit: FoodLabelUnit
    @Published var internalTextfieldString: String = ""
    @Published var internalTextfieldDouble: Double? = nil
    
    init(
        attribute: Attribute,
        initialValue: FoodLabelValue?,
        handleNewValue: @escaping (FoodLabelValue?) -> Void
    ) {
        self.attribute = attribute
        self.handleNewValue = handleNewValue
        self.initialValue = initialValue
        
        if let initialValue {
            internalTextfieldDouble = initialValue.amount
            internalTextfieldString = initialValue.amount.cleanWithoutRounding
        }
        self.unit = initialValue?.unit ?? attribute.defaultUnit ?? .g
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
    
    var value: FoodLabelValue? {
        guard let internalTextfieldDouble else { return nil }
        return FoodLabelValue(amount: internalTextfieldDouble, unit: unit)
    }
    
    var shouldDisableDone: Bool {
        if initialValue == value {
            return true
        }
        if isRequired && internalTextfieldDouble == nil {
            return true
        }
        return false
    }
}

/// ** Next tasks **
/// [x] Support unit picker for micros too—consider feeding this with an attribute and it choosing the title and unit picker—making it reusable so we may use it again on the Extractor without much changes
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
        handleNewValue: @escaping (FoodLabelValue?) -> ()
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
                viewModel.handleNewValue(viewModel.value)
                dismiss()
            } label: {
                Text("Done")
                    .bold()
            }
            .disabled(viewModel.shouldDisableDone)
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
