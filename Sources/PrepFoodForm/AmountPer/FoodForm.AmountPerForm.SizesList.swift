import SwiftUI

extension FoodForm.AmountPerForm {
    struct SizesList: View {
        @EnvironmentObject var fields: FoodForm.Fields
        @EnvironmentObject var sources: FoodForm.Sources
        @State var showingAddSizeForm = false
        @State var sizeToEdit: Field?
    }
}

extension FoodForm.AmountPerForm.SizesList {
    
    var body: some View {
        list
            .toolbar { navigationTrailingContent }
            .toolbar { bottomBarContents }
            .sheet(isPresented: $showingAddSizeForm) { addSizeForm }
            .navigationTitle("Sizes")
            .sheet(item: $sizeToEdit) { editSizeForm(for: $0) }
    }
    
    var list: some View {
        List {
            if !fields.standardSizes.isEmpty {
                standardSizesSection
            }
            if !fields.volumePrefixedSizes.isEmpty {
                volumePrefixedSizesSection
            }
        }
    }
    
    var standardSizesSection: some View {
        Section {
            ForEach(fields.standardSizes.indices, id: \.self) { index in
                cellForStandardSize(at: index)
            }
            .onDelete(perform: deleteStandardSizes)
            .onMove(perform: moveStandardSizes)
        }
    }
    
    func cellForStandardSize(at index: Int) -> some View {
        let size = fields.standardSizes[index].value.size
        let icon = fields.standardSizes[index].fill.iconSystemImage
        return Group {
            if let size {
                Button {
                    sizeToEdit = fields.standardSizes[index]
                } label: {
                    Cell(size: size, icon: icon)
                }
            }
        }
    }
    
    func cellForVolumePrefixedSize(at index: Int) -> some View {
        let size = fields.volumePrefixedSizes[index].value.size
        let icon = fields.volumePrefixedSizes[index].fill.iconSystemImage
        return Group {
            if let size {
                Button {
                    sizeToEdit = fields.volumePrefixedSizes[index]
                } label: {
                    Cell(size: size, icon: icon)
                }
            }
        }
    }
    
    var volumePrefixedSizesSection: some View {
        var header: some View {
            Text("Volume-prefixed")
        }
        
        var footer: some View {
            Text("These let you log this food in volumes of different densities or thicknesses.")
                .foregroundColor(fields.volumePrefixedSizes.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
        }
        
        return Section(header: header, footer: footer) {
            ForEach(fields.volumePrefixedSizes.indices, id: \.self) { index in
                cellForVolumePrefixedSize(at: index)
            }
            .onDelete(perform: deleteVolumePrefixedSizes)
            .onMove(perform: moveVolumePrefixedSizes)
        }
    }
    
    var addSizeForm: some View {
        FoodForm.AmountPerForm.SizeForm(sources: sources)
            .environmentObject(fields)
    }
    
    @ViewBuilder
    func editSizeForm(for sizeField: Field) -> some View {
        FoodForm.AmountPerForm.SizeForm(field: sizeField, sources: sources) { sizeField in
            
        }
        .environmentObject(fields)
    }
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            EditButton()
        }
    }
    
    var bottomBarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                showingAddSizeForm = true
            } label: {
                Image(systemName: "plus")
            }
            Spacer()
        }
    }
    
    var addButtonSection: some View {
        Section {
            Button {
                showingAddSizeForm = true
            } label: {
                Text("Add a size")
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
        }
    }
    
    //MARK: - Actions
    
    func deleteStandardSizes(at offsets: IndexSet) {
        fields.standardSizes.remove(atOffsets: offsets)
    }
    
    func deleteVolumePrefixedSizes(at offsets: IndexSet) {
        fields.volumePrefixedSizes.remove(atOffsets: offsets)
    }
    
    func moveStandardSizes(from source: IndexSet, to destination: Int) {
        fields.standardSizes.move(fromOffsets: source, toOffset: destination)
    }
    
    func moveVolumePrefixedSizes(from source: IndexSet, to destination: Int) {
        fields.volumePrefixedSizes.move(fromOffsets: source, toOffset: destination)
    }
    
    enum SizesSection: String {
        case standard
        case volumePrefixed
    }
}
