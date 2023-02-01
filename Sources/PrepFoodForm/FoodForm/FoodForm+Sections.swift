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
        
        return NavigationStack {
            QuickForm(title: "Details", saveAction: saveActionBinding) {
                FormStyledSection {
                    Grid(alignment: .leading) {
                        GridRow {
                            Text("Name")
                                .foregroundColor(.secondary)
                            Button {
                                Haptics.feedback(style: .soft)
                                showingNameForm = true
                            } label: {
                                Text(!fields.name.isEmpty ? fields.name : "Required")
                                    .foregroundColor(!fields.name.isEmpty ? .white : Color(.tertiaryLabel))
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
                                Haptics.feedback(style: .soft)
                                showingDetailForm = true
                            } label: {
                                Text(!fields.detail.isEmpty ? fields.detail : "Optional")
                                    .foregroundColor(!fields.detail.isEmpty ? .white : Color(.tertiaryLabel))
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
                                Haptics.feedback(style: .soft)
                                showingBrandForm = true
                            } label: {
                                Text(!fields.brand.isEmpty ? fields.brand : "Optional")
                                    .foregroundColor(!fields.brand.isEmpty ? .white : Color(.tertiaryLabel))
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
        .sheet(isPresented: $showingNameForm) {
            DetailsNameForm(title: "Name", name: $fields.name)
        }
        .sheet(isPresented: $showingDetailForm) {
            DetailsNameForm(title: "Detail", name: $fields.detail)
        }
        .sheet(isPresented: $showingBrandForm) {
            DetailsNameForm(title: "Brand", name: $fields.brand)
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
