import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer

extension LabelScanner {
    
    var imageViewerLayer: some View {
        
        func imageViewer(_ image: UIImage) -> some View {
            ImageViewer(
                id: UUID(),
                image: image,
                textBoxes: $textBoxes,
                scannedTextBoxes: $scannedTextBoxes,
                contentMode: .fit,
                zoomBox: $zoomBox,
                showingBoxes: $showingBoxes,
                shimmering: $shimmering
            )
            .edgesIgnoringSafeArea(.all)
            .background(.black)
            .scaleEffect(animatingCollapse ? 0 : 1)
//            .padding(.top, animatingCollapse ? 400 : 0)
//            .padding(.trailing, animatingCollapse ? 300 : 0)
        }
        
        return Group {
//            if isCamera, let image {
            if let image {
                ZStack {
                    ZStack {
                        Color.clear
                        imageViewer(image)
                    }
//                    Color.clear
//                        .background(.thinMaterial)
//                    Color.black
//                        .opacity(shimmeringImage ? 0.8 : 0)
//                    croppedImagesCutoutLayer
//                        .scaleEffect(animatingCollapseOfCutouts ? 0 : 1)
//                        .opacity(animatingCollapseOfCutouts ? 0 : 1)
//                        .padding(.top, animatingCollapseOfCutouts ? 400 : 0)
//                        .padding(.trailing, animatingCollapseOfCutouts ? 300 : 0)
                    croppedImagesLayer
                        .scaleEffect(animatingCollapseOfCroppedImages ? 0 : 1)
                        .padding(.top, animatingCollapseOfCroppedImages ? 0 : 0)
                        .padding(.trailing, animatingCollapseOfCroppedImages ? 300 : 0)
                }
                .edgesIgnoringSafeArea(.all)
                .transition(.opacity)
            }
        }
    }    
}
