import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar

extension FoodForm {
    struct NutrientsList: View {
        @EnvironmentObject var fields: FoodForm.Fields
        @EnvironmentObject var sources: FoodForm.Sources

        @State var showingMenu = false
        @State var showingMicronutrientsPicker = false

        @State var showingImages = true
    }
}

extension FoodForm.NutrientsList {
    
    public var body: some View {
        scrollView
            .toolbar { navigationTrailingContent }
            .navigationTitle("Nutrition Facts")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingMicronutrientsPicker) { micronutrientsPicker }
            .bottomMenu(isPresented: $showingMenu, menu: bottomMenu)
    }
    
    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                energyCell
                macronutrientsGroup
                micronutrientsGroup
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.systemGroupedBackground))
    }
}
