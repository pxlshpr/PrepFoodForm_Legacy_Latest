import SwiftUI

struct LinkCell: View {
    
    @ObservedObject var linkInfo: LinkInfo
    let customTitle: String?
    let includeSymbol: Bool
    let alwaysIncludeUrl: Bool
    let titleColor: Color
    let imageColor: Color
    let detailColor: Color

    init(_ linkInfo: LinkInfo,
         title: String? = nil,
         alwaysIncludeUrl: Bool = false,
         includeSymbol: Bool = true,
         titleColor: Color = Color.accentColor,
         imageColor: Color = Color.accentColor,
         detailColor: Color = Color(.secondaryLabel)
    ) {
        self.linkInfo = linkInfo
        self.customTitle = title
        self.includeSymbol = includeSymbol
        self.alwaysIncludeUrl = alwaysIncludeUrl
        self.titleColor = titleColor
        self.imageColor = imageColor
        self.detailColor = detailColor
    }
    
    var title: String {
        guard let customTitle else {
            return linkInfo.title ?? linkInfo.urlString
        }
        return customTitle
    }
    var haveTitle: Bool {
        customTitle != nil || linkInfo.title != nil
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Group {
                    if includeSymbol {
                        HStack(alignment: .top, spacing: LabelSpacing) {
                            Image(systemName: "link")
                                .frame(width: LabelImageWidth)
                                .foregroundColor(imageColor)
                            Text(title)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(titleColor)
                            
                        }
//                        Label(title, systemImage: "link")
                    } else {
                        Text(title)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(titleColor)
                    }
                }
                .foregroundColor(.accentColor)
//                if alwaysIncludeUrl, haveTitle {
                    Text(linkInfo.urlDisplayString)
                        .font(.footnote)
                        .foregroundColor(detailColor)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, LabelSpacing + LabelImageWidth)
//                }
            }
            Spacer()
            if let image = linkInfo.faviconImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 21, height: 21)
                    .transition(.opacity)
            }
        }
    }
}
