import AVKit
import SwiftUI
import FoodLabelScanner
import SwiftHaptics

public typealias ImageHandler = (UIImage) -> ()

extension LabelCamera {
    class ViewModel: ObservableObject {
        
        @Published var shouldDismiss = false
        @Published var started: Bool = false
        let imageHandler: ImageHandler
        let mockData: (ScanResult, UIImage)?
        
        init(
            mockData: (ScanResult, UIImage)? = nil,
            imageHandler: @escaping ImageHandler
        ) {
            self.imageHandler = imageHandler
            self.mockData = mockData
        }
    }
}

extension LabelCamera.ViewModel {
    
    var isMock: Bool {
        mockData != nil
    }
    
    func simulateScan() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            
            guard let self else { return }
            
            guard let mockData = self.mockData else {
                self.shouldDismiss = true
                return
            }
            Haptics.successFeedback()
            self.imageHandler(mockData.1)
        }
    }
}

extension ScanResult {
    var barcodeBoundingBoxes: [CGRect] {
        barcodes
            .map { $0.boundingBox }
            .filter { $0 != .zero }
    }
}
