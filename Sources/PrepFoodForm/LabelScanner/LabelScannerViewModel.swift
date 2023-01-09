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
    var lastContentOffset: CGPoint? = nil
    var lastContentSize: CGSize? = nil
    var waitingForZoomToEndToShowCroppedImages = false
    var croppedImages: [RecognizedText : UIImage] = [:]
    var croppingStatus: CroppingStatus = .idle
    var waitingToShowCroppedImages = false

    enum CroppingStatus {
        case idle
        case started
        case complete
    }
    
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(zoomableScrollViewDidEndZooming),
            name: .zoomableScrollViewDidEndZooming,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(zoomableScrollViewDidEndZooming),
            name: .zoomableScrollViewDidEndScrollingAnimation,
            object: nil
        )
    }
    
    @objc func zoomableScrollViewDidEndZooming(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let contentOffset = userInfo[Notification.ZoomableScrollViewKeys.contentOffset] as? CGPoint,
              let contentSize = userInfo[Notification.ZoomableScrollViewKeys.contentSize] as? CGSize
        else { return }
        
        lastContentOffset = contentOffset
        lastContentSize = contentSize
        print("LabelScannerViewModel: 🚠 scrollViewDidEndZooming — offset: \(contentOffset) size: \(contentSize)")
        
        if waitingForZoomToEndToShowCroppedImages {
            waitingForZoomToEndToShowCroppedImages = false
            
            Task.detached { [weak self] in
                guard let self else { return }
                switch await self.croppingStatus {
                case .complete:
                    print("✂️ didEndZooming with CroppingStatus.complete — Now show cropped images")
                    await self.showCroppedImages()
                case .started:
                    print("✂️ didEndZooming with CroppingStatus.started — Wait till cropping is done")
                    await MainActor.run { [weak self] in
                        self?.waitingToShowCroppedImages = true
                    }
                case .idle:
                    print("✂️ didEndZooming with CroppingStatus.idle — shouldn't ever get here")
                }
//                try await self?.cropImages()
            }
        }
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
        lastContentOffset = nil
        lastContentSize = nil
        waitingForZoomToEndToShowCroppedImages = false
        croppedImages = [:]
        croppingStatus = .idle
        waitingToShowCroppedImages = false
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
            
            await self.startCroppingImages()

            if scanResult.columnCount == 2 {
                try await self.showColumnPicker()
            } else {
                /// If we're not showing the column picker—zoom into the texts we'll be extracting, and wait for long enough to get the new `contentOffset` and `contentSize`
                if await self.shouldZoomToTextsToCrop == true {
                    await self.zoomToTextsToCrop()
                    await MainActor.run { [weak self] in
                        self?.waitingForZoomToEndToShowCroppedImages = true
                    }
//                } else {
//                    try await self.cropImages()
                } else {
                    await MainActor.run { [weak self] in
                        self?.waitingToShowCroppedImages = true
                    }
                }
            }
        }
    }
    
    func startCroppingImages() {
        guard let image else { return }

        Task.detached { [weak self] in
            guard let self else { return }
            
            await MainActor.run { [weak self] in
                self?.croppingStatus = .started
            }
            print("✂️ Starting cropping")
            
            var croppedImages: [RecognizedText : UIImage] = [:]
            for text in await self.allTexts {
                guard let croppedImage = await image.cropped(boundingBox: text.boundingBox) else {
                    print("Couldn't get image for box: \(text)")
                    continue
                }
                print("✂️ Cropped: \(text.string)")
                croppedImages[text] = croppedImage
            }

            await MainActor.run { [weak self, croppedImages] in
                print("✂️ Cropping completed, setting dict and status")
                self?.croppedImages = croppedImages
                self?.croppingStatus = .complete
            }
            
            if await self.waitingToShowCroppedImages {
                print("✂️ Was waitingToShowCroppedImages, so showing now")
                await self.showCroppedImages()
            }
        }
    }
    
    func showCroppedImages() {
        print("✂️ Showing cropped images")
        Task.detached { [weak self] in
            
            guard let self else { return }
            
            for (text, cropped) in await self.croppedImages {
                guard await self.textsToCrop.contains(where: { $0.id == text.id }) else {
                    print("✂️ Not including: \(text.string) since it's not in textsToCrop")
                    continue
                }
                
                print("✂️ Getting rect for: \(text.string)")
                let correctedRect = await self.rectForText(text)
                
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
                    self.scannedTextBoxes = self.getScannedTextBoxes
                }
            }
            
            try await sleepTask(0.1, tolerance: 0.01)

            await self.stackCroppedImagesOnTop()
        }
    }
    
    func stackCroppedImagesOnTop() {
        Task.detached { [weak self] in
            
            guard let self else { return }
            
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
    
//    func cropImages() async throws {
//        guard let image else { return }
//
//        Task.detached { [weak self] in
//
//            guard let self else { return }
//
//            for text in await self.textsToCrop {
//                guard let cropped = await image.cropped(boundingBox: text.boundingBox) else {
//                    print("Couldn't get image for box: \(text)")
//                    continue
//                }
//
//                print("📐 Getting rect for: \(text.string)")
//                let correctedRect = await self.rectForText(text)
//
//                await MainActor.run { [weak self] in
//                    guard let self else { return }
//                    let randomWiggleAngles = self.randomWiggleAngles
//
//                    if !self.images.contains(where: { $0.2 == text.id }) {
//                        self.images.append((
//                            cropped,
//                            correctedRect,
//                            text.id,
//                            Angle.degrees(CGFloat.random(in: -20...20)),
//                            randomWiggleAngles
//                        ))
//                    }
//                }
//            }
//
//            Haptics.selectionFeedback()
//
//            await MainActor.run { [weak self] in
//                guard let self else { return }
//                withAnimation {
//                    self.textBoxes = []
//                    self.showingCroppedImages = true
////                    self.scannedTextBoxes = scanResult.textBoxes
//                    self.scannedTextBoxes = self.getScannedTextBoxes
//                }
//            }
//
//            try await sleepTask(0.1, tolerance: 0.01)
//
//            await MainActor.run { [weak self] in
//                guard let self else { return }
//                withAnimation {
//                    self.showingCutouts = true
//                    self.animatingLiftingUpOfCroppedImages = true
//                }
//            }
//
//            let Bounce: Animation = .interactiveSpring(response: 0.35, dampingFraction: 0.66, blendDuration: 0.35)
//
//            try await sleepTask(Double.random(in: 0.05...0.15), tolerance: 0.01)
//
//            await MainActor.run { [weak self] in
//                guard let self else { return }
//                Haptics.selectionFeedback()
//                withAnimation(Bounce) {
//                    self.animatingFirstWiggleOfCroppedImages = true
//                }
//            }
//
//            try await sleepTask(Double.random(in: 0.05...0.15), tolerance: 0.01)
//
//            await MainActor.run { [weak self] in
//                guard let self else { return }
//                Haptics.selectionFeedback()
//                withAnimation(Bounce) {
//                    self.animatingFirstWiggleOfCroppedImages = false
//                    self.animatingSecondWiggleOfCroppedImages = true
//                }
//            }
//
//            try await sleepTask(Double.random(in: 0.05...0.15), tolerance: 0.01)
//
//            await MainActor.run { [weak self] in
//                guard let self else { return }
//                Haptics.selectionFeedback()
//                withAnimation(Bounce) {
//                    self.animatingSecondWiggleOfCroppedImages = false
//                    self.animatingThirdWiggleOfCroppedImages = true
//                }
//            }
//
//            try await sleepTask(Double.random(in: 0.05...0.15), tolerance: 0.01)
//
//            await MainActor.run { [weak self] in
//                guard let self else { return }
//                Haptics.selectionFeedback()
//                withAnimation(Bounce) {
//                    self.animatingThirdWiggleOfCroppedImages = false
//                    self.animatingFourthWiggleOfCroppedImages = true
//                }
//            }
//
//            try await sleepTask(Double.random(in: 0.3...0.5), tolerance: 0.01)
//
//            await MainActor.run { [weak self] in
//                guard let self else { return }
//                Haptics.feedback(style: .soft)
//                withAnimation(Bounce) {
//                    self.animatingFourthWiggleOfCroppedImages = false
//                    self.stackedOnTop = true
//                }
//            }
//
//            try await sleepTask(0.8, tolerance: 0.01)
//
//            try await self.collapse()
//        }
//    }

    var shouldZoomToTextsToCrop: Bool {
        guard !showingColumnPicker else { return false }
        let boundingBox = textsToCrop.boundingBox
        return boundingBox.height < 0.6
    }
    
    var allTexts: [RecognizedText] {
        scanResult?.allTexts ?? []
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
            switch columns.selectedColumnIndex {
            case 2:
                if let text = scanResult.headers?.headerText2?.text  {
                    texts.append(text)
                }
            default:
                if let text = scanResult.headers?.headerText1?.text {
                    texts.append(text)
                }
            }
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

    func getRectForText(_ text: RecognizedText, contentSize: CGSize, contentOffset: CGPoint) -> CGRect {
        /// Get the bounding box in terms of the (scaled) image dimensions
        let rect = text.boundingBox.rectForSize(contentSize)

        print("    📐 Getting rectForSize for: \(text.string) \(rect)")

        /// Now offset it by the scrollview's current offset to get it's current position
        return CGRect(
            x: rect.origin.x - contentOffset.x,
            y: rect.origin.y - contentOffset.y,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    func rectForText(_ text: RecognizedText) -> CGRect {
        
        if let lastContentSize, let lastContentOffset {
            print("    📐 Have contentSize and contentOffset, so calculating")
            return getRectForText(text, contentSize: lastContentSize, contentOffset: lastContentOffset)
        }
        print("    📐 DON'T Have contentSize and contentOffset, doing it manually")

        //TODO: Try and always have lastContentSize and lastContentOffset and calculate using those
        let boundingBox = text.boundingBox
        guard let image else { return .zero }
        
        let screen = UIScreen.main.bounds
        
        let correctedRect: CGRect
        if self.isCamera {
            let scaledWidth: CGFloat = (image.size.width * screen.height) / image.size.height
            let scaledSize = CGSize(width: scaledWidth, height: screen.height)
            let rectForSize = boundingBox.rectForSize(scaledSize)
            
            correctedRect = CGRect(
                x: rectForSize.origin.x - ((scaledWidth - screen.width) / 2.0),
                y: rectForSize.origin.y,
                width: rectForSize.size.width,
                height: rectForSize.size.height
            )
            
            print("🌱 box.boundingBox: \(boundingBox)")
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
                rectForSize = boundingBox.rectForSize(scaledSize)
                x = rectForSize.origin.x
                y = rectForSize.origin.y + ((screen.height - scaledHeight) / 2.0)
                
                print("🌱 scaledSize: \(scaledSize)")
            } else {
                let scaledWidth = (image.size.width * screen.height) / image.size.height
                let scaledSize = CGSize(width: scaledWidth, height: screen.height)
                rectForSize = boundingBox.rectForSize(scaledSize)
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
        return correctedRect
    }
    
    func zoomToTextsToCrop() async {
        guard let imageSize = image?.size else { return }
        let boundingBox = self.textsToCrop.filter({ $0.id != defaultUUID }).boundingBox
        
        let columnZoomBox = ZoomBox(
            boundingBox: boundingBox,
            animated: true,
            padded: true,
            imageSize: imageSize
        )

        print("🏎 zooming to boundingBox: \(boundingBox)")
        await MainActor.run { [weak self] in
            guard let _ = self else { return }
            NotificationCenter.default.post(
                name: .zoomZoomableScrollView,
                object: nil,
                userInfo: [Notification.ZoomableScrollViewKeys.zoomBox: columnZoomBox]
            )
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
        let boundingBox: CGRect
        let imageSize: CGSize
        if isCamera {
            boundingBox = image.boundingBoxForScreenFill
            imageSize = image.size
        } else {
            boundingBox = CGRect(x: 0, y: 0, width: 1, height: 1)
            imageSize = UIScreen.main.bounds.size
        }
        
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

//                if await self.isCamera {
//                    let scaledWidth: CGFloat = (image.size.width * screen.height) / image.size.height
//                    let scaledSize = CGSize(width: scaledWidth, height: screen.height)
//                    let rectForSize = text.boundingBox.rectForSize(scaledSize)
//
//                    correctedRect = CGRect(
//                        x: rectForSize.origin.x - ((scaledWidth - screen.width) / 2.0),
//                        y: rectForSize.origin.y,
//                        width: rectForSize.size.width,
//                        height: rectForSize.size.height
//                    )
//
//                    print("🌱 box.boundingBox: \(text.boundingBox)")
//                    print("🌱 scaledSize: \(scaledSize)")
//                    print("🌱 rectForSize: \(rectForSize)")
//                    print("🌱 correctedRect: \(correctedRect)")
//                    print("🌱 image.boundingBoxForScreenFill: \(image.boundingBoxForScreenFill)")
//
//
//                } else {
//
//                    let rectForSize: CGRect
//                    let x: CGFloat
//                    let y: CGFloat
//
//                    if image.size.widthToHeightRatio > screen.size.widthToHeightRatio {
//                        /// This means we have empty strips at the top, and image gets width set to screen width
//                        let scaledHeight = (image.size.height * screen.width) / image.size.width
//                        let scaledSize = CGSize(width: screen.width, height: scaledHeight)
//                        rectForSize = text.boundingBox.rectForSize(scaledSize)
//                        x = rectForSize.origin.x
//                        y = rectForSize.origin.y + ((screen.height - scaledHeight) / 2.0)
//
//                        print("🌱 scaledSize: \(scaledSize)")
//                    } else {
//                        let scaledWidth = (image.size.width * screen.height) / image.size.height
//                        let scaledSize = CGSize(width: scaledWidth, height: screen.height)
//                        rectForSize = text.boundingBox.rectForSize(scaledSize)
//                        x = rectForSize.origin.x + ((screen.width - scaledWidth) / 2.0)
//                        y = rectForSize.origin.y
//                    }
//
//                    correctedRect = CGRect(
//                        x: x,
//                        y: y,
//                        width: rectForSize.size.width,
//                        height: rectForSize.size.height
//                    )
//
//                    print("🌱 rectForSize: \(rectForSize)")
//                    print("🌱 correctedRect: \(correctedRect), screenHeight: \(screen.height)")
//
//                }
                
