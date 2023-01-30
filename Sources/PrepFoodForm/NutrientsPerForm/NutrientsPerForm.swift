import SwiftUI
import SwiftUISugar

struct NutrientsPerForm: View {

    @EnvironmentObject var fields: FoodForm.Fields
    @EnvironmentObject var sources: FoodForm.Sources
    @State var showingImages: Bool = true

    var body: some View {
        scrollView
//        .toolbar { navigationTrailingContent }
        .navigationTitle("Nutrients Per")
        .navigationBarTitleDisplayMode(.large)
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
            case .size(let size, _):
                return "This is how many \(size.prefixedName) is 1 serving."
            case .serving:
                return "Unsupported"
            }
        }

        return Group {
            Button {
            } label: {
                FieldCell(field: fields.serving, showImage: $showingImages)
            }
            footerCell(footerString)
        }
    }

    var densityCell: some View {
        var footerString: String {
            if fields.isWeightBased {
                return "Enter this to also log this food using volume units, like cups."
            } else {
                return "Enter this to also log this food using using its weight."
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

