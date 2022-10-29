import SwiftUI
import ActivityIndicatorView
import PhotosUI
import SwiftHaptics
import SwiftUISugar

extension FoodForm {
    struct SourcesView: View {
        @ObservedObject var sources: FoodForm.Sources
        
        let didTapAddSource: () -> ()
        let handleSourcesAction: (SourcesAction) -> ()
    }
}

extension FoodForm.SourcesView {
        
    var body: some View {
        Group {
            if sources.isEmpty {
                emptyContent
            } else {
                content
            }
        }
    }
    
    var emptyContent: some View {
        FormStyledSection(header: header, footer: emptyFooter) {
            Button {
                didTapAddSource()
            } label: {
                Text("Add a source")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
        }
    }
    
    var content: some View {
        FormStyledSection(header: header, footer: filledFooter, horizontalPadding: 0, verticalPadding: 0) {
            navigationLink
        }
    }
    
    var navigationLink: some View {
        NavigationLink {
            FoodForm.SourcesForm(
                sources: sources,
                actionHandler: handleSourcesAction
            )
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
                Text("Add a source if you would like this food to be verified and generate subscription tokens.")
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.leading)
                Label("Learn more", systemImage: "info.circle")
                    .foregroundColor(.accentColor)
            }
            .font(.footnote)
        }
    }
    
    var filledFooter: some View {
        Text("This food can now be submitted for verification.")
            .foregroundColor(Color(.secondaryLabel))
            .multilineTextAlignment(.leading)
    }
}
