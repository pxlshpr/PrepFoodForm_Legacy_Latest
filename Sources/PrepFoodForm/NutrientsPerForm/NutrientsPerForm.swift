import SwiftUI
import SwiftUISugar
import FoodLabelScanner
import PrepDataTypes
import SwiftHaptics

extension NutrientsPerForm {
    class ViewModel: ObservableObject {
    }
}

struct NutrientsPerForm: View {

    @EnvironmentObject var fields: FoodForm.Fields
    @EnvironmentObject var sources: FoodForm.Sources
    
    @StateObject var viewModel = ViewModel()

    @State var showingAmountForm = false
    @State var showingServingForm = false
    
    @State var showingImages: Bool = true

    var body: some View {
        scrollView
//        .toolbar { navigationTrailingContent }
        .navigationTitle("Servings and Sizes")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAmountForm) { amountForm }
        .sheet(isPresented: $showingServingForm) { servingForm }
    }
    
    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                amountCell
                if fields.shouldShowServing {
                    servingCell
                }
                if fields.shouldShowDensity {
                    densityCell
                }
                sizesGroup
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
    }
    
    var sizesGroup: some View {
        var footerString: String {
            "Sizes give you additional portions to log this food in; like biscuit, bottle, container, etc."
        }
        
        return Group {
            titleCell("Sizes")
            ForEach(fields.allSizeFields, id: \.self) {
                sizeCell(for: $0)
            }
            addSizeButton
            footerCell(footerString)
        }
    }
    
    var addSizeButton: some View {
        Button {
        } label: {
            Text("Add a size")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.accentColor)
                .padding(.horizontal, 16)
                .padding(.bottom, 13)
                .padding(.top, 13)
                .background(FormCellBackground())
                .cornerRadius(10)
                .padding(.bottom, 10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }
    
    func titleCell(_ title: String) -> some View {
        Group {
            Spacer().frame(height: 15)
            HStack {
                Spacer().frame(width: 3)
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                Spacer()
            }
            Spacer().frame(height: 7)
        }
    }

    func footerCell(_ title: String) -> some View {
        Group {
//            Spacer().frame(height: 5)
            HStack {
                Spacer().frame(width: 3)
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 17)
            .offset(y: -3)
            Spacer()
                .frame(height: 12)
        }
    }
    var amountCell: some View {
        var footerString: String {
            "This is how much of this food the nutrition facts are for."
        }
        
        return Group {
            Button {
                Haptics.feedback(style: .soft)
                showingAmountForm = true
            } label: {
                FieldCell(field: fields.amount, showImage: $showingImages)
            }
            footerCell(footerString)
        }
    }

    var servingCell: some View {
        var footerString: String {
            if fields.serving.value.isEmpty {
                return "This is the size of 1 serving."
            }
            
            switch fields.serving.value.doubleValue.unit {
            case .weight:
                return "This is the weight of 1 serving."
            case .volume:
                return "This is the volume of 1 serving."
            case .size:
                return "This is the size of 1 serving."
//                return "This is how many \(size.prefixedName) 1 serving has."
//                return "This is how many \(size.prefixedName) is 1 serving."
            case .serving:
                return "Unsupported"
            }
        }

        return Group {
            Button {
                Haptics.feedback(style: .soft)
                showingServingForm = true
            } label: {
                FieldCell(field: fields.serving, showImage: $showingImages)
            }
            footerCell(footerString)
        }
    }

    var densityCell: some View {
        var footerString: String {
            var prefix: String {
                return fields.density.isValid
                ? "You can"
                : "Enter this to"
            }
            if fields.isWeightBased {
                return "\(prefix) also log this food using volume units, like cups."
            } else {
                return "\(prefix) also log this food using using its weight."
            }
        }
        
        return Group {
            Button {
            } label: {
                FieldCell(field: fields.density, showImage: $showingImages)
            }
            footerCell(footerString)
        }
    }

    func sizeCell(for sizeField: Field) -> some View {
        Button {
            
        } label: {
            FieldCell(field: sizeField, showImage: $showingImages)
        }
    }
}

extension NutrientsPerForm {
    var amountForm: some View {
        ServingForm(
            isServingSize: false,
            initialField: fields.amount,
            handleNewValue: { tuple in
                guard let tuple else { return }
                handleNewAmount(tuple.0, unit: tuple.1)
            }
        )
    }
    
    var servingForm: some View {
        ServingForm(
            isServingSize: true,
            initialField: fields.serving,
            handleNewValue: { tuple in
                guard let tuple else { return }
                handleNewServing(tuple.0, unit: tuple.1)
            }
        )
    }

    func handleNewAmount(_ double: Double, unit: FormUnit) {
        withAnimation {
            fields.amount.value.double = double
            fields.amount.value.doubleValue.unit = unit
            fields.amount.registerUserInput()
        }
    }
    
    func handleNewServing(_ double: Double, unit: FormUnit) {
        withAnimation {
            fields.serving.value.double = double
            fields.serving.value.doubleValue.unit = unit
            fields.serving.registerUserInput()
        }
    }

}
