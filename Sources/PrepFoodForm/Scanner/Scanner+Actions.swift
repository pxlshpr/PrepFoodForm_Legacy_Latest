import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer

extension Scanner {

    func handleCapturedImage(_ image: UIImage) {
        withAnimation(.easeInOut(duration: 0.7)) {
            viewModel.image = image
            print("👀 image has been set: \(image.size)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .scannerDidSetImage, object: nil, userInfo: [
                    Notification.ZoomableScrollViewKeys.imageSize: image.size
                ])
            }
        }
//
        
//        withAnimation(.easeInOut(duration: 0.4).repeatForever()) {
//            viewModel.shimmeringImage = true
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.begin(image)
        }
    }
}
