//import SwiftUI
//import PrepDataTypes
//import SwiftHaptics
//import SwiftUISugar
//
//struct NutrientsPicker: View {
//    @Environment(\.dismiss) var dismiss
//    @Environment(\.colorScheme) var colorScheme
//
//    @EnvironmentObject var fields: FoodForm.Fields
//    let didAddNutrientTypes: ([NutrientType]) -> ()
//
//    @State var pickedNutrientTypes: [NutrientType] = []
//
//    @State var searchText = ""
//    @State var searchIsFocused: Bool = false
//}
//
//extension NutrientsPicker {
//    
//    var body: some View {
//        NavigationView {
//            SearchableView(
//                searchText: $searchText,
//                promptSuffix: "Micronutrients",
//                focused: $searchIsFocused,
//                content: {
//                    form
//                }
//            )
//            .navigationTitle("Add Micronutrients")
//            .navigationBarTitleDisplayMode(.large)
//            .toolbar { navigationLeadingContent }
//            .toolbar { navigationTrailingContent }
//        }
//    }
//    
//    func didSubmit() { }
//    
//    var navigationTrailingContent: some ToolbarContent {
//        ToolbarItemGroup(placement: .navigationBarTrailing) {
//            if !pickedNutrientTypes.isEmpty {
//                Button("Add \(pickedNutrientTypes.count)") {
//                    didAddNutrientTypes(pickedNutrientTypes)
//                    Haptics.successFeedback()
//                    dismiss()
//                }
//            }
//        }
//    }
//    var navigationLeadingContent: some ToolbarContent {
//        ToolbarItemGroup(placement: .navigationBarLeading) {
//            Button {
//                Haptics.feedback(style: .soft)
//                dismiss()
//            } label: {
//                closeButtonLabel
//            }
//        }
//    }
//
//    var form: some View {
//        Form {
//            ForEach(NutrientTypeGroup.allCases) {
//                if fields.hasUnusedMicros(in: $0, matching: searchText) {
//                    group(for: $0)
//                }
//            }
//        }
//    }
//    
//    func group(for group: NutrientTypeGroup) -> some View {
//        Section(group.description) {
//            ForEach(group.nutrients) {
//                if !fields.hasMicronutrient(for: $0) {
//                    cell(for: $0)
//                }
//            }
//        }
//    }
//    
//    func cell(for nutrientType: NutrientType) -> some View {
//        var shouldInclude: Bool
//        if !searchText.isEmpty {
//            shouldInclude = nutrientType.matchesSearchString(searchText)
//        } else {
//            shouldInclude = true
//        }
//        return Group {
//            if shouldInclude {
//                label(for: nutrientType)
//            }
//        }
//    }
//    
//    func label(for nutrientType: NutrientType) -> some View {
//        Button {
//            if pickedNutrientTypes.contains(nutrientType) {
//                pickedNutrientTypes.removeAll(where: { $0 == nutrientType })
//            } else {
//                pickedNutrientTypes.append(nutrientType)
//            }
//        } label: {
//            HStack {
//                Image(systemName: "checkmark")
//                    .opacity(pickedNutrientTypes.contains(nutrientType) ? 1 : 0)
//                    .animation(.default, value: pickedNutrientTypes)
//                Text(nutrientType.description)
//                    .foregroundColor(.primary)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .contentShape(Rectangle())
//            }
//        }
//    }
//}
