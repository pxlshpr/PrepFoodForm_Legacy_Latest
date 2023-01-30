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

    var amountCell: some View {
        Button {
        } label: {
            FieldCell(field: fields.amount, showImage: $showingImages)
        }
    }

    var servingCell: some View {
        Button {
        } label: {
            FieldCell(field: fields.serving, showImage: $showingImages)
        }
    }

    var densityCell: some View {
        Button {
        } label: {
            FieldCell(field: fields.density, showImage: $showingImages)
        }
    }

    func sizeCell(for sizeField: Field) -> some View {
        Button {
            
        } label: {
            FieldCell(field: sizeField, showImage: $showingImages)
        }
    }
}

