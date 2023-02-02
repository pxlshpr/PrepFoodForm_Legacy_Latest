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
        DetailsQuickForm()
            .environmentObject(fields)
    }
}


struct DetailsQuickForm: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var fields: FoodForm.Fields
    
    @State var showingBrandForm = false
    @State var showingNameForm = false
    @State var showingDetailForm = false

    var body: some View {
        NavigationStack {
            form
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
    
    var form: some View {
        QuickForm(title: "Details") {
            FormStyledSection {
                Grid(alignment: .leading) {
                    GridRow {
                        Text("Name")
                            .foregroundColor(.secondary)
                        fieldButton(fields.name, isRequired: true) {
                            showingNameForm = true
                        }
                    }
                    GridRow {
                        Text("Detail")
                            .foregroundColor(.secondary)
                        fieldButton(fields.detail) {
                            showingDetailForm = true
                        }
                    }
                    GridRow {
                        Text("Brand")
                            .foregroundColor(.secondary)
                        fieldButton(fields.brand) {
                            showingBrandForm = true
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    func fieldButton(_ string: String, isRequired: Bool = false, action: @escaping () -> ()) -> some View {
        let fill: Color = colorScheme == .light
        ? Color(hex: "EFEFF0")
        : Color(.secondarySystemFill)
        
        return Button {
            Haptics.feedback(style: .soft)
            action()
        } label: {
            Text(!string.isEmpty ? string : (isRequired ? "Required" : "Optional"))
                .foregroundColor(!string.isEmpty ? .primary : Color(.tertiaryLabel))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .foregroundColor(fill)
                )
        }
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
