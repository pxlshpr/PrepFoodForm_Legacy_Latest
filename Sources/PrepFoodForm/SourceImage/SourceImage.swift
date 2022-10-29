import SwiftUI
import ActivityIndicatorView

struct SourceImage: View {
    
    @ObservedObject var imageViewModel: ImageViewModel
    
    let imageSize: ImageSize
    
    enum ImageSize {
        case small
        case medium
        
        var size: CGSize {
            switch self {
            case .small: return CGSize(width: 55, height: 55)
            case .medium: return CGSize(width: 120, height: 120)
            }
        }
    }
    
    init(imageViewModel: ImageViewModel, imageSize: ImageSize = .medium) {
        _imageViewModel = ObservedObject(wrappedValue: imageViewModel)
        self.imageSize = imageSize
    }
    
    var image: UIImage? {
        switch imageSize {
        case .medium: return imageViewModel.mediumThumbnail
        case .small: return imageViewModel.smallThumbnail
        }
    }
    
    @ViewBuilder
    var body: some View {
        Group {
            if let image {
                imageView(with: image)
            } else {
                placeholder
            }
        }
        .frame(width: imageSize.size.width, height: imageSize.size.height)
        .clipShape(
//            RoundedRectangle(cornerRadius: 10, style: .continuous)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
        )
        .shadow(radius: imageViewModel.status == .scanning ? 0 : 3, x: 0, y: 3)
        .animation(.default, value: imageViewModel.status)
    }
    
    var placeholder: some View {
        ZStack {
            Color(.systemFill)
//            ActivityIndicatorView(isVisible: .constant(true), type: .flickeringDots(count: 8))
            ActivityIndicatorView(isVisible: .constant(true), type: .flickeringDots())
//                .frame(width: 60, height: 60)
                .frame(width: 30, height: 30)
                .foregroundColor(Color(.tertiaryLabel))
        }
    }
    
    func imageView(with image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .overlay(overlay)
    }
    
    var overlay: some View {
        @ViewBuilder
        var color: some View {
            switch imageViewModel.status {
            case .scanning:
                Color(.darkGray)
                    .opacity(0.5)
            case .scanned:
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(.darkGray).opacity(0.9), location: 0),
                        .init(color: Color.clear, location: 0.3),
                        .init(color: Color.clear, location: 1)
                    ]),
                    startPoint: .bottomTrailing,
                    endPoint: .topLeading
                )
            default:
                Color.clear
            }
        }
        
        @ViewBuilder
        var activityView: some View {
            if imageViewModel.status == .scanning {
                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots(count: 3, inset: 2))
//                ActivityIndicatorView(isVisible: .constant(true), type: .flickeringDots(count: 8))
//                    .frame(width: 50, height: 50)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }
        }
        
        @ViewBuilder
        var checkmark: some View {
            if let image = imageViewModel.statusSystemImage {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: image)
                            .renderingMode(.original)
                            .foregroundColor(.white)
//                            .imageScale(.large)
                            .imageScale(.small)
                            .padding(2)
                            .background(
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
//                                    .foregroundColor(.accentColor)
                                    .foregroundColor(.green)
                                    .opacity(0.7)
                            )
                            .padding(5)
                    }
                }
            }
        }
        
        return ZStack {
            color
            activityView
            checkmark
        }
        .frame(width: imageSize.size.width, height: imageSize.size.height)
    }
}

//public struct SourceImagePreview: View {
//        
//    @StateObject var viewModel: ImageViewModel
//    
//    public init() {
//        let image = PrepFoodForm.sampleImage(6)!
//        let viewModel = ImageViewModel(image)
//        _viewModel = StateObject(wrappedValue: viewModel)
//    }
//    
//    public var body: some View {
//        SourceImage(imageViewModel: viewModel)
//    }
//}
//
//struct SourceImage_Previews: PreviewProvider {
//    static var previews: some View {
//        SourceImagePreview()
//    }
//}
