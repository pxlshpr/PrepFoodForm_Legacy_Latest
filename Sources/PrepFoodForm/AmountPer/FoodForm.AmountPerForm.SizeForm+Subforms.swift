import SwiftUI
import NamePicker

extension FoodForm.AmountPerForm.SizeForm {
    var quantityForm: some View {
        Quantity(field: field)
    }
    
    var nameForm: some View {
        let binding = Binding<String>(
            get: { field.value.string },
            set: {
                if $0 != field.value.string {
                    withAnimation {
                        field.registerUserInput()
                    }
                }
                field.value.string = $0
            }
        )

        return NamePicker(
                name: binding,
                showClearButton: true,
                focusOnAppear: true,
                lowercased: true,
                title: "Name",
                titleDisplayMode: .large,
                presetStrings: ["Bottle", "Box", "Biscuit", "Cookie", "Container", "Pack", "Sleeve"]
            )
    }
    
    var amountForm: some View {
        Amount(field: field)
            .environmentObject(formViewModel)
    }
    
    var unitPickerForVolumePrefix: some View {
        UnitPicker_Legacy(
            pickedUnit: field.sizeVolumePrefixUnit,
            filteredType: .volume)
        { unit in
            field.value.size?.volumePrefixUnit = unit
        }
        .environmentObject(fields)
        .onDisappear {
            refreshBool.toggle()
        }
    }
    
}
