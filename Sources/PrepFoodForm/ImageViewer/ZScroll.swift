import SwiftUI
import Combine

public struct ZScroll<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    @State var doubleTap = PassthroughSubject<Void, Never>()
    
    public var body: some View {
        ZScrollImpl(content: content, doubleTap: doubleTap.eraseToAnyPublisher())
        /// The double tap gesture is a modifier on a SwiftUI wrapper view, rather than just putting a UIGestureRecognizer on the wrapped view,
        /// because SwiftUI and UIKit gesture recognizers don't work together correctly correctly for failure and other interactions.
            .onTapGesture(count: 2) {
                doubleTap.send()
            }
    }
}

fileprivate struct ZScrollImpl<Content: View>: UIViewControllerRepresentable {
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
                bottom: -bottomSafeAreaHeight,
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
            guard let zoomBox = notification.userInfo?[Notification.ZoomableScrollViewKeys.zoomBox] as? ZBox
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
//            self.scrollView.shouldPositionContent = false
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
