import SwiftUI
import SwiftHaptics
import SwiftUISugar
import PhotosUI

let LabelSpacing: CGFloat = 10
let LabelImageWidth: CGFloat = 20

extension FoodForm {
    enum SourcesAction {
        case removeLink
        case addLink
        case showPhotosMenu
        case removeImage(index: Int)
    }

    struct SourcesForm: View {
        @ObservedObject var sources: Sources
        @State var showingRemoveAllImagesConfirmation = false
        @State var showingPhotosPicker = false
        @State var showingTextPicker: Bool = false
        var actionHandler: ((SourcesAction) -> Void)
    }
}
extension FoodForm.SourcesForm {

    var body: some View {
        form
        .navigationTitle("Sources")
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(isPresented: $showingTextPicker) { textPicker }
        .photosPicker(
            isPresented: $showingPhotosPicker,
            selection: $sources.selectedPhotos,
            maxSelectionCount: sources.availableImagesCount,
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
            actionHandler(.removeLink)
        } label: {
            HStack(spacing: LabelSpacing) {
                Image(systemName: "trash")
                    .frame(width: LabelImageWidth)
                Text("Remove Link")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var addLinkSection: some View {
        FormStyledSection(
            horizontalPadding: 17,
            verticalPadding: 15
        ) {
            Button {
                actionHandler(.addLink)
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
                    actionHandler(.removeImage(index: deletedImageIndex))
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
            actionHandler(.showPhotosMenu)
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
        withAnimation {
            actionHandler(.removeImage(index: index))
        }
    }
}

