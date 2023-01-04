import SwiftUI
import SwiftHaptics
import SwiftUISugar
import PhotosUI

let LabelSpacing: CGFloat = 10
let LabelImageWidth: CGFloat = 20

extension FoodForm {
    //    enum SourcesAction {
    //        case removeLink
    //        case addLink
    //        case showPhotosMenu
    //        case removeImage(index: Int)
    //    }
    
    struct SourcesForm: View {
        @ObservedObject var sources: Sources
        @State var showingRemoveAllImagesConfirmation = false
        @State var showingPhotosPicker = false
        @State var showingTextPicker: Bool = false
        
        @State var showingRemoveLinkDialog = false
        @State var showingAddLinkAlert = false
        @State var linkIsInvalid = false
        @State var link: String = ""
        
        //        var actionHandler: ((SourcesAction) -> Void)
    }
}
extension FoodForm.SourcesForm {
    
    var body: some View {
        form
            .navigationTitle("Sources")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(isPresented: $showingTextPicker) { textPicker }
            .alert(addLinkTitle, isPresented: $showingAddLinkAlert, actions: { addLinkActions }, message: { addLinkMessage })
            .photosPicker(
                isPresented: $showingPhotosPicker,
                selection: $sources.selectedPhotos,
//                maxSelectionCount: sources.availableImagesCount,
                maxSelectionCount: 1,
                matching: .images
            )
    }
    
    var form: some View {
        FormStyledScrollView {
            if !sources.imageViewModels.isEmpty {
                imagesSection
            } else {
                addImagesSection
            }
            if let linkInfo = sources.linkInfo {
                linkSections(for: linkInfo)
            } else {
                addLinkSection
            }
        }
    }
    
    func linkSections(for linkInfo: LinkInfo) -> some View {
        FormStyledSection(header: Text("Link"), horizontalPadding: 0, verticalPadding: 0) {
            VStack(spacing: 0) {
                NavigationLink {
                    WebView(urlString: linkInfo.urlString)
                } label: {
                    LinkCell(linkInfo, alwaysIncludeUrl: true, includeSymbol: true)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                }
                Divider()
                    .padding(.leading, 50)
                removeLinkButton
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
            }
        }
    }
    
    var removeLinkButton: some View {
        Button(role: .destructive) {
            showingRemoveLinkDialog = true
        } label: {
            HStack(spacing: LabelSpacing) {
                Image(systemName: "minus.circle")
                    .frame(width: LabelImageWidth)
                Text("Remove Link")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .confirmationDialog("", isPresented: $showingRemoveLinkDialog, titleVisibility: .hidden) {
            Button("Remove Link", role: .destructive) {
                withAnimation {
                    Haptics.successFeedback()
                    sources.removeLink()
                }
            }
        }
    }
    
    var addLinkSection: some View {
        FormStyledSection(
            horizontalPadding: 17,
            verticalPadding: 15
        ) {
            Button {
                Haptics.feedback(style: .soft)
                showingAddLinkAlert = true
            } label: {
                Label("Add a Link", systemImage: "link")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    //MARK: - Images
    
    var imagesSection: some View {
        FormStyledSection(
            header: Text("Images"),
            horizontalPadding: 0,
            verticalPadding: 0
        ) {
            VStack(spacing: 0) {
                imagesCarousel
                    .padding(.vertical, 15)
                if sources.availableImagesCount > 0 {
                    Divider()
                    addImagesButton
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                }
            }
        }
    }
    
    var textPicker: some View {
        TextPicker(
            imageViewModels: sources.imageViewModels,
            mode: .imageViewer(
                initialImageIndex: sources.presentingImageIndex,
                deleteHandler: { deletedImageIndex in
                    removeImage(at: deletedImageIndex)
                },
                columnSelectionHandler: { selectedColumn, scanResult in
                    sources.autoFillHandler?(selectedColumn, scanResult)
                }
            )
        )
    }
    
    var imagesCarousel: some View {
        SourceImagesCarousel(imageViewModels: $sources.imageViewModels) { index in
            sources.presentingImageIndex = index
            showingTextPicker = true
        } didTapDeleteOnImage: { index in
            removeImage(at: index)
        }
    }
    
    var addImagesSection: some View {
        FormStyledSection(
            horizontalPadding: 17,
            verticalPadding: 15
        ) {
            addImagesButton
        }
    }
    
    var addImagesButton: some View {
        Button {
            showingPhotosPicker = true
        } label: {
            HStack(spacing: LabelSpacing) {
                Image(systemName: "plus")
                    .frame(width: LabelImageWidth)
                Text("Add Photo\(sources.pluralS)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
    }
    
    //MARK: - Actions
    func removeImage(at index: Int) {
        Haptics.feedback(style: .rigid)
        guard let id = sources.id(forImageAtIndex: index) else {
            return
        }
        withAnimation {
            sources.removeImage(at: index)
        }
        FoodForm.Fields.shared.resetFillsForFieldsUsingImage(with: id)
    }
}

//MARK: - Add Link Alert (Duplicated in FoodForm.SourcesSummaryCell)

extension FoodForm.SourcesForm {
    
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
