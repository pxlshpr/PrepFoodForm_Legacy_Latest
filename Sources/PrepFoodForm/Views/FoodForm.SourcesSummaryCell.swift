import SwiftUI
import ActivityIndicatorView
import PhotosUI
import SwiftHaptics
import SwiftUISugar
import Camera
//import FoodLabelCamera

extension FoodForm {
    struct SourcesSummaryCell: View {
        @ObservedObject var sources: FoodForm.Sources
        @Binding var showingAddLinkAlert: Bool
        let didTapCamera: () -> ()
        
        @State var showingPhotosPicker = false
        @State var showingFoodLabelCamera = false
        @State var linkIsInvalid = false
        @State var link: String = ""
        @State var linkInfoBeingPresented: LinkInfo? = nil
    }
}

extension FoodForm.SourcesSummaryCell {
        
    var body: some View {
        Group {
//            if sources.isEmpty {
//                emptyContent
//            } else {
                filledContent
//            }
        }
        .alert(addLinkTitle, isPresented: $showingAddLinkAlert, actions: { addLinkActions }, message: { addLinkMessage })
        .photosPicker(
            isPresented: $showingPhotosPicker,
            selection: $sources.selectedPhotos,
//            maxSelectionCount: sources.availableImagesCount,
            maxSelectionCount: 1,
            matching: .images
        )
        .sheet(item: $linkInfoBeingPresented) { webView(for: $0) }
    }
    
    func webView(for linkInfo: LinkInfo) -> some View {
        NavigationStack {
            WebView(urlString: linkInfo.urlString, title: linkInfo.displayTitle)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self.linkInfoBeingPresented = nil
                        } label: {
                            closeButtonLabel
                        }
                    }
                }
        }
    }
    
    var emptyContent: some View {
        FormStyledSection(header: header, footer: emptyFooter, verticalPadding: 0) {
            addSourceButtons
        }
    }
    
    
    func showAddLinkAlert() {
        Haptics.feedback(style: .soft)
        if showingAddLinkAlert {
            /// Mitigates glitch where the alert fails to present if we're already presenting a `Menu`, but still sets this flag
            showingAddLinkAlert = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingAddLinkAlert = true
            }
        } else {
            showingAddLinkAlert = true
        }
    }
    
    var addSourceButtons: some View {
        HStack {
            foodFormButton("Camera", image: "camera") {
                Haptics.feedback(style: .soft)
                didTapCamera()
            }
            foodFormButton("Photo", image: "photo.on.rectangle") {
                Haptics.feedback(style: .soft)
                showingPhotosPicker = true
            }
            foodFormButton("Link", image: "link") {
                showAddLinkAlert()
            }
        }
        .padding(.vertical, 15)
    }
    
    func removeImageViewModel(_ imageViewModel: ImageViewModel) {
        guard let index = sources.imageViewModels.firstIndex(where: { $0.id == imageViewModel.id }) else {
            return
        }
        
        Haptics.feedback(style: .rigid)
        withAnimation {
            sources.removeImage(at: index)
        }
        FoodForm.Fields.shared.resetFillsForFieldsUsingImage(with: imageViewModel.id)
    }
    
    var buttonWidth: CGFloat {
        (UIScreen.main.bounds.width - (2 * 35.0) - (8.0 * 2.0)) / 3.0
    }
    
    var filledContent: some View {
        FormStyledSection(header: header, footer: filledFooter, horizontalPadding: 0, verticalPadding: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8.0) {
                    /// Images
                    ForEach(sources.imageViewModels, id: \.self.hashValue) { imageViewModel in
                        if let image = imageViewModel.image {
                            Menu {
                                Button(role: .destructive) {
                                    removeImageViewModel(imageViewModel)
                                } label: {
                                    Label("Remove", systemImage: "minus.circle")
                                }
                            } label: {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: buttonWidth, height: 80)
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 20,
                                            style: .continuous
                                        )
                                    )
//                                    .shadow(radius: 3, x: 0, y: 3)
                            }
                            .contentShape(Rectangle())
                            .simultaneousGesture(TapGesture().onEnded {
                                Haptics.feedback(style: .soft)
                            })
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .leading),
                                    removal: .scale
                                )
                            )
                        }
                    }
                    
                    /// Link
                    if let linkInfo = sources.linkInfo {
                        Menu {
                            Button {
                                Haptics.feedback(style: .soft)
                                linkInfoBeingPresented = linkInfo
                            } label: {
                                Label("View", systemImage: "safari")
                            }
                            Divider()
                            Button(role: .destructive) {
                                Haptics.successFeedback()
                                withAnimation {
                                    sources.removeLink()
                                }
                            } label: {
                                Label("Remove", systemImage: "minus.circle")
                            }
                        } label: {
                            LinkCell(linkInfo)
                                .frame(width: buttonWidth)
                        }
                        .contentShape(Rectangle())
                        .simultaneousGesture(TapGesture().onEnded {
                            Haptics.feedback(style: .soft)
                        })
                        .transition(.move(edge: .leading))
                    }
                    
                    if sources.isEmpty {
                        Group {
                            foodFormButton("Camera", image: "camera") {
                                Haptics.feedback(style: .soft)
                                didTapCamera()
                            }
                            foodFormButton("Photo", image: "photo.on.rectangle") {
                                Haptics.feedback(style: .soft)
                                showingPhotosPicker = true
                            }
                            foodFormButton("Link", image: "link") {
                                showAddLinkAlert()
                            }
                        }
                        .frame(width: buttonWidth)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .scale)
                        )
                    }

                    
                    /// Add Menu
                    if !sources.isEmpty {
                        
                        Menu {
                            
                            Section("Scan a Food Label") {
                                Button {
                                    Haptics.feedback(style: .soft)
                                    didTapCamera()
                                } label: {
                                    Label("Camera", systemImage: "camera")
                                }

                                Button {
                                    Haptics.feedback(style: .soft)
                                    showingPhotosPicker = true
                                } label: {
                                    Label("Choose Photo", systemImage: "photo.on.rectangle")
                                }
                            }
                            
                            Divider()

                            Button {
                                showAddLinkAlert()
                            } label: {
                                Label("Add a Link", systemImage: "link")
                            }
                            
                        } label: {
                            foodFormButton("Add", image: "plus", isSecondary: true)
                                .frame(width: buttonWidth)
                        }
                        .contentShape(Rectangle())
                        .simultaneousGesture(TapGesture().onEnded {
                            Haptics.feedback(style: .soft)
                        })
                        .transition(.move(edge: .trailing))
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
            }
        }
    }
        
    var navigationLink: some View {
        NavigationLink {
            FoodForm.SourcesForm(sources: sources)
        } label: {
            VStack(spacing: 0) {
                imagesRow
                linkRow
            }
        }
    }
    
    @ViewBuilder
    var linkRow: some View {
        if let linkInfo = sources.linkInfo {
            LinkCell(linkInfo, titleColor: .secondary, imageColor: .secondary, detailColor: Color(.tertiaryLabel))
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
        }
    }
    
    @ViewBuilder
    var imagesRow: some View {
        if !sources.imageViewModels.isEmpty {
            HStack(alignment: .top, spacing: LabelSpacing) {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(.secondary)
                    .frame(width: LabelImageWidth)
                VStack(alignment: .leading, spacing: 15) {
                    imagesGrid
                    imageSetSummary
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 15)
            if sources.linkInfo != nil {
                Divider()
                    .padding(.leading, 50)
            }
        }
    }

    var imagesGrid: some View {
        HStack {
            ForEach(sources.imageViewModels, id: \.self.hashValue) { imageViewModel in
                SourceImage(
                    imageViewModel: imageViewModel,
                    imageSize: .small
                )
            }
        }
    }
    
    var imageSetSummary: some View {
        FoodImageSetSummary(imageSetStatus: $sources.imageSetStatus)
    }

    var header: some View {
        Text("Sources")
    }
    
    @ViewBuilder
    var emptyFooter: some View {
        Button {
            
        } label: {
            VStack(alignment: .leading, spacing: 5) {
//                Text("A valid source is required for submission as a public food.")
                Text("A source is required to be eligible for the public database and accrue subscription tokens.")
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.leading)
                Label("Learn more", systemImage: "info.circle")
                    .foregroundColor(.accentColor)
            }
            .font(.footnote)
        }
    }
    
    @ViewBuilder
    var filledFooter: some View {
        if sources.isEmpty {
            emptyFooter
        } else {
            Text("This food can now be submitted for verification.")
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.leading)
        }
    }
    
    var addSourceMenu: some View {
        Menu {
            
            Button {
                showAddLinkAlert()
            } label: {
                Label("Add a Link", systemImage: "link")
            }

            Divider()

            Button {
                Haptics.feedback(style: .soft)
                showingPhotosPicker = true
            } label: {
                Label("Choose Photo\(sources.pluralS)", systemImage: "photo.on.rectangle")
            }
            
            Button {
                Haptics.feedback(style: .soft)
                didTapCamera()
            } label: {
                Label("Take Photo\(sources.pluralS)", systemImage: "camera")
            }

            Button {
                Haptics.feedback(style: .soft)
                showingFoodLabelCamera = true
            } label: {
                Label("Scan a Food Label", systemImage: "text.viewfinder")
            }
            
        } label: {
            Text("Add a Source")
                .frame(height: 50)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded {
            Haptics.feedback(style: .soft)
        })
    }
    
    //MARK: - Sheets
    var camera: some View {
        Camera { image in
            sources.addImageViewModel(ImageViewModel(image))
        }
    }
//    var foodLabelCamera: some View {
//        FoodLabelCamera { scanResult, image in
//            sources.add(image, with: scanResult)
//            NotificationCenter.default.post(name: .didScanFoodLabel, object: nil)
//        }
//    }
}

extension Notification.Name {
    public static var didScanFoodLabel: Notification.Name { return .init("didScanFoodLabel") }
}

//MARK: - Add Link Alert (Duplicated in FoodForm.SourcesForm)

extension FoodForm.SourcesSummaryCell {
    
    var addLinkTitle: String {
        linkIsInvalid ? "Invalid link" : "Add a Link"
    }
    
    var addLinkActions: some View {
        Group {
            TextField("Enter a URL", text: $link)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                .submitLabel(.done)
            Button("Add", action: {
                guard link.isValidUrl, let linkInfo = LinkInfo(link) else {
                    Haptics.errorFeedback()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        linkIsInvalid = true
                        showingAddLinkAlert = true
                    }
                    return
                }
                linkIsInvalid = false
                link = ""
                Haptics.successFeedback()
                withAnimation {
                    sources.addLink(linkInfo)
                }
            })
            Button("Cancel", role: .cancel, action: {})
        }
    }
    
    var addLinkMessage: some View {
        Text(linkIsInvalid ? "Please enter a valid URL." : "Please enter a link that verifies the nutrition facts of this food.")
    }

}

func foodFormButton(
    _ string: String,
    image: String,
    isSecondary: Bool = false,
    action: (() -> ())? = nil
) -> some View {
    
    @ViewBuilder
    var background: some View {
        if isSecondary {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundColor(Color(.tertiarySystemFill))
        } else {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundStyle(Color.accentColor.gradient)
        }
    }
    
    var textColor: Color {
        isSecondary ? .accentColor : .white
    }
    
    var label: some View {
        VStack(spacing: 5) {
            Image(systemName: image)
                .imageScale(.large)
                .fontWeight(.medium)
            Text(string)
                .fontWeight(.medium)
        }
        .foregroundColor(textColor)
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(background)
    }
    
    var button: some View {
        Button {
            action?()
        } label: {
            label
        }
    }
    
    return Group {
        if let action {
            button
        } else {
            label
        }
    }
}


