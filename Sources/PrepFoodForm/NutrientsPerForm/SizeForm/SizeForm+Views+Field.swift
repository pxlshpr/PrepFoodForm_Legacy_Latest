import SwiftUI
import SwiftUISugar
import SwiftHaptics

extension SizeForm {
    
    var fieldSection: some View {
        @ViewBuilder
        var footer: some View {
            if viewModel.showingVolumePrefix {
                Text("e.g. 2 x cup, shredded = 125 g")
            } else {
                Text("e.g. 5 x cookies = 58 g")
            }
        }
        
        return FormStyledSection(footer: footer, horizontalPadding: 0) {
            field
        }
    }
    
    var field: some View {
        fieldContents
            .frame(height: 50)
    }
    
    var fieldContents: some View {

        var quantityButton: some View {
            button(viewModel.quantity.cleanAmount) {
                Haptics.feedback(style: .soft)
                showingQuantityForm = true
            }
        }
        
        var multiplySymbol: some View {
            symbol("×")
                .layoutPriority(3)
        }
        
        var volumePrefixButton: some View {
            button(viewModel.volumePrefixUnit.shortDescription) {
                Haptics.feedback(style: .soft)
                showingVolumePrefixUnitPicker = true
            }
            .layoutPriority(2)
            .transition(.scale)
        }
        
        var volumePrefixCommaSymbol: some View {
            symbol(", ")
                .layoutPriority(3)
                .transition(.opacity)
        }
        
        var nameButton: some View {
            button(viewModel.name, placeholder: "name") {
                Haptics.feedback(style: .soft)
                showingNameForm = true
            }
            .layoutPriority(2)
        }
        
        var equalsSymbol: some View {
            symbol("=")
                .layoutPriority(3)
        }
        
        var amountButton: some View {
            button(viewModel.amountDescription, placeholder: "amount") {
                Haptics.feedback(style: .soft)
                showingAmountForm = true
            }
            .layoutPriority(1)
        }
        
        return HStack {
            Group {
                Spacer()
                quantityButton
                Spacer()
                multiplySymbol
                Spacer()
            }
            HStack(spacing: 0) {
                if viewModel.showingVolumePrefix {
                    volumePrefixButton
                    volumePrefixCommaSymbol
                }
                nameButton
            }
            Group {
                Spacer()
                equalsSymbol
                Spacer()
                amountButton
                Spacer()
            }
        }
    }
}
