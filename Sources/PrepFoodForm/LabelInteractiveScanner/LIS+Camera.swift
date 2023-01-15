import SwiftUI

extension LabelInteractiveScanner {
        
    @ViewBuilder
    var cameraLayer: some View {
        if viewModel.isCamera {
            foodLabelCamera
                .opacity(viewModel.hideCamera ? 0 : 1)
        }
    }
    
    var foodLabelCamera: some View {
        LabelCamera(imageHandler: handleCapturedImage)
    }
    
}
