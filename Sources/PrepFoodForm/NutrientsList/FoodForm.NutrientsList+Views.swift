import SwiftUI
import SwiftUISugar
import SwiftHaptics

extension FoodForm.NutrientsList {

    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            addButton
            menuButton
        }
    }

    var addButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            showingMicronutrientsPicker = true
        } label: {
            Image(systemName: "plus")
                .padding(.vertical)
        }
        .buttonStyle(.borderless)
    }

    @ViewBuilder
    var menuButton: some View {
        if fields.containsFieldWithFillImage {
            Button {
                showingMenu = true
            } label: {
                Image(systemName: "ellipsis")
                    .padding(.vertical)
            }
        }
    }

    var micronutrientsPicker: some View {
        MicronutrientsPicker { nutrientTypes in
            withAnimation {
                fields.addMicronutrients(nutrientTypes)
            }
        }
        .environmentObject(fields)
    }
    
    //MARK: Decorator Views
    
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
    
    func subtitleCell(_ title: String) -> some View {
        Group {
            Spacer().frame(height: 5)
            HStack {
                Spacer().frame(width: 3)
                Text(title)
                    .font(.headline)
//                    .bold()
                    .foregroundColor(.secondary)
                Spacer()
            }
            Spacer().frame(height: 7)
        }
    }
    
    //MARK: Menu
    
    var bottomMenu: BottomMenu {
        BottomMenu(action: showHideAction)
    }

    var showHideAction: BottomMenuAction {
        BottomMenuAction(
            title: "\(showingImages ? "Hide" : "Show") Images",
            systemImage: "eye\(showingImages ? ".slash" : "")",
            tapHandler: {
                withAnimation {
                    showingImages.toggle()
                }
            })
    }
}
