import SwiftUI
import SwiftHaptics
import SwiftUISugar

extension FoodForm.FillInfo {
    struct OptionsGrid: View {
        @EnvironmentObject var fields: FoodForm.Fields
        
        @ObservedObject var field: Field
        @Binding var shouldAnimate: Bool
        
        var didTapFillOption: (FillOption) -> ()
    }
}

extension FoodForm.FillInfo.OptionsGrid {
    
    var body: some View {
        flowLayout
    }
    
    var flowLayout: some View {
        FlowLayout(
            mode: .scrollable,
            items: fields.fillOptions(for: field.value),
            itemSpacing: 4,
            shouldAnimateHeight: $shouldAnimate
        ) { fillOption in
            fillOptionButton(for: fillOption)
        }
    }
    
    func fillOptionButton(for fillOption: FillOption) -> some View {
        FillOptionButton(fillOption: fillOption) {
            didTapFillOption(fillOption)
        }
        .buttonStyle(.borderless)
    }
}
