import SwiftUI
import ZoomableScrollView

extension TextPickerViewModel {
    
    func setInitialState() {
        withAnimation {
            self.hasAppeared = true
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for i in self.imageViewModels.indices {
                self.setDefaultZoomBox(forImageAt: i)
                self.setZoomFocusBox(forImageAt: i)
            }
//        }
    }
    
    func setDefaultZoomBox(forImageAt index: Int) {
        guard let imageSize = imageSize(at: index) else {
            return
        }
        
        let initialZoomBox = ZoomBox(
            boundingBox: boundingBox(forImageAt: index),
            animated: true,
            padded: true,
            imageSize: imageSize,
            imageId: imageViewModels[index].id
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self else { return }
            let userInfo = [Notification.ZoomableScrollViewKeys.zoomBox: initialZoomBox]
            NotificationCenter.default.post(name: .zoomZoomableScrollView, object: nil, userInfo: userInfo)
        }
    }

    func setZoomFocusBox(forImageAt index: Int) {
        guard let imageSize = imageSize(at: index), zoomBoxes[index] == nil else {
            return
        }
        
        let zoomFocusedBox = ZoomBox(
            boundingBox: boundingBox(forImageAt: index),
            animated: true,
            padded: true,
            imageSize: imageSize,
            imageId: imageViewModels[index].id
        )
        zoomBoxes[index] = zoomFocusedBox
    }
}
