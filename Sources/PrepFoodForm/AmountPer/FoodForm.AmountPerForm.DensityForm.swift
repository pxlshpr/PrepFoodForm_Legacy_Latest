import SwiftUI
import SwiftUISugar
import SwiftHaptics
import VisionSugar

extension FoodForm.AmountPerForm {
    
    struct DensityForm: View {
        
        enum FocusedField {
            case weight, volume
        }
        
        @EnvironmentObject var fields: FoodForm.Fields
        @ObservedObject var field: Field
//        @StateObject var field: Field

        @Environment(\.dismiss) var dismiss
        
        @State var showColors = false

        @State var showingWeightUnitPicker = false
        @State var showingVolumeUnitPicker = false
        @State var shouldAnimateOptions = false
        @State var showingTextPicker = false
        @State var doNotRegisterUserInput: Bool
        @State var hasBecomeFirstResponder: Bool = false
        @FocusState var focusedField: FocusedField?
        
        let weightFirst: Bool
        
        init(field: Field, orderWeightFirst: Bool) {
            
            self.field = field
//            _field = StateObject(wrappedValue: field)
            
            self.weightFirst = orderWeightFirst
            _doNotRegisterUserInput = State(initialValue: true)
        }
    }
}

extension FoodForm.AmountPerForm.DensityForm {
    
    var body: some View {
        form
        .navigationTitle("Unit Conversion")
        .onAppear(perform: appeared)
        .fullScreenCover(isPresented: $showingTextPicker) { textPicker }
    }
    
    var form: some View {
        FormStyledScrollView {
            fieldSection
            fillOptionsSections
        }
        .sheet(isPresented: $showingWeightUnitPicker) { weightUnitPicker }
        .sheet(isPresented: $showingVolumeUnitPicker) { volumeUnitPicker }
    }
    
    @ViewBuilder
    var fillOptionsSections: some View {
        if fields.hasFillOptions(for: field.value) {
            FoodForm.FillInfo(
                field: field,
                shouldAnimate: $shouldAnimateOptions,
                didTapImage: didTapImage,
                didTapFillOption: didTapFillOption
            )
            .environmentObject(fields)
        }
    }
}
