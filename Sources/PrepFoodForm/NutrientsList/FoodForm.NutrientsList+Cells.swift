import SwiftUI
import PrepDataTypes

extension FoodForm.NutrientsList {
    
    //MARK: - Energy
    
    var energyCell: some View {
        NavigationLink {
            FoodForm.EnergyForm(existingField: fields.energy)
                .environmentObject(fields)
                .environmentObject(sources)
        } label: {
            Cell(field: fields.energy, showImage: $showingImages)
        }
    }

    //MARK: - Macros
    
    var macronutrientsGroup: some View {
        Group {
            titleCell("Macronutrients")
            macronutrientCell(for: fields.carb)
            macronutrientCell(for: fields.fat)
            macronutrientCell(for: fields.protein)
        }
    }

    func macronutrientCell(for field: Field) -> some View {
        NavigationLink {
            MacroForm(existingField: field)
                .environmentObject(fields)
                .environmentObject(sources)
                .onDisappear {
                    fields.updateCanBeSaved()
                }
        } label: {
            Cell(field: field, showImage: $showingImages)
        }
    }
    
    //MARK: - Micronutrients

    var micronutrientsGroup: some View {
        Group {
            titleCell("Micronutrients")

            microsGroup(.fats, fields: fields.microsFats)
            microsGroup(.fibers, fields: fields.microsFibers)
            microsGroup(.sugars, fields: fields.microsSugars)
            microsGroup(.minerals, fields: fields.microsMinerals)
            microsGroup(.vitamins, fields: fields.microsVitamins)
            microsGroup(.misc, fields: fields.microsMisc)
 
            if !fields.haveMicronutrients {
                addMicronutrientButton
            }
        }
    }
    
    @ViewBuilder
    func microsGroup(_ group: NutrientTypeGroup, fields: [Field]) -> some View {
        if !fields.isEmpty {
            Group {
                subtitleCell(group.description)
                ForEach(fields, id: \.self.nutrientType) { field in
                    micronutrientCell(for: field)
                }
            }
        }
    }
    
    func micronutrientCell(for field: Field) -> some View {
        NavigationLink {
            MicroForm(existingField: field)
                .environmentObject(fields)
                .environmentObject(sources)
        } label: {
            Cell(field: field, showImage: $showingImages)
        }
    }
    
    var addMicronutrientButton: some View {
        Button {
            showingMicronutrientsPicker = true
        } label: {
            Text("Add a micronutrient")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.accentColor)
                .padding(.horizontal, 16)
                .padding(.bottom, 13)
                .padding(.top, 13)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
                .padding(.bottom, 10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }
}
