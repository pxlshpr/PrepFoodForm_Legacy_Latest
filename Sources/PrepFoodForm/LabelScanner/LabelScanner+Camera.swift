import SwiftUI

extension LabelScanner {
        
    @ViewBuilder
    var cameraLayer: some View {
        if viewModel.isCamera {
            foodLabelCamera
                .opacity(viewModel.hideCamera ? 0 : 1)
        }
    }
    
    var foodLabelCamera: some View {
        LabelCamera(mockData: mock, imageHandler: handleCapturedImage)
    }
    
}
