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
                servingCell
                densityCell
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
        Group {
            titleCell("Sizes")
            ForEach(fields.allSizeFields, id: \.self) {
                sizeCell(for: $0)
            }
        }
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
            .padding(.horizontal, 20)
            Spacer()
                .frame(height: 20)
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
            switch fields.serving.value.doubleValue.unit {
            case .weight:
                return "This is the weight of 1 serving. Enter this to log this food using its weight in addition to servings."
            case .volume:
                return "This is the volume of 1 serving. Enter this to log this food using its volume in addition to servings."
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
//            footerCell(footerString)
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

