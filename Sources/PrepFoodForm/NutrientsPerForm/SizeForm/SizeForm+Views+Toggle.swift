import SwiftUI
import SwiftUISugar

extension SizeForm {
    
    var toggleSection: some View {
        FormStyledSection {
            toggle
        }
//        toggle
//            .frame(maxWidth: .infinity)
//            .padding(.horizontal, K.FormStyle.Padding.horizontal)
//            .padding(.vertical, K.FormStyle.Padding.vertical)
//            .background(
//                RoundedRectangle(cornerRadius: 10)
//                    .foregroundColor(formCellBackgroundColor(colorScheme: colorScheme))
//            )
//            .padding(.horizontal, 20)
//            .padding(.bottom, 10)
    }
    
    var toggle: some View {
        Toggle("Use a volume prefix", isOn: $viewModel.showingVolumePrefixToggle)
    }

    var footer: some View {
        Text("This will let you log this food in volumes of different densities or thicknesses, like – ‘cups shredded’, ‘cups sliced’.")
            .foregroundColor(FormFooterEmptyColor)
    }
    
}
