import SwiftUI
import SwiftUISugar
import FoodLabel
import PrepDataTypes
import PrepViews
import SwiftHaptics

extension FoodForm {
    var detailsSection: some View {
        
        FormStyledSection(header: Text("Details")) {
            detailsCell
        }
    }
    
    public var detailsCell: some View {
        var emojiButton: some View {
            Button {
                Haptics.feedback(style: .soft)
                showingEmojiPicker = true
            } label: {
                Text(fields.emoji)
                    .font(.system(size: 50))
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.secondarySystemFill).gradient)
                    )
                    .padding(.trailing, 10)
            }
        }
        
        var detailsButton: some View {
            @ViewBuilder
            var nameText: some View {
                if !fields.name.isEmpty {
                    Text(fields.name)
                        .bold()
                        .multilineTextAlignment(.leading)
                } else {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
            
            @ViewBuilder
            var detailText: some View {
                if !fields.detail.isEmpty {
                    Text(fields.detail)
                        .multilineTextAlignment(.leading)
                }
            }

            @ViewBuilder
            var brandText: some View {
                if !fields.brand.isEmpty {
                    Text(fields.brand)
                        .multilineTextAlignment(.leading)
                }
            }
            
            return Button {
                Haptics.feedback(style: .soft)
                showingDetailsForm = true
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        nameText
                        detailText
                            .foregroundColor(.secondary)
                        brandText
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            }
            .contentShape(Rectangle())
        }
        
        return HStack {
            emojiButton
            detailsButton
        }
        .foregroundColor(.primary)
    }
    
    var sourcesSection: some View {
        SourcesSummaryCell(
            sources: sources,
            showingAddLinkAlert: $showingAddLinkAlert,
            didTapCamera: showExtractorViewWithCamera
        )
    }
    
    var foodLabelSection: some View {
        @ViewBuilder var header: some View {
            if !fields.shouldShowFoodLabel {
                Text("Nutrition Facts")
            }
        }
        
        return FormStyledSection(header: header) {
            NavigationLink {
                NutrientsList()
                    .environmentObject(fields)
                    .environmentObject(sources)
            } label: {
                if fields.shouldShowFoodLabel {
                    foodLabel
                } else {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    @ViewBuilder
    var prefillSection: some View {
        if let url = fields.prefilledFood?.sourceUrl {
            FormStyledSection(header: Text("Prefilled Food")) {
                NavigationLink {
                    WebView(urlString: url)
                } label: {
                    LinkCell(LinkInfo("https://myfitnesspal.com")!, title: "MyFitnessPal")
                }
            }
        }
    }
    
    var servingSection: some View {
        FormStyledSection(header: Text("Servings and Sizes")) {
            NavigationLink {
//                AmountPerForm()
                NutrientsPerForm(fields: fields)
                    .environmentObject(sources)
            } label: {
                if fields.hasAmount {
                    servingsAndSizesCell
//                    foodAmountPerView
                } else {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

extension FoodForm {
    var detailsForm: some View {
        var saveActionBinding: Binding<FormConfirmableAction?> {
            Binding<FormConfirmableAction?>(
                get: {
                    .init(buttonImage: "checkmark", isDisabled: false) {
                        
                    }
                },
                set: { _ in }
            )
        }
        
        func fieldButton(_ string: String, isRequired: Bool = false, action: @escaping () -> ()) -> some View {
            let r: CGFloat = 2.0
            
            let topLeft: Color = colorScheme == .light
            ? Color(red: 197/255, green: 197/255, blue: 197/255)
            : Color(hex: "050505")
//            : Color(hex: "131313")

            let bottomRight: Color = colorScheme == .light
            ? .white
//            : Color(hex: "5E5E5E")
            : Color(hex: "2A2A2C")

            let fill: Color = colorScheme == .light
            ? Color(hex: "EFEFF0")
//            ? Color(red: 236/255, green: 234/255, blue: 235/255)
//            : Color(hex: "404040")
            : Color(.secondarySystemFill)
            
            return Button {
                Haptics.feedback(style: .soft)
                action()
            } label: {
                Text(!string.isEmpty ? string : (isRequired ? "Required" : "Optional"))
                    .foregroundColor(!string.isEmpty ? .primary : Color(.tertiaryLabel))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(
                                    .shadow(.inner(color: topLeft, radius: r, x: r, y: r))
                                    .shadow(.inner(color: bottomRight,radius: r, x: -r, y: -r))
                                )
                                .foregroundColor(fill)
                    )
                
//                    .background(
//                        RoundedRectangle(cornerRadius: 5, style: .continuous)
//                            .foregroundStyle(Color(.secondarySystemFill).gradient)
//                    )
            }
        }
        
        return NavigationStack {
            QuickForm(title: "Details") {
                FormStyledSection {
                    Grid(alignment: .leading) {
                        GridRow {
                            Text("Name")
                                .foregroundColor(.secondary)
                            fieldButton(fields.name, isRequired: true) {
                                showingNameForm = true
                            }
//                            Button {
//                                Haptics.feedback(style: .soft)
//                                showingNameForm = true
//                            } label: {
//                                Text(!fields.name.isEmpty ? fields.name : "Required")
//                                    .foregroundColor(!fields.name.isEmpty ? .primary : Color(.tertiaryLabel))
//                                    .bold()
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.horizontal, 15)
//                                    .padding(.vertical, 10)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
//                                            .foregroundStyle(Color(.secondarySystemFill).gradient)
//                                    )
//                            }
                        }
                        GridRow {
                            Text("Detail")
                                .foregroundColor(.secondary)
                            fieldButton(fields.detail) {
                                showingDetailForm = true
                            }
//                            Button {
//                                Haptics.feedback(style: .soft)
//                                showingDetailForm = true
//                            } label: {
//                                Text(!fields.detail.isEmpty ? fields.detail : "Optional")
//                                    .foregroundColor(!fields.detail.isEmpty ? .primary : Color(.tertiaryLabel))
//                                    .bold()
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.horizontal, 15)
//                                    .padding(.vertical, 10)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
//                                            .foregroundStyle(Color(.secondarySystemFill).gradient)
//                                    )
//                            }
                        }
                        GridRow {
                            Text("Brand")
                                .foregroundColor(.secondary)
                            fieldButton(fields.brand) {
                                showingBrandForm = true
                            }
//                            Button {
//                                Haptics.feedback(style: .soft)
//                                showingBrandForm = true
//                            } label: {
//                                Text(!fields.brand.isEmpty ? fields.brand : "Optional")
//                                    .foregroundColor(!fields.brand.isEmpty ? .primary : Color(.tertiaryLabel))
//                                    .bold()
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.horizontal, 15)
//                                    .padding(.vertical, 10)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
//                                            .foregroundStyle(Color(.secondarySystemFill).gradient)
//                                    )
//                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
        .sheet(isPresented: $showingNameForm) {
            DetailsNameForm(title: "Name", isRequired: true, name: $fields.name)
        }
        .sheet(isPresented: $showingDetailForm) {
            DetailsNameForm(title: "Detail", isRequired: false, name: $fields.detail)
        }
        .sheet(isPresented: $showingBrandForm) {
            DetailsNameForm(title: "Brand", isRequired: false, name: $fields.brand)
        }
    }
}


struct DetailsQuickForm: View {
    var body: some View {
        NavigationStack {
            QuickForm(title: "Details", saveAction: saveActionBinding) {
                FormStyledSection {
                    Grid(alignment: .leading) {
                        GridRow {
                            Text("Name")
                                .foregroundColor(.secondary)
                            Button {
                                Haptics.feedback(style: .soft)
                            } label: {
                                Text("Triple Whopper")
                                    .foregroundColor(.white)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                                            .foregroundStyle(Color(.secondarySystemFill).gradient)
                                    )
                            }
                        }
                        GridRow {
                            Text("Detail")
                                .foregroundColor(.secondary)
                            Button {
                            } label: {
                                Text("With Cheese")
                                    .foregroundColor(.white)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                                            .foregroundStyle(Color(.secondarySystemFill).gradient)
                                    )
                            }
                        }
                        GridRow {
                            Text("Brand")
                                .foregroundColor(.secondary)
                            Button {
                                
                            } label: {
                                Text("Burger King")
                                    .foregroundColor(.white)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                                            .foregroundStyle(Color(.secondarySystemFill).gradient)
                                    )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.hidden)
    }
    
    var saveActionBinding: Binding<FormConfirmableAction?> {
        Binding<FormConfirmableAction?>(
            get: {
                .init(buttonImage: "checkmark", isDisabled: false) {
                    
                }
            },
            set: { _ in }
        )
    }

}

struct DetailsQuickFormPreview: View {
    
    var body: some View {
        Color.clear
            .sheet(isPresented: .constant(true)) {
                DetailsQuickForm()
                    .preferredColorScheme(.dark)
            }
    }
}

struct DetailsQuickForm_Previews: PreviewProvider {
    static var previews: some View {
        DetailsQuickFormPreview()
    }
}
