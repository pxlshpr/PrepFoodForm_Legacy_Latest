//TODO: 🗑

import SwiftUI
import Combine

class CenteringScrollView: UIScrollView {
    func centerContent(for imageSize: CGSize? = nil) {
        var top: CGFloat = 0
        var left: CGFloat = 0

        //TODO: Magic Number 🪄
//        let bottom = 924 - UIScreen.main.bounds.height
        let bottom: CGFloat = 0

        if contentSize.width < bounds.size.width {
            left = (bounds.size.width - contentSize.width) * 0.5
        }
        if contentSize.height < bounds.size.height {
            top = (bounds.size.height - contentSize.height) * 0.5
        }
        self.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: left)
    }
}

struct ZoomScrollView<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    @State var doubleTap = PassthroughSubject<Void, Never>()
    
    var body: some View {
        ZoomScrollViewRepresentable(content: content, doubleTap: doubleTap.eraseToAnyPublisher())
        /// The double tap gesture is a modifier on a SwiftUI wrapper view, rather than just putting a UIGestureRecognizer on the wrapped view,
        /// because SwiftUI and UIKit gesture recognizers don't work together correctly correctly for failure and other interactions.
            .onTapGesture(count: 2) {
                doubleTap.send()
            }
    }
}

fileprivate struct ZoomScrollViewRepresentable<Content: View>: UIViewControllerRepresentable {
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
            scrollView.maximumZoomScale = 30 //TODO: Revisit whether this is too much
            scrollView.minimumZoomScale = 1
            scrollView.bouncesZoom = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.clipsToBounds = false
            
            let hostedView = coordinator.hostingController.view!
            hostedView.translatesAutoresizingMaskIntoConstraints = false
            
            scrollView.contentInsetAdjustmentBehavior = .always
            
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
            
            NotificationCenter.default.addObserver(self, selector: #selector(zoomZoomableScrollView), name: .zoomZoomableScrollView, object: nil)
        }
                
        override func updateViewConstraints() {
            super.updateViewConstraints()
            let hostedContentSize = coordinator.hostingController.sizeThatFits(in: view.bounds.size)
            contentSizeConstraints = [
                hostedView.widthAnchor.constraint(equalToConstant: hostedContentSize.width),
                hostedView.heightAnchor.constraint(equalToConstant: hostedContentSize.height),
            ]
        }
        
        //MARK: - View Lifecycle
        
        override func viewDidAppear(_ animated: Bool) {
            scrollView.zoom(to: hostedView.bounds, animated: false)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            let hostedContentSize = coordinator.hostingController.sizeThatFits(in: view.bounds.size)
            scrollView.minimumZoomScale = min(
                scrollView.bounds.width / hostedContentSize.width,
                scrollView.bounds.height / hostedContentSize.height
            )
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostedView
        }
        
        //MARK: UIScrollViewDelegate
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            self.scrollView.centerContent()
        }
        
        //MARK: - Event Handlers
        
        func handleDoubleTap() {
            scrollView.setZoomScale(scrollView.zoomScale >= 1 ? scrollView.minimumZoomScale : 1, animated: true)
        }
        
        
        @objc func scannerDidSetImage(_ notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let imageSize = userInfo[Notification.ZoomableScrollViewKeys.imageSize] as? CGSize
            else { return }
//            scrollView.centerContent(for: imageSize)
            scrollView.centerContent()
        }

        func update(content: Content, doubleTap: AnyPublisher<Void, Never>) {
            coordinator.hostingController.rootView = content
            scrollView.setNeedsUpdateConstraints()
            doubleTapCancellable = doubleTap.sink { [unowned self] in handleDoubleTap() }
        }

        @objc func zoomZoomableScrollView(notification: Notification) {
            guard let zoomBox = notification.userInfo?[Notification.ZoomableScrollViewKeys.zoomBox] as? ZBox
            else { return }
            
            self.convertBoundingBoxAndZoom(zoomBox.boundingBox, imageSize: zoomBox.imageSize)
        }

        @objc func scannerDidPresentKeyboard(notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let zBox = userInfo[Notification.ZoomableScrollViewKeys.zoomBox] as? ZBox
            else { return }
            
            //TODO: Use zoomZoomableScrollView instead
//            let paddedBoundingBox = zBox.boundingBox.horizontallyPaddedBoundingBox
//            self.convertBoundingBoxAndZoom(paddedBoundingBox, imageSize: zBox.imageSize)
            self.convertBoundingBoxAndZoom(zBox.boundingBox, imageSize: zBox.imageSize)
        }
        
        @objc func scannerDidDismissKeyboard(notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let zBox = userInfo[Notification.ZoomableScrollViewKeys.zoomBox] as? ZBox
            else { return }

            //TODO: Use zoomZoomableScrollView instead
            self.convertBoundingBoxAndZoom(zBox.boundingBox, imageSize: zBox.imageSize)
        }
        
        func convertBoundingBoxAndZoom(_ boundingBox: CGRect, imageSize: CGSize) {
            let imageSizeScaledToFit = CGSize(
                width: scrollView.contentSize.width / scrollView.zoomScale,
                height: scrollView.contentSize.height / scrollView.zoomScale
            )
            
            let rect = boundingBox.rectForSize(imageSizeScaledToFit)
            scrollView.zoom(to: rect, animated: true)
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

/// Keeping this as a reference in case we encounter errors as this was previously working
class CenteringScrollView_Legacy_Reference: UIScrollView {
    let HeightWithKeyboard: CGFloat = 566 - TopBarHeight
    func centerContent(for imageSize: CGSize? = nil) {
        var top: CGFloat = 0
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
    }
}
