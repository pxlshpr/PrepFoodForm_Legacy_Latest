import SwiftUI

extension LabelScanner {
        
    @ViewBuilder
    var cameraLayer: some View {
        if isCamera {
            foodLabelCamera
                .opacity(hideCamera ? 0 : 1)
        }
    }
    
    var foodLabelCamera: some View {
        LabelCamera(mockData: mock, imageHandler: handleCapturedImage)
    }
    
}
