import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer

extension LabelScanner {
    
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
                        randomAngle: viewModel.images[i].3)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .transition(.opacity)
        }
    }
    
    func croppedImage(_ image: UIImage, rect: CGRect, randomAngle: Angle) -> some View {
        var x: CGFloat {
            viewModel.stackedOnTop ? UIScreen.main.bounds.midX : rect.midX
        }
        
        var y: CGFloat {
            viewModel.stackedOnTop ? 150 : rect.midY
        }
        
        var angle: Angle {
            viewModel.stackedOnTop ? randomAngle : .degrees(0)
        }

        var scale: CGFloat {
            viewModel.stackedOnTop ? 2.0 : 1.0
        }
        
        var shadow: CGFloat {
            3
//            stackedOnTop ? 3 : 0
        }

        return Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: rect.width, height: rect.height)
            .rotationEffect(angle, anchor: .center)
            .scaleEffect(scale, anchor: .center)
            .position(x: x, y: y)
            .shadow(color: .black.opacity(0.3), radius: shadow, x: 0, y: shadow)
    }
}
