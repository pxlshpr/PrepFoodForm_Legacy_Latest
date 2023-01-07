import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer

extension LabelScanner {

    func handleCapturedImage(_ image: UIImage) {
//        withAnimation(.easeInOut(duration: 0.7)) {
            viewModel.image = image
//        }
//        
//        withAnimation(.easeInOut(duration: 0.4).repeatForever()) {
//            viewModel.shimmeringImage = true
//        }
        
        viewModel.begin(image)
    }
    
//    func getZoomBox(for image: UIImage) -> ZoomBox {
//        let boundingBox = isCamera
//        ? image.boundingBoxForScreenFill
//        : CGRect(x: 0, y: 0, width: 1, height: 1)
//
//        //TODO: Why isn't this screen bounds for camera as well?
//        let imageSize = isCamera ? image.size : UIScreen.main.bounds.size
//
//        /// Having `padded` as true for picked images is crucial to make sure we don't get the bug
//        /// where the initial zoom causes the image to scroll way off screen (and hence disappear)
//        let padded = !isCamera
//
//        return ZoomBox(
//            boundingBox: boundingBox,
//            animated: false,
//            padded: padded,
//            imageSize: imageSize
//        )
//    }
//
//    func startScan(_ image: UIImage) async throws {
//
//        let zoomBox = getZoomBox(for: image)
//
//        Haptics.selectionFeedback()
//
//        try await sleepTask(0.03, tolerance: 0.005)
////        try await sleepTask(1.0, tolerance: 0.005)
//
//        /// Zoom to ensure that the `ImageViewer` matches the camera preview layer
//        let userInfo = [Notification.ZoomableScrollViewKeys.zoomBox: zoomBox]
//        await MainActor.run {
//            NotificationCenter.default.post(name: .zoomZoomableScrollView, object: nil, userInfo: userInfo)
//        }
//
//        if isCamera {
//            await MainActor.run {
//                withAnimation {
//                    hideCamera = true
//                }
//            }
//        } else {
//            /// Ensure the sliding up animation is complete first
//            try await sleepTask(0.2, tolerance: 0.005)
//        }
//
//        /// Now capture recognized texts
//        /// - captures all the RecognizedTexts
//        let textSet = try await image.recognizedTextSet(for: .accurate, includeBarcodes: true)
//        let textBoxes = textSet.texts.map {
//            TextBox(
//                id: $0.id,
//                boundingBox: $0.boundingBox,
//                color: .accentColor,
//                opacity: 0.8,
//                tapHandler: {}
//            )
//        }
//
//        Haptics.selectionFeedback()
//
//        /// **VisionKit Scan Completed**: Show all `RecognizedText`'s
//        shimmeringStart = CFAbsoluteTimeGetCurrent()
//        self.textBoxes = textBoxes
//        shimmering = true
//        await MainActor.run {
//            withAnimation {
////                shimmeringImage = false
//                showingBoxes = true
//                print("🟢 DONE")
////                    isLoadingImageViewer = false
//            }
//        }
//        try await sleepTask(1, tolerance: 0.005)
//
//        Task(priority: .low) {
//            try await scan(textSet: textSet)
//        }
//    }
//
//    func scan(textSet: RecognizedTextSet) async throws {
//
//        let scanResult = textSet.scanResult
//        self.scanResult = scanResult
//
//        guard scanResult.columnCount != 2 else {
//            try await showColumnPicker()
//            return
//        }
//
//        await MainActor.run {
//            showingBlackBackground = false
//        }
//
//        /// Make sure the shimmering effect goes on for at least 2 seconds so user gets a feel of the image being processed
//        let minimumShimmeringTime: Double = 1
//        let timeSinceShimmeringStart = CFAbsoluteTimeGetCurrent()-shimmeringStart
//        if timeSinceShimmeringStart < minimumShimmeringTime {
//            try await sleepTask(minimumShimmeringTime - timeSinceShimmeringStart, tolerance: 0.005)
//        }
//
//        try await cropImages()
//    }
//
//    func cropImages() async throws {
//        guard let scanResult, let image else { return }
//
//        let resultBoxes = scanResult.textBoxes
//        for box in resultBoxes {
//            guard let cropped = await image.cropped(boundingBox: box.boundingBox) else {
//                print("Couldn't get image for box: \(box)")
//                continue
//            }
//
//            let screen = await UIScreen.main.bounds
//
//            let correctedRect: CGRect
//            if isCamera {
//                let scaledWidth: CGFloat = (image.size.width * screen.height) / image.size.height
//                let scaledSize = CGSize(width: scaledWidth, height: screen.height)
//                let rectForSize = box.boundingBox.rectForSize(scaledSize)
//
//                correctedRect = CGRect(
//                    x: rectForSize.origin.x - ((scaledWidth - screen.width) / 2.0),
//                    y: rectForSize.origin.y,
//                    width: rectForSize.size.width,
//                    height: rectForSize.size.height
//                )
//
//                print("🌱 box.boundingBox: \(box.boundingBox)")
//                print("🌱 scaledSize: \(scaledSize)")
//                print("🌱 rectForSize: \(rectForSize)")
//                print("🌱 correctedRect: \(correctedRect)")
//                print("🌱 image.boundingBoxForScreenFill: \(image.boundingBoxForScreenFill)")
//
//
//            } else {
//
//                let rectForSize: CGRect
//                let x: CGFloat
//                let y: CGFloat
//
//                if image.size.widthToHeightRatio > screen.size.widthToHeightRatio {
//                    /// This means we have empty strips at the top, and image gets width set to screen width
//                    let scaledHeight = (image.size.height * screen.width) / image.size.width
//                    let scaledSize = CGSize(width: screen.width, height: scaledHeight)
//                    rectForSize = box.boundingBox.rectForSize(scaledSize)
//                    x = rectForSize.origin.x
//                    y = rectForSize.origin.y + ((screen.height - scaledHeight) / 2.0)
//
//                    print("🌱 scaledSize: \(scaledSize)")
//                } else {
//                    let scaledWidth = (image.size.width * screen.height) / image.size.height
//                    let scaledSize = CGSize(width: scaledWidth, height: screen.height)
//                    rectForSize = box.boundingBox.rectForSize(scaledSize)
//                    x = rectForSize.origin.x + ((screen.width - scaledWidth) / 2.0)
//                    y = rectForSize.origin.y
//                }
//
//                correctedRect = CGRect(
//                    x: x,
//                    y: y,
//                    width: rectForSize.size.width,
//                    height: rectForSize.size.height
//                )
//
//                print("🌱 rectForSize: \(rectForSize)")
//                print("🌱 correctedRect: \(correctedRect), screenHeight: \(screen.height)")
//
//            }
//
//            if !self.images.contains(where: { $0.2 == box.id }) {
//                self.images.append((
//                    cropped,
//                    correctedRect,
//                    box.id,
//                    Angle.degrees(CGFloat.random(in: -20...20)))
//                )
//            }
//        }
//
//        Haptics.selectionFeedback()
//
//        await MainActor.run {
//            withAnimation {
//                showingCroppedImages = true
//                self.textBoxes = []
//                self.scannedTextBoxes = scanResult.textBoxes
//            }
//        }
//
//        try await sleepTask(0.5, tolerance: 0.01)
//
//        let Bounce: Animation = .interactiveSpring(response: 0.35, dampingFraction: 0.66, blendDuration: 0.35)
//
//        await MainActor.run {
//            Haptics.feedback(style: .soft)
//            withAnimation(Bounce) {
//                stackedOnTop = true
//            }
//        }
//
//        try await sleepTask(0.5, tolerance: 0.01)
//
//        try await collapse()
//    }
//
//    @MainActor
//    func transitionToImageViewer(with zoomBox: ZoomBox) async throws {
//
//        /// This delay is necessary to ensure that the zoom actually occurs and give the seamless transition from
//        /// that the capture layer of `LabelCamera` to the `ImageViewer`
////        try await sleepTask(0.03, tolerance: 0.005)
//        try await sleepTask(2.0, tolerance: 0.005)
//
////        await MainActor.run {
//            /// Zoom to ensure that the `ImageViewer` matches the camera preview layer
//            let userInfo = [Notification.ZoomableScrollViewKeys.zoomBox: zoomBox]
//            NotificationCenter.default.post(name: .zoomZoomableScrollView, object: nil, userInfo: userInfo)
//
////            withAnimation {
////                hideCamera = true
////            }
////        }
//
//    }
//
//    @MainActor
//    func collapse() async throws {
////        await MainActor.run {
//            withAnimation {
//                self.animatingCollapse = true
//                self.animatingCollapseOfCutouts = true
//                imageHandler(image!, scanResult!)
//            }
////        }
//
//        try await sleepTask(0.5, tolerance: 0.01)
//
////        await MainActor.run {
//            withAnimation {
//                self.animatingCollapseOfCroppedImages = true
//            }
////        }
//
//        try await sleepTask(0.2, tolerance: 0.01)
//
////        await MainActor.run {
//            withAnimation {
//                self.selectedImage = nil
//                scanResultHandler(scanResult!)
//            }
////        }
//    }
//
//    func zoomToColumns() async {
//        guard let imageSize = image?.size else { return }
//        let zoomRect = columns.boundingBox
//        let columnZoomBox = ZoomBox(
//            boundingBox: zoomRect,
//            animated: true,
//            padded: true,
//            imageSize: imageSize
//        )
//
//        await MainActor.run {
//            NotificationCenter.default.post(
//                name: .zoomZoomableScrollView,
//                object: nil,
//                userInfo: [Notification.ZoomableScrollViewKeys.zoomBox: columnZoomBox]
//            )
//        }
//    }
//
//    func showColumnPicker() async throws {
//        guard let scanResult else { return }
//
//        self.shimmering = false
//        withAnimation {
//            showingColumnPicker = true
//        }
//
//        let columns = scanResult.scannedColumns
//        self.columns.column1 = columns.column1
//        self.columns.column2 = columns.column2
//        self.columns.selectedColumnIndex = columns.selectedColumnIndex
//        self.selectedImageTexts = columns.selectedImageTexts
//
//        await zoomToColumns()
//        showColumnTextBoxes()
//        await showColumnPickingUI()
//    }
//
//    /// [ ] Show column boxes (animate changes, have default column preselected)
//    func showColumnTextBoxes() {
//        self.textBoxes = columns.texts.map {
//            TextBox(
//                boundingBox: $0.boundingBox,
//                color: color(for: $0),
//                tapHandler: tapHandler(for: $0)
//            )
//        }
//    }
//
//    func tapHandler(for text: RecognizedText) -> (() -> ())? {
//        guard !columns.selectedColumn.contains(text) else {
//            return nil
//        }
//        return {
//            withAnimation {
//                self.columns.toggleSelectedColumnIndex()
//                self.selectedImageTexts = columns.selectedImageTexts
//            }
//            showColumnTextBoxes()
//        }
//    }
//
//    func color(for text: RecognizedText) -> Color {
//        if selectedImageTexts.contains(where: { $0.text == text }) {
//            return Color.accentColor
//        } else {
//            return Color(.systemBackground).opacity(1.0)
//        }
//    }
//
//    /// [ ] Show column picking UI
//    func showColumnPickingUI() async {
//    }
}
