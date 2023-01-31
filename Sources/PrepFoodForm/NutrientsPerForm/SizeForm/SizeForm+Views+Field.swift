import SwiftUI
import SwiftUISugar

extension SizeForm {
    
    var fieldSection: some View {
        field
            .frame(maxWidth: .infinity)
            .padding(.horizontal, K.FormStyle.Padding.horizontal)
            .padding(0)
            .padding(.vertical, K.FormStyle.Padding.vertical)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(formCellBackgroundColor(colorScheme: colorScheme))
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
    }
    
    var field: some View {
        fieldContents
            .frame(height: 50)
    }
    
    var fieldContents: some View {

        var quantityButton: some View {
            button(viewModel.sizeQuantityString) {
                showingQuantity = true
            }
        }
        
        var multiplySymbol: some View {
            symbol("×")
                .layoutPriority(3)
        }
        
        var volumePrefixButton: some View {
            button(viewModel.sizeVolumePrefixString) {
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
            button(viewModel.sizeNameString, placeholder: "name") {
            }
            .layoutPriority(2)
        }
        
        var equalsSymbol: some View {
            symbol("=")
                .layoutPriority(3)
        }
        
        var amountButton: some View {
            button(viewModel.sizeAmountDescription, placeholder: "amount") {                showingAmount = true
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
