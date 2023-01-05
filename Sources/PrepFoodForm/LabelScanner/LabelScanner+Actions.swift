import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer

extension LabelScanner {

    func handleCapturedImage(_ image: UIImage) {
//        withAnimation(.easeInOut(duration: 0.7).repeatForever()) {
        withAnimation(.easeInOut(duration: 0.7)) {
            self.image = image
        }
//            shimmeringImage = true
//        }
        
        Haptics.successFeedback()
        print("🔵 WE here")
        
        Task(priority: .high) {
//            if !isCamera {
//                try await sleepTask(0.5)
//            }
            try await startScan(image)
        }
    }
    
    func getZoomBox(for image: UIImage) -> ZoomBox {
        let boundingBox = isCamera
        ? image.boundingBoxForScreenFill
        : CGRect(x: 0, y: 0, width: 1, height: 1)
        
        //TODO: Why isn't this screen bounds for camera as well?
        let imageSize = isCamera ? image.size : UIScreen.main.bounds.size

        /// Having `padded` as true for picked images is crucial to make sure we don't get the bug
        /// where the initial zoom causes the image to scroll way off screen (and hence disappear)
        let padded = !isCamera
        
        return ZoomBox(
            boundingBox: boundingBox,
            animated: false,
            padded: padded,
            imageSize: imageSize
        )
    }
    func startScan(_ image: UIImage) async throws {

        let zoomBox = getZoomBox(for: image)
        
        Haptics.selectionFeedback()

        try await sleepTask(0.03, tolerance: 0.005)
//        try await sleepTask(1.0, tolerance: 0.005)

        /// Zoom to ensure that the `ImageViewer` matches the camera preview layer
        let userInfo = [Notification.ZoomableScrollViewKeys.zoomBox: zoomBox]
        await MainActor.run {
            NotificationCenter.default.post(name: .zoomZoomableScrollView, object: nil, userInfo: userInfo)
        }
        
        if isCamera {
            await MainActor.run {
                withAnimation {
                    hideCamera = true
                }
            }
        } else {
            /// Ensure the sliding up animation is complete first
            try await sleepTask(0.2, tolerance: 0.005)
        }
        
        /// Now capture recognized texts
        /// - captures all the RecognizedTexts
        let textSet = try await image.recognizedTextSet(for: .accurate, includeBarcodes: true)
        let textBoxes = textSet.texts.map {
            TextBox(
                id: $0.id,
                boundingBox: $0.boundingBox,
                color: .accentColor,
                opacity: 0.8,
                tapHandler: {}
            )
        }
        
        Haptics.selectionFeedback()
        
        await MainActor.run {
            withAnimation {
                shimmeringImage = false
                self.textBoxes = textBoxes
                showingBoxes = true
//                    isLoadingImageViewer = false
            }
        }
        
//        try await sleepTask(2.0, tolerance: 0.005)

        
        /// - Sets them in a state variable
        /// - Have the loading animation stop and the texts appear
        let scanResult = textSet.scanResult

        await MainActor.run {
            self.scanResult = scanResult
            showingBlackBackground = false
        }

        let resultBoxes = scanResult.textBoxes
        
//            await MainActor.run {
//                withAnimation {
//                    self.shimmering = false
//                    self.scannedTextBoxes = resultBoxes
//                }
//            }
        

        let startCut = CFAbsoluteTimeGetCurrent()
        var croppedImages: [(UIImage, CGRect, UUID, Angle)] = []
        for box in resultBoxes {
            guard let cropped = await image.cropped(boundingBox: box.boundingBox) else {
                print("Couldn't get image for box: \(box)")
                continue
            }
            
            let screen = await UIScreen.main.bounds
            
            let correctedRect: CGRect
            if isCamera {
                let scaledWidth: CGFloat = (image.size.width * screen.height) / image.size.height
                let scaledSize = CGSize(width: scaledWidth, height: screen.height)
                let rectForSize = box.boundingBox.rectForSize(scaledSize)
                
                correctedRect = CGRect(
                    x: rectForSize.origin.x - ((scaledWidth - screen.width) / 2.0),
                    y: rectForSize.origin.y,
                    width: rectForSize.size.width,
                    height: rectForSize.size.height
                )
                
                print("🌱 box.boundingBox: \(box.boundingBox)")
                print("🌱 scaledSize: \(scaledSize)")
                print("🌱 rectForSize: \(rectForSize)")
                print("🌱 correctedRect: \(correctedRect)")
                print("🌱 image.boundingBoxForScreenFill: \(image.boundingBoxForScreenFill)")
                

            } else {
                
                let rectForSize: CGRect
                let x: CGFloat
                let y: CGFloat
                
                if image.size.widthToHeightRatio > screen.size.widthToHeightRatio {
                    /// This means we have empty strips at the top, and image gets width set to screen width
                    let scaledHeight = (image.size.height * screen.width) / image.size.width
                    let scaledSize = CGSize(width: screen.width, height: scaledHeight)
                    rectForSize = box.boundingBox.rectForSize(scaledSize)
                    x = rectForSize.origin.x
                    y = rectForSize.origin.y + ((screen.height - scaledHeight) / 2.0)
                    
                    print("🌱 scaledSize: \(scaledSize)")
                } else {
                    let scaledWidth = (image.size.width * screen.height) / image.size.height
                    let scaledSize = CGSize(width: scaledWidth, height: screen.height)
                    rectForSize = box.boundingBox.rectForSize(scaledSize)
                    x = rectForSize.origin.x + ((screen.width - scaledWidth) / 2.0)
                    y = rectForSize.origin.y
                }

                correctedRect = CGRect(
                    x: x,
                    y: y,
                    width: rectForSize.size.width,
                    height: rectForSize.size.height
                )
                
                print("🌱 rectForSize: \(rectForSize)")
                print("🌱 correctedRect: \(correctedRect), screenHeight: \(screen.height)")

            }
            
            if !self.images.contains(where: { $0.2 == box.id }) {
                self.images.append((
                    cropped,
                    correctedRect,
                    box.id,
                    Angle.degrees(CGFloat.random(in: -20...20)))
                )
            }
        }
        print("Took: \(CFAbsoluteTimeGetCurrent()-startCut)s, have \(images.count) images")

        Haptics.selectionFeedback()

//        return
        

//        await MainActor.run {
//            self.images = croppedImages
//        }
        

        await MainActor.run {
            withAnimation {
                showingCroppedImages = true
//                    scannedTextBoxes = []
                self.textBoxes = []
                self.scannedTextBoxes = scanResult.textBoxes
            }
        }
        
        try await sleepTask(0.5, tolerance: 0.01)
        
        let Bounce: Animation = .interactiveSpring(response: 0.35, dampingFraction: 0.66, blendDuration: 0.35)

        await MainActor.run {
            Haptics.feedback(style: .soft)
            withAnimation(Bounce) {
                stackedOnTop = true
            }
        }

        try await sleepTask(0.5, tolerance: 0.01)

        try await collapse()
//            return textSet.scanResult
        /// Now run texts through FoodLabelScanner
        /// - Have the texts now show a flashing occuring from left to right
        /// - Once received
    }
        

    @MainActor
    func transitionToImageViewer(with zoomBox: ZoomBox) async throws {
        
        /// This delay is necessary to ensure that the zoom actually occurs and give the seamless transition from
        /// that the capture layer of `LabelCamera` to the `ImageViewer`
//        try await sleepTask(0.03, tolerance: 0.005)
        try await sleepTask(2.0, tolerance: 0.005)

//        await MainActor.run {
            /// Zoom to ensure that the `ImageViewer` matches the camera preview layer
            let userInfo = [Notification.ZoomableScrollViewKeys.zoomBox: zoomBox]
            NotificationCenter.default.post(name: .zoomZoomableScrollView, object: nil, userInfo: userInfo)
            
//            withAnimation {
//                hideCamera = true
//            }
//        }
        
    }
    
    @MainActor
    func collapse() async throws {
//        await MainActor.run {
            withAnimation {
                self.animatingCollapse = true
                self.animatingCollapseOfCutouts = true
                imageHandler(image!, scanResult!)
            }
//        }
        
        try await sleepTask(0.5, tolerance: 0.01)
        
//        await MainActor.run {
            withAnimation {
                self.animatingCollapseOfCroppedImages = true
            }
//        }

        try await sleepTask(0.2, tolerance: 0.01)

//        await MainActor.run {
            withAnimation {
                self.selectedImage = nil
                scanResultHandler(scanResult!)
            }
//        }
    }
}
