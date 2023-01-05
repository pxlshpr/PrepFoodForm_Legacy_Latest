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
        if showingCroppedImages {
            ZStack {
                Color.clear
//                Color.blue.opacity(0.3)
                ForEach(images.indices, id: \.self) { i in
                    croppedImage(images[i].0, rect: images[i].1, randomAngle: images[i].3)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .transition(.opacity)
        }
    }
    
    func croppedImage(_ image: UIImage, rect: CGRect, randomAngle: Angle) -> some View {
        var x: CGFloat {
            stackedOnTop ? UIScreen.main.bounds.midX : rect.midX
        }
        
        var y: CGFloat {
            stackedOnTop ? 150 : rect.midY
        }
        
        var angle: Angle {
            stackedOnTop ? randomAngle : .degrees(0)
        }

        var scale: CGFloat {
            stackedOnTop ? 2.0 : 1.0
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
