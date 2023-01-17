import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer

//TODO: Make these dynamic
//let HarcodedBounds = CGRectMake(0, 0, 430, 566)
let HeightWithKeyboard: CGFloat = 566
let HeightWithoutKeyboard: CGFloat = 932 - 47 - 23 - 12
var HardcodedBounds = CGRectMake(0, 0, 430, HeightWithoutKeyboard)
var HardcodedBoundsForCentering = CGRectMake(0, 0, 430, HeightWithoutKeyboard)

let TopInset: CGFloat = 0
//let TopInset: CGFloat = -59.0
/// Use this for full screen height
//let BottomSafeAreaHeight: CGFloat = 34.0
let BottomInset: CGFloat = 57.0


let BottomInsetInitial: CGFloat = 62
let BottomInsetWithKeyboard: CGFloat = 57

extension Scanner {
    
    @ViewBuilder
    var imageViewerLayer: some View {
        if let image = viewModel.image {
            VStack(spacing: 0) {
                ZStack {
                    imageViewer(image)
                    croppedImagesLayer
                        .scaleEffect(viewModel.animatingCollapseOfCroppedImages ? 0 : 1)
                        .padding(.top, viewModel.animatingCollapseOfCroppedImages ? 0 : 0)
                        .padding(.trailing, viewModel.animatingCollapseOfCroppedImages ? 300 : 0)
                }
//                .frame(height: imageViewerHeight)
//                .overlay(.green.opacity(0.5))
//                if viewModel.showingTextField {
                    Spacer()
//                }
            }
            .transition(.opacity)
        }
    }
    
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
//        .edgesIgnoringSafeArea(.all)
//        .padding(.bottom, 0)
//            .frame(height: 473)
//            .padding(.bottom, 366)
//            .background(.green)
        .scaleEffect(viewModel.animatingCollapse ? 0 : 1)
        .opacity(viewModel.shimmeringImage ? 0.4 : 1)
    }
    
    @ViewBuilder
    var croppedImagesLayer: some View {
        if viewModel.showingCroppedImages {
            ZStack {
                Color.clear
//                Color.blue.opacity(0.3)
                ForEach(viewModel.images.indices, id: \.self) { i in
                    croppedImage(
                        viewModel.images[i].0,
                        rect: viewModel.images[i].1,
                        stackedAngle: viewModel.images[i].3,
                        wiggleAngles: viewModel.images[i].4
                    )
                }
            }
            .edgesIgnoringSafeArea(.all)
            .transition(.opacity)
        }
    }
    
}
