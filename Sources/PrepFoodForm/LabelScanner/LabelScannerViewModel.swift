import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer
import VisionSugar

@MainActor
public class LabelScannerViewModel: ObservableObject {

    var isCamera: Bool
    var imageHandler: ((UIImage, ScanResult) -> ())?
    var scanResultHandler: ((ScanResult, Int?) -> ())?
    var dismissHandler: (() -> ())?

    @Published var hideCamera = false
    @Published var textBoxes: [TextBox] = []
    @Published var scanResult: ScanResult? = nil
    @Published var image: UIImage? = nil
    @Published var images: [(UIImage, CGRect, UUID, Angle, (Angle, Angle, Angle, Angle))] = []
    @Published var stackedOnTop: Bool = false
    @Published var scannedTextBoxes: [TextBox] = []
    @Published var animatingCollapse: Bool = false
    @Published var animatingCollapseOfCutouts = false
    @Published var animatingCollapseOfCroppedImages = false
    @Published var animatingLiftingUpOfCroppedImages = false
    
    @Published var animatingFirstWiggleOfCroppedImages = false
    @Published var animatingSecondWiggleOfCroppedImages = false
    @Published var animatingThirdWiggleOfCroppedImages = false
    @Published var animatingFourthWiggleOfCroppedImages = false

    @Published var columns: ScannedColumns = ScannedColumns()
    @Published var selectedImageTexts: [ImageText] = []
    @Published var zoomBox: ZoomBox? = nil
    @Published var shimmering = false
    @Published var shimmeringImage = false
    @Published var showingColumnPicker = false
    @Published var showingColumnPickerUI = false
    @Published var showingCroppedImages = false
    @Published var showingBlackBackground = true
    @Published var showingBoxes = false
    @Published var showingCutouts = false
    @Published var clearSelectedImage: Bool = false
    
    let id = UUID()
    
    public init(
        isCamera: Bool,
        imageHandler: @escaping (UIImage, ScanResult) -> (),
        scanResultHandler: @escaping (ScanResult, Int?) -> (),
        dismissHandler: @escaping () -> ()
    ) {
        self.isCamera = isCamera
        self.imageHandler = imageHandler
        self.scanResultHandler = scanResultHandler
        self.dismissHandler = dismissHandler
        
        self.hideCamera = !isCamera
//        self.showingBlackBackground = !isCamera
    }
    
    public convenience init() {
        self.init(
            isCamera: false,
            imageHandler: { _, _ in },
            scanResultHandler:  { _, _ in },
            dismissHandler: { }
        )
    }
    
    func reset() {
        hideCamera = false
        animatingCollapse = false
        animatingCollapseOfCutouts = false
        animatingCollapseOfCroppedImages = false
        animatingLiftingUpOfCroppedImages = false
        
        shimmering = false
        shimmeringImage = false
        showingColumnPicker = false
        showingColumnPickerUI = false
        showingCroppedImages = false
        showingBlackBackground = true
        showingBoxes = false
        showingCutouts = false
        textBoxes = []
        scanResult = nil
        image = nil
        images = []
        stackedOnTop = false
        scannedTextBoxes = []
        columns = ScannedColumns()
        selectedImageTexts = []
        zoomBox = nil
        clearSelectedImage = false
    }
    
    func begin(_ image: UIImage) {
        self.startScan(image)
    }

    func begin_test(_ image: UIImage) {
        Task.detached { [weak self] in
            guard let self else { return }
            try await sleepTask(1.0, tolerance: 0.1)
            await self.dismissHandler?()
//            try await self.collapse()
            
//            let textSet = try await image.recognizedTextSet(for: .accurate, includeBarcodes: true)
//            let scanResult = textSet.scanResult
            
        }
    }

    func zoomOutCompletely(_ image: UIImage, animated: Bool = false) {
        let zoomBox = self.getZoomBox(for: image, animated: animated)
        let userInfo = [Notification.ZoomableScrollViewKeys.zoomBox: zoomBox]
        NotificationCenter.default.post(name: .zoomZoomableScrollView, object: nil, userInfo: userInfo)
    }
    
    func startScan(_ image: UIImage) {

        Task.detached { [weak self] in
            
            guard let self else { return }
            
            Haptics.selectionFeedback()
            
//            try await sleepTask(0.03, tolerance: 0.005)
//            try await sleepTask(0.75, tolerance: 0.005)
//            try await sleepTask(1.0, tolerance: 0.005)
            
            await MainActor.run { [weak self] in
                self?.zoomOutCompletely(image)
            }
            
            if await self.isCamera {
                await MainActor.run { [weak self] in
                    withAnimation {
                        self?.hideCamera = true
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

            /// **VisionKit Scan Completed**: Show all `RecognizedText`'s
            await MainActor.run {  [weak self] in
                guard let self else { return }
                withAnimation {
                    self.shimmeringImage = false
                    self.textBoxes = textBoxes
                    self.showingBoxes = true
                }
            }

            try await sleepTask(0.2, tolerance: 0.005)
            await MainActor.run { [weak self] in
                self?.shimmering = true
            }

            try await sleepTask(1, tolerance: 0.005)
            
            try await self.scan(textSet: textSet)
        }
    }
    
    func scan(textSet: RecognizedTextSet) async throws {
        
        Task.detached { [weak self] in
            guard let self else { return }
            let scanResult = textSet.scanResult

            await MainActor.run { [weak self] in
                guard let self else { return }
                self.scanResult = scanResult
                self.showingBlackBackground = false
            }
            
            if scanResult.columnCount == 2 {
                try await self.showColumnPicker()
            } else {
                try await self.cropImages()
            }
        }
    }
    
    var textsToCrop: [RecognizedText] {
        guard let scanResult else { return [] }
        if showingColumnPicker {
            var texts: [RecognizedText] = []
            for selectedImageText in selectedImageTexts {
                texts.append(selectedImageText.text)
                if let attributeText = selectedImageText.attributeText {
                    texts.append(attributeText)
                }
            }
            texts.append(contentsOf: scanResult.servingTexts)
            return texts
        } else {
            return scanResult.allTexts
        }
    }
    
    var getScannedTextBoxes: [TextBox] {
        textsToCrop.map {
            TextBox(
                id: $0.id,
                boundingBox: $0.boundingBox,
                color: .accentColor,
                opacity: 0.8,
                tapHandler: {}
            )
        }
    }
    
    func cropImages() async throws {
        guard let image else { return }
        
        Task.detached { [weak self] in

            guard let self else { return }
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                if self.showingColumnPicker {
                    self.zoomOutCompletely(image, animated: true)
                }
            }
            
//            let resultBoxes = scanResult.textBoxes
            
            for text in await self.textsToCrop {
                guard let cropped = await image.cropped(boundingBox: text.boundingBox) else {
                    print("Couldn't get image for box: \(text)")
                    continue
                }
                
                let screen = await UIScreen.main.bounds
                
                let correctedRect: CGRect
                if await self.isCamera {
                    let scaledWidth: CGFloat = (image.size.width * screen.height) / image.size.height
                    let scaledSize = CGSize(width: scaledWidth, height: screen.height)
                    let rectForSize = text.boundingBox.rectForSize(scaledSize)
                    
                    correctedRect = CGRect(
                        x: rectForSize.origin.x - ((scaledWidth - screen.width) / 2.0),
                        y: rectForSize.origin.y,
                        width: rectForSize.size.width,
                        height: rectForSize.size.height
                    )
                    
                    print("🌱 box.boundingBox: \(text.boundingBox)")
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
                        rectForSize = text.boundingBox.rectForSize(scaledSize)
                        x = rectForSize.origin.x
                        y = rectForSize.origin.y + ((screen.height - scaledHeight) / 2.0)
                        
                        print("🌱 scaledSize: \(scaledSize)")
                    } else {
                        let scaledWidth = (image.size.width * screen.height) / image.size.height
                        let scaledSize = CGSize(width: scaledWidth, height: screen.height)
                        rectForSize = text.boundingBox.rectForSize(scaledSize)
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
                
                await MainActor.run { [weak self] in
                    
                    guard let self else { return }
                    
                    let randomWiggleAngles = self.randomWiggleAngles
                    if !self.images.contains(where: { $0.2 == text.id }) {
                        self.images.append((
                            cropped,
                            correctedRect,
                            text.id,
                            Angle.degrees(CGFloat.random(in: -20...20)),
                            randomWiggleAngles
                        ))
                    }
                }
            }
            
            Haptics.selectionFeedback()
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                withAnimation {
                    self.textBoxes = []
                    self.showingCroppedImages = true
//                    self.scannedTextBoxes = scanResult.textBoxes
                    self.scannedTextBoxes = self.getScannedTextBoxes
                }
            }

            try await sleepTask(0.1, tolerance: 0.01)

            await MainActor.run { [weak self] in
                guard let self else { return }
                withAnimation {
                    self.showingCutouts = true
                    self.animatingLiftingUpOfCroppedImages = true
                }
            }

            let Bounce: Animation = .interactiveSpring(response: 0.35, dampingFraction: 0.66, blendDuration: 0.35)

            try await sleepTask(Double.random(in: 0.05...0.15), tolerance: 0.01)

            await MainActor.run { [weak self] in
                guard let self else { return }
                Haptics.selectionFeedback()
                withAnimation(Bounce) {
                    self.animatingFirstWiggleOfCroppedImages = true
                }
            }

            try await sleepTask(Double.random(in: 0.05...0.15), tolerance: 0.01)

            await MainActor.run { [weak self] in
                guard let self else { return }
                Haptics.selectionFeedback()
                withAnimation(Bounce) {
                    self.animatingFirstWiggleOfCroppedImages = false
                    self.animatingSecondWiggleOfCroppedImages = true
                }
            }

            try await sleepTask(Double.random(in: 0.05...0.15), tolerance: 0.01)

            await MainActor.run { [weak self] in
                guard let self else { return }
                Haptics.selectionFeedback()
                withAnimation(Bounce) {
                    self.animatingSecondWiggleOfCroppedImages = false
                    self.animatingThirdWiggleOfCroppedImages = true
                }
            }

            try await sleepTask(Double.random(in: 0.05...0.15), tolerance: 0.01)

            await MainActor.run { [weak self] in
                guard let self else { return }
                Haptics.selectionFeedback()
                withAnimation(Bounce) {
                    self.animatingThirdWiggleOfCroppedImages = false
                    self.animatingFourthWiggleOfCroppedImages = true
                }
            }

            try await sleepTask(Double.random(in: 0.3...0.5), tolerance: 0.01)

            await MainActor.run { [weak self] in
                guard let self else { return }
                Haptics.feedback(style: .soft)
                withAnimation(Bounce) {
                    self.animatingFourthWiggleOfCroppedImages = false
                    self.stackedOnTop = true
                }
            }
            
            try await sleepTask(0.8, tolerance: 0.01)
            
            try await self.collapse()
        }
    }
    
    var randomWiggleAngles: (Angle, Angle, Angle, Angle) {
        let left1 = Angle.degrees(CGFloat.random(in: (-8)...(-2)))
        let right1 = Angle.degrees(CGFloat.random(in: 2...8))
        let left2 = Angle.degrees(CGFloat.random(in: (-8)...(-2)))
        let right2 = Angle.degrees(CGFloat.random(in: 2...8))
        let leftFirst = Bool.random()
        if leftFirst {
            return (left1, right1, left2, right2)
        } else {
            return (right1, left1, right2, left2)
        }
    }
    
    @MainActor
    func collapse() async throws {
        withAnimation {
            animatingCollapse = true
            animatingCollapseOfCutouts = true
            if let image, let scanResult {
                imageHandler?(image, scanResult)
                imageHandler = nil
            }
        }
        
        try await sleepTask(0.5, tolerance: 0.01)
        
        withAnimation {
            self.animatingCollapseOfCroppedImages = true
        }

        try await sleepTask(0.2, tolerance: 0.01)

        withAnimation {
            //TODO: Handle this in LabelScanner with a local variable an an onChange modifier since it's a binding
            clearSelectedImage = true
            
            if let scanResult {
                if showingColumnPicker {
                    scanResultHandler?(scanResult, columns.selectedColumnIndex)
                } else {
                    scanResultHandler?(scanResult, nil)
                }
                scanResultHandler = nil
            }
        }
    }
    
    func getZoomBox(for image: UIImage, animated: Bool) -> ZoomBox {
        /// Zoom to ensure that the `ImageViewer` matches the camera preview layer when `isCamera` is true
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
            animated: animated,
            padded: padded,
            imageSize: imageSize
        )
    }
    
}
