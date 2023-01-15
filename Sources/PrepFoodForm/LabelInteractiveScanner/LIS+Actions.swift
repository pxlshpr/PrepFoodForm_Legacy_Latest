import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer

extension LabelInteractiveScanner {

    func handleCapturedImage(_ image: UIImage) {
        withAnimation(.easeInOut(duration: 0.7)) {
            viewModel.image = image
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
