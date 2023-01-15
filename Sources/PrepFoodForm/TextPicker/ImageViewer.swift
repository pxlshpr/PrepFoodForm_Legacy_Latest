import SwiftUI
//import ZoomableScrollView

let BottomOffsetToBePassedIn: CGFloat = 104.0

struct ImageViewer: View {
    
    let id: UUID
    let image: UIImage
    let contentMode: ContentMode
    
    @Binding var textBoxes: [TextBox]
    @Binding var scannedTextBoxes: [TextBox]
    @Binding var zoomBox: ZoomBox?
    @Binding var showingBoxes: Bool
    @Binding var showingCutouts: Bool
    @Binding var textPickerHasAppeared: Bool
    
    @Binding var shimmering: Bool
    @Binding var isFocused: Bool

    init(
        id: UUID = UUID(),
        image: UIImage,
        textBoxes: Binding<[TextBox]>? = nil,
        scannedTextBoxes: Binding<[TextBox]>? = nil,
        contentMode: ContentMode = .fit,
        zoomBox: Binding<ZoomBox?>,
        showingBoxes: Binding<Bool>? = nil,
        showingCutouts: Binding<Bool>? = nil,
        textPickerHasAppeared: Binding<Bool>? = nil,
        shimmering: Binding<Bool>? = nil,
        isFocused: Binding<Bool>? = nil
    ) {
        self.id = id
        self.image = image
        self.contentMode = contentMode

        _textBoxes = textBoxes ?? .constant([])
        _scannedTextBoxes = scannedTextBoxes ?? .constant([])
        _zoomBox = zoomBox
        _showingBoxes = showingBoxes ?? .constant(true)
        _showingCutouts = showingCutouts ?? .constant(true)
        _textPickerHasAppeared = textPickerHasAppeared ?? .constant(true)
        _shimmering = shimmering ?? .constant(false)
        _isFocused = isFocused ?? .constant(false)
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
            VStack(spacing: 0) {
                zoomableScrollView
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    
    var zoomableScrollView: some View {
        ZoomableScrollView {
            VStack(spacing: 0) {
                imageView(image)
                    .overlay(textBoxesLayer)
                    .overlay(scannedTextBoxesLayer)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .background(.black)
            .opacity((showingBoxes && isFocused) ? 0.7 : 1)
            .animation(.default, value: showingBoxes)
    }
    
    var textBoxesLayer: some View {
        var shouldShow: Bool {
            (textPickerHasAppeared && showingBoxes && scannedTextBoxes.isEmpty)
        }
        var opacity: CGFloat {
            guard shouldShow else { return 0 }
            if shimmering || isFocused { return 1 }
            return 0.3
        }
        return TextBoxesLayer(textBoxes: $textBoxes)
            .opacity(opacity)
            .animation(.default, value: textPickerHasAppeared)
            .animation(.default, value: showingBoxes)
            .animation(.default, value: shimmering)
            .animation(.default, value: scannedTextBoxes.count)
            .shimmering(active: shimmering)
    }
    
    var scannedTextBoxesLayer: some View {
        var shouldShow: Bool {
            (textPickerHasAppeared && showingBoxes && showingCutouts)
        }

        return TextBoxesLayer(textBoxes: $scannedTextBoxes, isCutOut: true)
            .opacity(shouldShow ? 1 : 0)
            .animation(.default, value: textPickerHasAppeared)
            .animation(.default, value: showingBoxes)
            .animation(.default, value: showingCutouts)
//            .shimmering(active: shimmering)
    }

}









import SwiftUI
import Combine

public struct ZoomableScrollView<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    @State var doubleTap = PassthroughSubject<Void, Never>()
    
    public var body: some View {
        ZoomableScrollViewImpl(content: content, doubleTap: doubleTap.eraseToAnyPublisher())
        /// The double tap gesture is a modifier on a SwiftUI wrapper view, rather than just putting a UIGestureRecognizer on the wrapped view,
        /// because SwiftUI and UIKit gesture recognizers don't work together correctly correctly for failure and other interactions.
            .onTapGesture(count: 2) {
                doubleTap.send()
            }
    }
}

enum RelativeAspectRatioType {
    case taller
    case wider
    case equal
}

//MARK: - CenteringScrollView

class CenteringScrollView: UIScrollView {
    
    var shouldCenterCapture: Bool = false
    var shouldCenterToFit: Bool = true
    var relativeAspectRatioType: RelativeAspectRatioType? = nil
    var isAtDefaultScale = true
    var zoomRect: CGRect = .zero
    
    var shouldPositionContent = true
    
    var animatingOffsetChange = false
    
    func positionContent(withAnimation: Bool = false, fromLayoutSubviews: Bool = false) {
        let call = "positionContent(\(withAnimation ? "withAnimation" : "")\(fromLayoutSubviews ? " fromLayoutSubviews" : ""))"
        guard !animatingOffsetChange else {
            print("🌻 cancelling \(call) since animatingOffsetChange")
            return
        }
        
        let widerThanScreen = contentSize.width > UIScreen.main.bounds.width
        let tallerThanScreen = contentSize.height > UIScreen.main.bounds.height

//        guard !isDragging else {
//        guard zoomScale <= 1.0 else {
//        if tallerThanScreen && widerThanScreen {
//            print("🌻 cancelling \(call) since isDragging")
//            return
//        }
        
        guard shouldPositionContent || withAnimation else {
            print("🌻 cancelling \(call) since !shouldPositionContent")
            return
        }
        if withAnimation {
            shouldPositionContent = true
        }
        
        guard subviews.count == 1 else {
            print("🌻 cancelling \(call) since subviews.count != 1")
            return
        }
        
        let screenSize = bounds.size
        let scaledImageSize = subviews[0].frame.size
        
        let contentOffset: CGPoint
        if scaledImageSize.isWider(than: screenSize) {

            print("🌻 \(call) image isWider: \(Double(zoomScale.rounded(toPlaces: 2)).clean), \(widerThanScreen ? "" : "!")widerThanScreen \(tallerThanScreen ? "" : "!")tallerThanScreen")

            let shouldCenterY = (
                zoomRect == .zero || scaledImageSize.height < screenSize.height
            ) && !tallerThanScreen
            
            let y: CGFloat
            if shouldCenterY  {
                /// If we're not zooming into a rect, (or the rect is shorter than the screen's height), center it vertically
                /// (it's negative since we want to move the offset upwards—and show the black bars above and below it)
                y = -(screenSize.height - scaledImageSize.height) / 2
                print("    🌻 Y: centering")
            } else {
                let maxY = contentSize.height - screenSize.height + BottomOffsetToBePassedIn
                y = min(max(self.contentOffset.y, 0), maxY)
                print("    🌻 Y: untouched")
            }
            
            /// Get the (scaled) x position of the zoom rect.
            let widthRatio =  scaledImageSize.width / screenSize.width
            let x: CGFloat
            if zoomRect != .zero {
                x = zoomRect.origin.x * widthRatio
            } else {
                if !widerThanScreen {
                    x = -(screenSize.width - scaledImageSize.width) / 2
                    print("    🌻 X: centering")
                } else {
                    let maxX = contentSize.width - screenSize.width
                    x = min(max(self.contentOffset.x, 0), maxX)
                    print("    🌻 X: untouched")
                }
            }

            contentOffset = CGPoint(x: x, y: y)
            
        } else if scaledImageSize.isTaller(than: screenSize) {
            
            let x: CGFloat
            if zoomRect == .zero || scaledImageSize.width < screenSize.width  {
                /// If we're not zooming into a rect, (or the rect is narrower than the screen's width), center it horizontally
                /// (it's negative since we want to move the offset leftwards—and show the black bars to the sides of it)
                x = -(screenSize.width - scaledImageSize.width) / 2
            } else {
                /// Otherwise leave it alone
                x = self.contentOffset.x
            }
            
            /// Get the (scaled) y position of the zoom rect
            let heightRatio =  scaledImageSize.height / screenSize.height
            let y = zoomRect.origin.y * heightRatio

            contentOffset = CGPoint(x: x, y: y)
            
        } else {
            /// same aspect ratio's, so no offset necessary to center
            contentOffset = self.contentOffset
        }

        if withAnimation {
            animatingOffsetChange = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.animatingOffsetChange = false
            }
        }

//        withAnimation(.interactiveSpring()) {
            self.setContentOffset(contentOffset, animated: withAnimation)
//        }
        
        print("🔩     contentOffset: \(contentOffset), zoomScale: \(zoomScale)")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        positionContent(fromLayoutSubviews: true)
    }
    
    func zoomToFill(_ imageSize: CGSize) {
        print("🍉 Zoom to fill \(imageSize)")
        let boundingBox = UIScreen.main.bounds.size.boundingBoxToFill(imageSize)

        if boundingBox == .zero || boundingBox == CGRect(x: 0, y: 0, width: 1, height: 1) {
            /// Only set the `zoomScale` to 1 if it's not already at 1
            guard zoomScale != 1 else { return }
            setZoomScale(1, animated: false)
        } else {
            shouldCenterCapture = true
            let zoomRect = boundingBox.zoomRect(
                forImageSize: imageSize,
                fittedInto: bounds.size,
                padded: false
            )
            zoom(to: zoomRect, animated: true)
//            setContentOffset(CGPoint(x: calculatedX, y: 0), animated: true)
        }
        
//        shouldCenterCapture = true
    }
    
    func zoomToFit(_ imageSize: CGSize) {
        print("Zoom to fit")
    }
    
    func zoomTo(_ zoomBox: ZoomBox) {
        /// If an `id` was provided, make sure it matches
//        if let zoomBoxImageId = zoomBox.imageId {
//                guard zoomBoxImageId == id else {
//                    /// `ZoomBox` was mean for another `ZoomableScrollView`
//                    return
//                }
//        }
        shouldPositionContent = true
        zoomRect = .zero

        if zoomBox.boundingBox == .zero || zoomBox.boundingBox == CGRect(x: 0, y: 0, width: 1, height: 1) {
            guard zoomScale != 1 else { return }
//            guard !isAtDefaultScale else { return }
            relativeAspectRatioType = nil
            shouldCenterToFit = true
            setZoomScale(1, animated: zoomBox.animated)
        } else {
            relativeAspectRatioType = bounds.size.relativeAspectRatio(of: zoomBox.imageSize)
//            relativeAspectRatioType = zoomBox.boundingBox.size.relativeAspectRatio(of: bounds.size)
            shouldCenterToFit = false
            
            
//            zoom(onTo: zoomBox)
            var zoomRect = zoomBox.boundingBox.zoomRect(forImageSize: zoomBox.imageSize, fittedInto: frame.size, padded: false)
            zoomRect = CGRect(
                x: zoomRect.origin.x,
                y: zoomRect.origin.y,
                width: zoomRect.size.width,
                height: zoomRect.size.height
            )

            /// Do this only if ZoomBox has the option (have option for both top and bottom safeAreaPoints
            if zoomBox.padded {
                zoomRect = paddedForUI(zoomRect)
            }
            
            self.zoomRect = zoomRect
            zoom(to: zoomRect, animated: zoomBox.animated)
        }
        
//        isAtDefaultScale = false
    }
    
    func paddedForUI(_ zoomRect: CGRect) -> CGRect {
        
        /// Modify this as needed to define a minimum aspect ratio for the area we're zooming into (so it does not get obstructed by the UI elements)
        let safeSize = CGSize(width: 430, height: 530)
        
        let horizontalPadding: CGFloat
        if zoomRect.size.isTaller(than: safeSize) {
            horizontalPadding = (zoomRect.size.height * safeSize.widthToHeightRatio) - zoomRect.size.width
        } else {
            horizontalPadding = zoomRect.size.width * 0.1
        }

        return zoomRect.padHorizontally(by: horizontalPadding, in: frame)
    }
}

extension CGRect {
    func padHorizontally(by padding: CGFloat, in frame: CGRect) -> CGRect {
        
        var r = self
        var horizontalPaddingNeeded = padding
        
        let maxLeadingPadding = r.minX
        let maxTrailingPadding = frame.size.width - r.maxX
        
        /// First try adding half to the side with the most to spare
        if maxLeadingPadding > maxTrailingPadding {
            let leadingPadding = min(maxLeadingPadding, horizontalPaddingNeeded/2.0)
            horizontalPaddingNeeded -= leadingPadding

            /// Pad it by transposing it to the left and the expanding the width
            r.origin.x = r.origin.x - leadingPadding
            r.size.width = r.width + leadingPadding
            
            let trailingPadding = min(maxTrailingPadding, horizontalPaddingNeeded)
            horizontalPaddingNeeded -= trailingPadding
            
            /// Pad it by expanding the width
            r.size.width = r.width + trailingPadding

        } else {

            let trailingPadding = min(maxTrailingPadding, horizontalPaddingNeeded/2.0)
            horizontalPaddingNeeded -= trailingPadding

            /// Pad it by expanding the width
            r.size.width = r.width + trailingPadding

            let leadingPadding = min(maxLeadingPadding, horizontalPaddingNeeded)
            horizontalPaddingNeeded -= leadingPadding
            
            /// Pad it by transposing it to the left and the expanding the width
            r.origin.x = r.origin.x - leadingPadding
            r.size.width = r.width + leadingPadding
        }
        
        guard horizontalPaddingNeeded > 0 else {
            return r
        }
        
        /// Now if there's any padding left, divide amongst both sides equally
        r.origin.x = r.origin.x - (horizontalPaddingNeeded/2.0)
        r.size.width = r.width + (horizontalPaddingNeeded)
        
        return r
    }
}

import SwiftSugar

extension CGFloat {
    func rounded(toPlaces places: Int) -> CGFloat {
        Double(self).rounded(toPlaces: places)
    }
}

extension CGSize {
    
    func isWider(than other: CGSize) -> Bool {
        widthToHeightRatio > other.widthToHeightRatio
    }
    
    func isTaller(than other: CGSize) -> Bool {
        widthToHeightRatio < other.widthToHeightRatio
    }
    
    func relativeAspectRatio(of other: CGSize) -> RelativeAspectRatioType {
        let ratio = widthToHeightRatio.rounded(toPlaces: 2)
        let otherRatio = other.widthToHeightRatio.rounded(toPlaces: 2)
//        let ratio = widthToHeightRatio
//        let otherRatio = other.widthToHeightRatio
        if otherRatio > ratio {
            return .wider
        } else if otherRatio < ratio {
            return .taller
        } else {
            return .equal
        }
    }
}

func relativeAspectRatio(of size: CGSize, to other: CGSize) -> RelativeAspectRatioType {
    let ratio = size.widthToHeightRatio.rounded(toPlaces: 2)
    let otherRatio = other.widthToHeightRatio.rounded(toPlaces: 2)
//        let ratio = widthToHeightRatio
//        let otherRatio = other.widthToHeightRatio
    if otherRatio > ratio {
        return .wider
    } else if otherRatio < ratio {
        return .taller
    } else {
        return .equal
    }
}

extension CGSize {
    func boundingBoxToFill(_ size: CGSize) -> CGRect {
        let scaledWidth: CGFloat = (size.width * self.height) / size.height

        let x: CGFloat = ((scaledWidth - self.width) / 2.0)
        let h: CGFloat = size.height
        
        let rect = CGRect(
            x: x / scaledWidth,
            y: 0,
            width: (self.width / scaledWidth),
            height: h / size.height
        )

        print("🧮 scaledWidth: \(scaledWidth)")
        print("🧮 bounds size: \(self)")
        print("🧮 imageSize: \(size)")
        print("🧮 rect: \(rect)")
        return rect
    }

}


fileprivate struct ZoomableScrollViewImpl<Content: View>: UIViewControllerRepresentable {
    let content: Content
    let doubleTap: AnyPublisher<Void, Never>
    
    func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController(coordinator: context.coordinator, doubleTap: doubleTap)
        Task(priority: .high) {
//            await MainActor.run {
//                viewController.scrollView.setZoomScale(1.01, animated: false)
//            }
//            await MainActor.run {
//                viewController.scrollView.setZoomScale(1, animated: false)
//            }
        }
        return viewController
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }
    
    func updateUIViewController(_ viewController: ViewController, context: Context) {
        viewController.update(content: self.content, doubleTap: doubleTap)
    }
    
    // MARK: - ViewController
    
    class ViewController: UIViewController, UIScrollViewDelegate {
        let coordinator: Coordinator
        let scrollView = CenteringScrollView()
        
        var doubleTapCancellable: Cancellable?
        var updateConstraintsCancellable: Cancellable?
        
        private var hostedView: UIView { coordinator.hostingController.view! }
        
        private var contentSizeConstraints: [NSLayoutConstraint] = [] {
            willSet { NSLayoutConstraint.deactivate(contentSizeConstraints) }
            didSet { NSLayoutConstraint.activate(contentSizeConstraints) }
        }
        
        required init?(coder: NSCoder) { fatalError() }
        init(coordinator: Coordinator, doubleTap: AnyPublisher<Void, Never>) {
            self.coordinator = coordinator
            super.init(nibName: nil, bundle: nil)
            self.view = scrollView
            
            scrollView.delegate = self  // for viewForZooming(in:)
//            scrollView.maximumZoomScale = 10
            scrollView.maximumZoomScale = 20
            scrollView.minimumZoomScale = 1
            scrollView.bouncesZoom = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false

            /// Changed this to `.always` after discovering that `.never` caused a slight vertical offset when displaying an image at zoom scale 1 on a full screen.
            /// The potential repurcisions of these haven't been explored—so keep an eye on this, as it may break other uses.
//            scrollView.contentInsetAdjustmentBehavior = .never
            //TODO: only use this if the image has a width-height ratio that's equal or tall (not for wide images)
//            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.contentInsetAdjustmentBehavior = .always
            let topSafeAreaHeight: CGFloat = 59.0
            let bottomSafeAreaHeight: CGFloat = 34.0
            scrollView.contentInset = UIEdgeInsets(
                top: -topSafeAreaHeight,
                left: 0,
                bottom: BottomOffsetToBePassedIn - bottomSafeAreaHeight,
                right: 0
            )

            let hostedView = coordinator.hostingController.view!
            hostedView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(hostedView)
//            hostedView.translatesAutoresizingMaskIntoConstraints = true
//            hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            hostedView.frame = scrollView.bounds
//            hostedView.insetsLayoutMarginsFromSafeArea = false
//            if let backgroundColor {
//            hostedView.backgroundColor = .black
//            }
            
//            scrollView.setZoomScale(2.01, animated: true)
//            scrollView.setZoomScale(1, animated: true)

            NSLayoutConstraint.activate([
                hostedView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
                hostedView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
                hostedView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                hostedView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            ])
            
            updateConstraintsCancellable = scrollView.publisher(for: \.bounds).map(\.size).removeDuplicates()
                .sink { [unowned self] size in
                    view.setNeedsUpdateConstraints()
                }
            doubleTapCancellable = doubleTap.sink { [unowned self] in handleDoubleTap() }
            
            NotificationCenter.default.addObserver(
                self, selector: #selector(zoomZoomableScrollView),
                name: .zoomZoomableScrollView, object: nil
            )
            
            NotificationCenter.default.addObserver(
                self, selector: #selector(zoomToFitZoomableScrollView),
                name: .zoomToFitZoomableScrollView, object: nil
            )

            NotificationCenter.default.addObserver(
                self, selector: #selector(zoomToFillZoomableScrollView),
                name: .zoomToFillZoomableScrollView, object: nil
            )
        }
        
        @objc func zoomToFitZoomableScrollView(notification: Notification) {
            guard let imageSize = notification.userInfo?[Notification.ZoomableScrollViewKeys.imageSize] as? CGSize
            else { return }
            scrollView.zoomToFit(imageSize)
        }

        @objc func zoomToFillZoomableScrollView(notification: Notification) {
            guard let imageSize = notification.userInfo?[Notification.ZoomableScrollViewKeys.imageSize] as? CGSize
            else { return }
            scrollView.zoomToFill(imageSize)
        }

        @objc func zoomZoomableScrollView(notification: Notification) {
            guard let zoomBox = notification.userInfo?[Notification.ZoomableScrollViewKeys.zoomBox] as? ZoomBox
            else { return }
            scrollView.zoomTo(zoomBox)
        }
        
        func update(content: Content, doubleTap: AnyPublisher<Void, Never>) {
            coordinator.hostingController.rootView = content
            scrollView.setNeedsUpdateConstraints()
            doubleTapCancellable = doubleTap.sink { [unowned self] in handleDoubleTap() }
        }
        
        func handleDoubleTap() {
            scrollView.setZoomScale(scrollView.zoomScale >= 1 ? scrollView.minimumZoomScale : 1, animated: true)
        }
        
        //MARK: - UIView Overrides
        
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            coordinator.animateAlongsideTransition { [self] context in
                scrollView.zoom(to: hostedView.bounds, animated: false)
            }
        }
        
        override func updateViewConstraints() {
            super.updateViewConstraints()
            let hostedContentSize = coordinator.hostingController.sizeThatFits(in: view.bounds.size)
            contentSizeConstraints = [
                hostedView.widthAnchor.constraint(equalToConstant: hostedContentSize.width),
                hostedView.heightAnchor.constraint(equalToConstant: hostedContentSize.height),
            ]
        }
        
        override func viewDidAppear(_ animated: Bool) {
            scrollView.zoom(to: hostedView.bounds, animated: false)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()

            let hostedContentSize = coordinator.hostingController.sizeThatFits(in: view.bounds.size)
            scrollView.minimumZoomScale = min(
                scrollView.bounds.width / hostedContentSize.width,
                scrollView.bounds.height / hostedContentSize.height)
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostedView
        }

        //MARK: - UIScrollViewDelegate

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            // For some reason this is needed in both didZoom and layoutSubviews, thanks to https://medium.com/@ssamadgh/designing-apps-with-scroll-views-part-i-8a7a44a5adf7
            // Sometimes this seems to work (view animates size and position simultaneously from current position to center) and sometimes it does not (position snaps to center immediately, size change animates)
            self.scrollView.positionContent()
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            print("🟣🌻 scrollViewWillBeginDragging, setting shouldPositionContent to true")
            self.scrollView.shouldPositionContent = false
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            print("🟣🌻 scrollViewWillEndDragging")
        }

        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            print("🟣🌻 scrollViewDidEndScrollingAnimation")
//            NotificationCenter.default.post(name: .zoomableScrollViewDidEndScrollingAnimation, object: nil, userInfo: [
//                Notification.ZoomableScrollViewKeys.contentSize: scrollView.contentSize,
//                Notification.ZoomableScrollViewKeys.contentOffset: scrollView.contentOffset
//            ])
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            print("🟣🌻 scrollViewDidEndDragging")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                if !scrollView.isDragging {
                    self.scrollView.positionContent(withAnimation: true)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    self.scrollView.shouldPositionContent = true
//                }
//                }
            }
        }
        
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            print("🟣🌻 scrollViewDidEndZooming")
            self.scrollView.positionContent(withAnimation: true)
//            NotificationCenter.default.post(name: .zoomableScrollViewDidEndZooming, object: nil, userInfo: [
//                Notification.ZoomableScrollViewKeys.contentSize: scrollView.contentSize,
//                Notification.ZoomableScrollViewKeys.contentOffset: scrollView.contentOffset
//            ])
        }
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }
    }
}

extension Notification.Name {
    public static var zoomableScrollViewDidEndZooming: Notification.Name { return .init("zoomableScrollViewDidEndZooming") }
    public static var zoomableScrollViewDidEndScrollingAnimation: Notification.Name { return .init("zoomableScrollViewDidEndScrollingAnimation") }
}

extension Notification {
    public struct ZoomableScrollViewKeys {
        public static let contentOffset = "contentOffset"
        public static let contentSize = "contentSize"
    }
}


extension UIViewControllerTransitionCoordinator {
    // Fix UIKit method that's named poorly for trailing closure style
    @discardableResult
    func animateAlongsideTransition(_ animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) -> Bool {
        return animate(alongsideTransition: animation, completion: completion)
    }
}

/// Execute scoped modifications to `arg`.
///
/// Useful when multiple modifications need to be made to a single nested property. For example,
/// ```
/// view.frame.origin.x -= view.frame.width / 2
/// view.frame.origin.y -= view.frame.height / 2
/// ```
/// can be rewritten as
/// ```
/// mutate(&view.frame) {
///   $0.origin.x -= $0.width / 2
///   $0.origin.y -= $0.height / 2
/// }
/// ```
///
public func mutate<T>(_ arg: inout T, _ body: (inout T) -> Void) {
    body(&arg)
}

/// This identifies an area of the ZoomableScrollView to focus on
public struct ZoomBox {
    
    /// This is the boundingBox—in terms of a 0 to 1 ratio on each dimension of what the CGRect is (similar to the boundingBox in Vision, with the y-axis starting from the bottom)
    public let boundingBox: CGRect
    public let padded: Bool
    public let animated: Bool
    public let imageSize: CGSize
    public let imageId: UUID?
    
    public init(boundingBox: CGRect, animated: Bool = true, padded: Bool = true, imageSize: CGSize, imageId: UUID? = nil) {
        self.boundingBox = boundingBox
        self.padded = padded
        self.animated = animated
        self.imageSize = imageSize
        self.imageId = imageId
    }
    
//    public static let none = Self.init(boundingBox: .zero, imageSize: .zero, imageId: UUID())
}
















import UIKit
import VisionSugar
import SwiftUISugar

extension UIScrollView {

    func zoomToScale(_ newZoomScale: CGFloat, on point: CGPoint) {
        let scaleChange = newZoomScale / zoomScale
        let rect = zoomRect(forFactorChangeInZoomScaleOf: scaleChange, on: point)
        zoom(to: rect, animated: true)
    }

    func zoomRect(forFactorChangeInZoomScaleOf factor: CGFloat, on point: CGPoint) -> CGRect {
        let size = CGSize(width: frame.size.width / factor,
                          height: frame.size.height / factor)
        let zoomSize = CGSize(width: size.width / zoomScale,
                              height: size.height / zoomScale)

        let origin = CGPoint(x: point.x - (zoomSize.width / factor),
                             y: point.y - (zoomSize.height / factor))
        return CGRect(origin: origin, size: zoomSize)
    }
    
    func zoom(onTo zoomBox: ZoomBox, animated: Bool = true) {
        zoomIn(
            boundingBox: zoomBox.boundingBox,
            padded: zoomBox.padded,
            imageSize: zoomBox.imageSize,
            animated: zoomBox.animated
        )
    }

    func zoomIn(boundingBox: CGRect, padded: Bool, imageSize: CGSize, animated: Bool = true) {

        let zoomRect = boundingBox.zoomRect(forImageSize: imageSize, fittedInto: frame.size, padded: padded)
//        var zoomRect = boundingBox.rectForSize(imageSize, fittedInto: frame.size)
//        if padded {
//            let ratio = min(frame.size.width / (zoomRect.size.width * 5), 3.5)
//            zoomRect.pad(within: frame.size, ratio: ratio)
//        }

        print("🔍 zoomIn on: \(zoomRect) within \(frame.size)")
        let zoomScaleX = frame.size.width / zoomRect.width
        print("🔍 zoomScaleX is \(zoomScaleX)")
        let zoomScaleY = frame.size.height / zoomRect.height
        print("🔍 zoomScaleY is \(zoomScaleY)")
        print("🔍 🤖 calculated zoomScale is: \(zoomRect.zoomScale(within: frame.size))")

        zoom(to: zoomRect, animated: animated)
    }
}

extension CGRect {

    func zoomRect(forImageSize imageSize: CGSize, fittedInto frameSize: CGSize, padded: Bool) -> CGRect {
        var zoomRect = rectForSize(imageSize, fittedInto: frameSize)
        if padded {
            let ratio = min(frameSize.width / (zoomRect.size.width * 5), 3.5)
            zoomRect.pad(within: frameSize, ratio: ratio)
        }
        return zoomRect
    }
    func zoomScale(within parentSize: CGSize) -> CGFloat {
        let xScale = parentSize.width / width
        let yScale = parentSize.height / height
        return min(xScale, yScale)
    }

    mutating func pad(within parentSize: CGSize, ratio: CGFloat) {
        padX(withRatio: ratio, withinParentSize: parentSize)
        padY(withRatio: ratio, withinParentSize: parentSize)
    }

}

extension CGRect {

    mutating func padX(
        withRatio paddingRatio: CGFloat,
        withinParentSize parentSize: CGSize,
        minPadding padding: CGFloat = 5.0,
        maxRatioOfParent: CGFloat = 0.9
    ) {
        padX(withRatioOfWidth: paddingRatio)
        origin.x = max(padding, origin.x)
        if maxX > parentSize.width {
            size.width = parentSize.width - origin.x - padding
        }
    }

    mutating func padY(
        withRatio paddingRatio: CGFloat,
        withinParentSize parentSize: CGSize,
        minPadding padding: CGFloat = 5.0,
        maxRatioOfParent: CGFloat = 0.9
    ) {
        padY(withRatioOfHeight: paddingRatio)
        origin.y = max(padding, origin.y)
        if maxY > parentSize.height {
            size.height = parentSize.height - origin.y - padding
        }
    }

    mutating func padX(withRatioOfWidth ratio: CGFloat) {
        let padding = size.width * ratio
        padX(with: padding)
    }

    mutating func padX(with padding: CGFloat) {
        origin.x -= (padding / 2.0)
        size.width += padding
    }

    mutating func padY(withRatioOfHeight ratio: CGFloat) {
        let padding = size.height * ratio
        padY(with: padding)
    }

    mutating func padY(with padding: CGFloat) {
        origin.y -= (padding / 2.0)
        size.height += padding
    }

    func rectForSize(_ size: CGSize, fittedInto frameSize: CGSize, withLegacyPaddingCorrections: Bool = false) -> CGRect {
        let sizeFittingFrame = size.sizeFittingWithin(frameSize)
        var rect = rectForSize(sizeFittingFrame)

        //TODO: Remove these (are they even needed now?)
        if withLegacyPaddingCorrections {
            let paddingLeft: CGFloat?
            let paddingTop: CGFloat?
            if size.widthToHeightRatio < frameSize.widthToHeightRatio {
                paddingLeft = (frameSize.width - sizeFittingFrame.width) / 2.0
                paddingTop = nil
            } else {
                paddingLeft = nil
                paddingTop = (frameSize.height - sizeFittingFrame.height) / 2.0
            }

            if let paddingLeft {
                rect.origin.x += paddingLeft
            }
            if let paddingTop {
                rect.origin.y += paddingTop
            }
        }

        return rect
    }
}

extension CGSize {
    /// Returns a size that fits within the parent size
    func sizeFittingWithin(_ size: CGSize) -> CGSize {
        let newWidth: CGFloat
        let newHeight: CGFloat
        if widthToHeightRatio < size.widthToHeightRatio {
            /// height would be the same as parent
            newHeight = size.height

            /// we're scaling the width accordingly
            newWidth = (width * newHeight) / height
        } else {
            /// width would be the same as parent
            newWidth = size.width

            /// we're scaling the height accordingly
            newHeight = (height * newWidth) / width
        }
        return CGSize(width: newWidth, height: newHeight)
    }
}
