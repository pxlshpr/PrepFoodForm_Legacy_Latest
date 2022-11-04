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
            Menu {
                Button {
                    Haptics.feedback(style: .soft)
                    withAnimation {
                        showingImages.toggle()
                    }
                } label: {
                    Label(
                        "\(showingImages ? "Hide" : "Show") Images",
                        systemImage: "eye\(showingImages ? ".slash" : "")"
                    )
                }
            } label: {
                Image(systemName: "ellipsis")
                    .padding(.vertical)
            }
            .contentShape(Rectangle())
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
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
}
