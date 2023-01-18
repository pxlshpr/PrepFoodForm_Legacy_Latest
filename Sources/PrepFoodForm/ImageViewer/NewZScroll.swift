import SwiftUI
import Combine


class NewCenteringScrollView: UIScrollView {
    
//    func centerContent() {
//        assert(subviews.count == 1)
//        mutate(&subviews[0].frame) {
//            // not clear why view.center.{x,y} = bounds.mid{X,Y} doesn't work -- maybe transform?
////                        let bounds = UIScreen.main.bounds
//            let bounds = HardcodedBounds
//            print("🦄🗜 Centering when bounds are: \(bounds.size)")
//            $0.origin.x = max(0, bounds.width - $0.width) / 2
//            $0.origin.y = max(0, bounds.height - $0.height) / 2
//        }
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        centerContent()
    }
    
    func centerContent(for imageSize: CGSize? = nil) {
        var top: CGFloat = 0
//        let bottom: CGFloat = -42 /// this was for the simulator
        let bottom: CGFloat = -2
//        let bottom: CGFloat = -8  /// this was for the simulator
        var left: CGFloat = 0
        
        if let imageSize {
            let bounds = CGRectMake(0, 0, 430, HeightWithKeyboard)
            if imageSize.isWider(than: bounds.size) {
                top = (bounds.size.height - contentSize.height) * 0.5
            } else if imageSize.isTaller(than: bounds.size) {
                left = (bounds.size.width - contentSize.width) * 0.5
            }
        } else {
            if contentSize.width < bounds.size.width {
                left = (bounds.size.width - contentSize.width) * 0.5
            }
            if contentSize.height < bounds.size.height {
                top = (bounds.size.height - contentSize.height) * 0.5
            }
        }
        self.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: left)
        print("👀 contentInset is: \(self.contentInset)")
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
    }
}

struct NewZScroll<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    @State var doubleTap = PassthroughSubject<Void, Never>()
    
    var body: some View {
        NewZScrollImpl(content: content, doubleTap: doubleTap.eraseToAnyPublisher())
        /// The double tap gesture is a modifier on a SwiftUI wrapper view, rather than just putting a UIGestureRecognizer on the wrapped view,
        /// because SwiftUI and UIKit gesture recognizers don't work together correctly correctly for failure and other interactions.
            .onTapGesture(count: 2) {
                doubleTap.send()
            }
    }
}

fileprivate struct NewZScrollImpl<Content: View>: UIViewControllerRepresentable {
    let content: Content
    let doubleTap: AnyPublisher<Void, Never>
    
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController(coordinator: context.coordinator, doubleTap: doubleTap)
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
        let scrollView = NewCenteringScrollView()
        
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
            scrollView.maximumZoomScale = 30 //TODO: Revisit whether this is too much
            scrollView.minimumZoomScale = 1
            scrollView.bouncesZoom = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.clipsToBounds = false
            
            let hostedView = coordinator.hostingController.view!
            hostedView.translatesAutoresizingMaskIntoConstraints = false
            
            /// ** Added: This makes tall images stretch all the way to the top and bottom of the screen **
            //TODO: Deal with these magic values
            scrollView.contentInsetAdjustmentBehavior = .always
//            scrollView.contentInsetAdjustmentBehavior = .never
//            scrollView.contentInset = UIEdgeInsets(
//                top: TopInset,
//                left: 0,
//                bottom: BottomInsetInitial,
//                right: 0
//            )
            /// ***
            
            scrollView.addSubview(hostedView)
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
            
            NotificationCenter.default.addObserver(self, selector: #selector(scannerDidPresentKeyboard), name: .scannerDidPresentKeyboard, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(scannerDidDismissKeyboard), name: .scannerDidDismissKeyboard, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(scannerDidSetImage), name: .scannerDidSetImage, object: nil)
        }
        
        @objc func scannerDidSetImage(_ notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let imageSize = userInfo[Notification.ZoomableScrollViewKeys.imageSize] as? CGSize
            else { return }
            scrollView.centerContent(for: imageSize)
        }

        func update(content: Content, doubleTap: AnyPublisher<Void, Never>) {
            coordinator.hostingController.rootView = content
            scrollView.setNeedsUpdateConstraints()
            doubleTapCancellable = doubleTap.sink { [unowned self] in handleDoubleTap() }
        }
        
        func handleDoubleTap() {
            scrollView.setZoomScale(scrollView.zoomScale >= 1 ? scrollView.minimumZoomScale : 1, animated: true)
        }
        
        override func updateViewConstraints() {
            super.updateViewConstraints()
            let hostedContentSize = coordinator.hostingController.sizeThatFits(in: view.bounds.size)
            contentSizeConstraints = [
                hostedView.widthAnchor.constraint(equalToConstant: hostedContentSize.width),
                hostedView.heightAnchor.constraint(equalToConstant: hostedContentSize.height),
            ]
        }
        
        func simulateZoom() {
//            zoom(to: CGRectMake(115, 292, 192, 27))
            //            zoom(to: CGRectMake(122, 359, 107, 231.92))
            //            zoom(to: CGRectMake(286, 15, 72, 156.06))
            //            zoom(to: CGRectMake(38, 192, 185, 401))
        }
        
        @objc func scannerDidPresentKeyboard(notification: Notification) {
//            changeBottomContentInset(to: BottomInsetWithKeyboard)
            
            guard let userInfo = notification.userInfo,
                  let zBox = userInfo[Notification.ZoomableScrollViewKeys.zoomBox] as? ZBox
            else { return }
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.convertBoundingBoxAndZoom(zBox.boundingBox, imageSize: zBox.imageSize, bottomInset: BottomInsetWithKeyboard)
//            }
        }
        
        @objc func scannerDidDismissKeyboard(notification: Notification) {
//            changeBottomContentInset(to: BottomInsetInitial)
            
            guard let userInfo = notification.userInfo,
                  let zBox = userInfo[Notification.ZoomableScrollViewKeys.zoomBox] as? ZBox
            else { return }

            let delay: CGFloat
            if zBox.imageSize.isTaller(than: HardcodedBounds.size) {
                print("⚱️ imageSize.isTaller(than: HardcodedBounds.size), delaying zoom by 0.3")
                delay = 0.3
            } else {
                print("⚱️ imageSize.isTaller(than: HardcodedBounds.size), NOT delaying zoom by 0.3")
                delay = 0.3
            }
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.convertBoundingBoxAndZoom(zBox.boundingBox, imageSize: zBox.imageSize, bottomInset: BottomInsetInitial)
//            }
        }
        
        func changeBottomContentInset(to newValue: CGFloat) {
            let contentInset = UIEdgeInsets(top: TopInset, left: 0, bottom: newValue, right: 0)
            let contentOffset = scrollView.contentOffset
            scrollView.contentInset = contentInset
            scrollView.contentOffset = contentOffset
//            self.scrollView.setZoomScale(1, animated: true)
        }
        
        func convertBoundingBoxAndZoom(_ boundingBox: CGRect, imageSize: CGSize, bottomInset: CGFloat) {
            let imageSize = scrollView.contentSize
            
//            let bounds = HardcodedBounds
//            let bounds = UIScreen.main.bounds
            let bounds = CGRectMake(0, 0, 430, 566)

            let imageSizeWhenScaledToFit: CGSize
            if imageSize.isWider(than: bounds.size) {
                imageSizeWhenScaledToFit = CGSizeMake(
                    bounds.width,
                    (imageSize.height * bounds.width) / imageSize.width
                )
            } else if imageSize.isTaller(than: bounds.size) {
                imageSizeWhenScaledToFit = CGSizeMake(
                    (imageSize.width * bounds.height) / imageSize.height,
                    bounds.height
                )
            } else {
                imageSizeWhenScaledToFit = bounds.size
            }
            
            let rect = boundingBox.rectForSize(imageSizeWhenScaledToFit)
            print("📏 zooming to boundingBox: \(boundingBox)")
            print("📏 - scrollView contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset), zoomScale: \(scrollView.zoomScale)")
            print("📏 - bounds.size: \(bounds.size)")
            print("📏 - imageSizeWhenScaledToFit: \(imageSizeWhenScaledToFit)")
            print("📏 - rectForSize(imageSizeWhenScaledToFit): \(rect)")

            zoom(
                to: rect,
                imageSize: imageSize,
                bottomInset: bottomInset
            )
        }
        
        //TODO: Provide imageSize here and use that instead of scrollView.contentSize
        func zoom(to rect: CGRect, imageSize: CGSize, bottomInset: CGFloat) {
            
//            let imageSize = scrollView.contentSize
            //            let screenSize = scrollView.bounds.size
//            let screenSize = HardcodedBounds.size
//            let screenSize = CGSizeMake(430, 517)
            let screenSize = CGSizeMake(430, 483)

            //            screenSize.height = screenSize.height - 366
            //            let screenSize = UIScreen.main.bounds.size
            
            var screenAspectRect: CGRect {
                var new: CGRect
                if rect.size.isWider(than: screenSize) {
                    
                    /// Use the same x and width as rect
                    let x = rect.origin.x
                    let width = rect.width
                    
                    /// Calculate height based on screen dimensions
                    let height = (width * screenSize.height) / screenSize.width
                    
                    /// Calculate y so that its centered vertically
                    let y = rect.origin.y - ((height - rect.height) / 2.0)
                    
                    new = CGRectMake(x, y, width, height)
                    
                } else if rect.size.isTaller(than: screenSize) {
                    /// Use the same y and height as rect
                    let y = rect.origin.y
                    let height = rect.height
                    
                    /// Calculate width based on screen dimensions
                    let width = (height * screenSize.width) / screenSize.height
                    
                    /// Calculate x so that its centered horizontally
                    let x = rect.origin.x - ((width - rect.width) / 2.0)
                    
                    new = CGRectMake(x, y, width, height)
                    
                } else {
                    /// If same aspect ratio, do nothing and use rectForSize
                    new = rect
                }
                return new
            }
            
            let screenRect = screenAspectRect
            
            print("📏 screenRect: \(screenRect)")
            var relativeZoomScale: CGFloat
            /// If image itself (not the rect) has wider (or equal) aspect ratio than the screen
            if imageSize.isWider(than: screenSize) {
                print("📏 getting zoomScale by dividing screenSize.width: \(screenSize.width) / screenRect.width: \(screenRect.width)")
                relativeZoomScale = screenSize.width / screenRect.width
            } else {
                print("📏 getting zoomScale by dividing screenSize.height: \(screenSize.height) / screenRect.height: \(screenRect.height)")
                relativeZoomScale = screenSize.height / screenRect.height
            }
            
            print("📏 correcting relativeZoomScale (\(relativeZoomScale)) to absolute by")
            print("📏     dividing by current zoomScale (\(scrollView.zoomScale))")
//            let zoomScale = relativeZoomScale / scrollView.zoomScale
            let zoomScale = relativeZoomScale
            print("📏     = (\(zoomScale))")

            /// Now use zoomScale and scale the screenAspectRect's origin to get the contentOffset
            //            var contentOffset = CGPointMake(
            //                max(screenRect.origin.x * zoomScale, 0),
            //                max(screenRect.origin.y * zoomScale, 0)
            //            )
            let x = screenRect.origin.x * zoomScale
            var y = screenRect.origin.y
            //            if imageSize.isTaller(than: screenSize) {
            //                y = screenRect.origin.y + 20
            //            }
            y = y * zoomScale
            
            var contentOffset = CGPointMake(x, y)
            
            print("📏 contentOffset: \(contentOffset)")
            
            /// Correct rects here
            /// First calculate proposedRect
            let proposedRect = CGRect(
                x: contentOffset.x,
                y: contentOffset.y,
                width: screenSize.width,
                height: screenSize.height
            )
            print("📏 proposedRect: \(proposedRect)")
            
            /// ** Center proposed rect's that are larger than a dimension **
            /// If proposedRect.height > contentSize.height, set the y to 0 to center it vertically
            if proposedRect.size.height > (imageSize.height * zoomScale) {
                print("📏 proposedRect.size.height > scrollView.contentSize.height, setting y to 0 to center")
                contentOffset.y = 0
            }
            
            /// If proposedRect.width > contentSize.width, set the x to 0 to center it horizontally
            if proposedRect.size.width > (imageSize.width * zoomScale) {
                print("📏 proposedRect.size.width > scrollView.contentSize.width, setting x to 0 to center")
                contentOffset.x = 0
            }
            
            
            /// ** Correct rect's that are out of bounds **
            if proposedRect.minY < 0 {
                print("📏 proposedRect.minY < 0, setting y to 0")
                contentOffset.y = 0
            }
            if proposedRect.maxY > (imageSize.height * zoomScale) {
                print("📏 proposedRect.maxY > scrollView.contentSize.height, setting y to 0")
                contentOffset.y = 0
            }
            
            if proposedRect.minX < 0 {
                print("📏 proposedRect.maxX < 0, setting x to 0")
                contentOffset.x = 0
            }
            if proposedRect.maxX > (imageSize.width * zoomScale) {
                print("📏🍍 proposedRect.maxX > scrollView.contentSize.width, setting x to where screen end would be image end")
                contentOffset.x = (imageSize.width * zoomScale) - screenSize.width
            }
            
            /// [ ] See if this works when zoomed-in somewhere and we need to zoom to a certain location
            ///  [ ] Replace `scrollView.contentSize` with `imageSize` so that it's valid even at different zoom levels
            /// - Assume we have the image size handy
            /// - We'll probably have to do ntihg
            
            let contentInset = UIEdgeInsets(top: TopInset, left: 0, bottom: bottomInset, right: 0)

            print("📏 Setting contentOffset: \(contentOffset)")
            print("📏 Setting zoomScale: \(zoomScale)")

            print("⚱️ zooming to: \(rect)")
            scrollView.zoom(to: rect, animated: true)
            
//            print("⚱️ zooming to: \(screenRect)")
//            scrollView.zoom(to: screenRect, animated: true)

//            print("📏 proposedRect: \(proposedRect)")

//            UIView.animate(withDuration: 0.3) {
//                self.scrollView.zoomScale = zoomScale
//                self.scrollView.contentOffset = contentOffset
//            }
        }
        
        override func viewDidAppear(_ animated: Bool) {
            scrollView.zoom(to: hostedView.bounds, animated: false)
            /// Removed 60 for black wide label
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.simulateZoom()
            }
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            setScrollViewMinimumZoomScale()
        }
        
        func setScrollViewMinimumZoomScale() {
            let hostedContentSize = coordinator.hostingController.sizeThatFits(in: view.bounds.size)
            scrollView.minimumZoomScale = min(
                scrollView.bounds.width / hostedContentSize.width,
                scrollView.bounds.height / hostedContentSize.height)
//                HardcodedBounds.width / hostedContentSize.width,
//                (HardcodedBounds.height - 8) / hostedContentSize.height)
//                430 / hostedContentSize.width,
//                483 / hostedContentSize.height)
        }
        
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            coordinator.animateAlongsideTransition { [self] context in
                print("🦄 viewWillTransition")
                scrollView.zoom(to: hostedView.bounds, animated: false)
            }
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostedView
        }
        
        //MARK: UIScrollViewDelegate
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            // For some reason this is needed in both didZoom and layoutSubviews, thanks to https://medium.com/@ssamadgh/designing-apps-with-scroll-views-part-i-8a7a44a5adf7
            // Sometimes this seems to work (view animates size and position simultaneously from current position to center) and sometimes it does not (position snaps to center immediately, size change animates)
            print("""
🦄 scrollViewDidZoom:
    - 🦄 scrollView.contentOffset: \(scrollView.contentOffset)
    - 🦄 scrollView.contentSize: \(scrollView.contentSize)
    - 🦄 scrollView.bounds.size: \(scrollView.bounds.size)
    - 🦄 scrollView.zoomScale: \(scrollView.zoomScale)x
""")
//            self.scrollView.centerContent()
            self.scrollView.centerContent()
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            print("""
🦄 scrollViewDidScroll:
    - 🦄 scrollView.contentInset: \(scrollView.contentInset)
    - 🦄 scrollView.contentOffset: \(scrollView.contentOffset)
    - 🦄 scrollView.contentSize: \(scrollView.contentSize)
    - 🦄 scrollView.bounds.size: \(scrollView.bounds.size)
    - 🦄 scrollView.zoomScale: \(scrollView.zoomScale)x
""")
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
