import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar

extension FoodForm {
    struct NutrientsList: View {
        @EnvironmentObject var fields: FoodForm.Fields
        @EnvironmentObject var sources: FoodForm.Sources

        @State var showingMicronutrientsPicker = false
        @State var showingImages = true
        
        @State var showingEnergyForm = false
    }
}

extension FoodForm.NutrientsList {
    
    public var body: some View {
        scrollView
            .toolbar { navigationTrailingContent }
            .navigationTitle("Nutrition Facts")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingMicronutrientsPicker) { micronutrientsPicker }
            .sheet(isPresented: $showingEnergyForm) { energyForm }
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
    
    var energyForm: some View {
        NutrientForm(
            title: "Energy",
            handleNewValue: { newValue in
                
            }
        )
    }
}

struct NutrientForm: View {
    
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    @State var text: String = ""
    @State var unit: EnergyUnit = .kcal
    @State var hasFocusedOnAppear: Bool = false
    @State var hasCompletedFocusedOnAppearAnimation: Bool = false

    let title: String
    let handleNewValue: (FoodLabelValue) -> ()
    
    init(
        title: String,
        handleNewValue: @escaping (FoodLabelValue) -> ()
    ) {
        self.title = title
        self.handleNewValue = handleNewValue
    }
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    textField
                    unitPicker
                }
            }
            .navigationTitle(title)
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
                handleNewValue(.init(amount: 1))
                dismiss()
            } label: {
                Text("Done")
                    .bold()
            }
        }
    }

    var textField: some View {
        
        TextField("", text: $text)
            .focused($isFocused)
            .multilineTextAlignment(.leading)
            .font(text.isEmpty ? .body : .largeTitle)
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
    
    var unitPicker: some View {
        Picker("", selection: $unit) {
            ForEach(EnergyUnit.allCases, id: \.self) { unit in
                Text(unit.shortDescription).tag(unit)
            }
        }
        .pickerStyle(.segmented)
    }
}
