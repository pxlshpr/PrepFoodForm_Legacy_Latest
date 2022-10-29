import SwiftUI
import SwiftUISugar
import SwiftHaptics

extension FoodForm.AmountPerForm.DensityForm {

    var fieldSection: some View {
        FormStyledSection {
            HStack {
                Spacer()
                if weightFirst {
                    weightStack
                } else {
                    volumeStack
                }
                Spacer()
                Text("↔")
                    .font(.title2)
                    .foregroundColor(Color(.tertiaryLabel))
                Spacer()
                if weightFirst {
                    volumeStack
                } else {
                    weightStack
                }
                Spacer()
            }
        }
    }
    
    var weightStack: some View {
        HStack {
            weightTextField
                .padding(.vertical, 5)
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
            weightUnitButton
                .background(showColors ? .red : .clear)
                .layoutPriority(2)
        }
        .background(showColors ? .brown : .clear)
    }
    
    var volumeStack: some View {
        HStack {
            volumeTextField
                .padding(.vertical, 5)
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
            volumeUnitButton
                .background(showColors ? .blue : .clear)
        }
        .background(showColors ? .pink : .clear)
    }
    
    //MARK: - TextFields

    var weightTextField: some View {
        let binding = Binding<String>(
            get: { field.value.weight.string },
            set: {
                if !doNotRegisterUserInput, focusedField == .weight, $0 != field.value.weight.string {
                    withAnimation {
                        field.registerUserInput()
                    }
                }
                field.value.weight.string = $0
            }
        )
        
        return TextField("weight", text: binding)
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .focused($focusedField, equals: .weight)
//            .font(.title2)
            .font(field.value.weight.string.isEmpty ? .body : .title2)
    }
    
    var volumeTextField: some View {
        let binding = Binding<String>(
            get: { field.value.volume.string },
            set: {
                if !doNotRegisterUserInput, focusedField == .volume, $0 != field.value.volume.string {
                    withAnimation {
                        field.registerUserInput()
                    }
                }
                field.value.volume.string = $0
            }
        )
        
        return TextField("volume", text: binding)
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .focused($focusedField, equals: .volume)
//            .font(.title2)
            .font(field.value.volume.string.isEmpty ? .body : .title2)
    }
    
    //MARK: Unit Buttons
     
    var weightUnitButton: some View {
        Button {
            showingWeightUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(field.value.weight.unitDescription)
//                    Image(systemName: "chevron.up.chevron.down")
//                        .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }
    
    var volumeUnitButton: some View {
        Button {
            showingVolumeUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(field.value.volume.unitDescription)
//                    Image(systemName: "chevron.up.chevron.down")
//                        .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }
}
