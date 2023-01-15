import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer

extension LabelInteractiveScanner {
    
    var imageViewerLayer: some View {
        
        func imageViewer(_ image: UIImage) -> some View {
            
            let isFocused = Binding<Bool>(
                get: { viewModel.showingColumnPicker || viewModel.showingValuePicker },
                set: { _ in }
            )
            
            return ImageViewer(
                id: UUID(),
                image: image,
                textBoxes: $viewModel.textBoxes,
                scannedTextBoxes: $viewModel.scannedTextBoxes,
                contentMode: .fit,
                zoomBox: $viewModel.zoomBox,
                showingBoxes: $viewModel.showingBoxes,
                showingCutouts: $viewModel.showingCutouts,
                shimmering: $viewModel.shimmering,
                isFocused: isFocused
            )
            .edgesIgnoringSafeArea(.all)
//            .background(.black)
            .scaleEffect(viewModel.animatingCollapse ? 0 : 1)
            .opacity(viewModel.shimmeringImage ? 0.4 : 1)
        }
        
        return Group {
            if let image = viewModel.image {
                ZStack {
                    imageViewer(image)
                    croppedImagesLayer
                        .scaleEffect(viewModel.animatingCollapseOfCroppedImages ? 0 : 1)
                        .padding(.top, viewModel.animatingCollapseOfCroppedImages ? 0 : 0)
                        .padding(.trailing, viewModel.animatingCollapseOfCroppedImages ? 300 : 0)
                }
//            } else {
//                Color.black
            }
        }
//        .edgesIgnoringSafeArea(.all)
        .transition(.opacity)
    }
}
