import SwiftUI
import Combine

class NewCenteringScrollView: UIScrollView {
    func centerContent() {
        assert(subviews.count == 1)
        mutate(&subviews[0].frame) {
            // not clear why view.center.{x,y} = bounds.mid{X,Y} doesn't work -- maybe transform?
            $0.origin.x = max(0, bounds.width - $0.width) / 2
            $0.origin.y = max(0, bounds.height - $0.height) / 2
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerContent()
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
            scrollView.maximumZoomScale = 30
            scrollView.minimumZoomScale = 1
            scrollView.bouncesZoom = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.clipsToBounds = false
            
            let hostedView = coordinator.hostingController.view!
            hostedView.translatesAutoresizingMaskIntoConstraints = false
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
//            zoom(to: CGRectMake(220, 217, 81.55, 176.75))
//            zoom(to: CGRectMake(169, 381, 54, 18))
            zoom(to: CGRectMake(78, 167, 333, 333))
        }
        

        func convertBoundingBoxAndZoom(_ boundingBox: CGRect, imageSize: CGSize) {
            zoom(to: boundingBox.rectForSize(imageSize))
        }

        func zoom(to rect: CGRect) {
            
            var screenAspectRect: CGRect {
                var new: CGRect
                if rect.size.isWider(than: scrollView.bounds.size) {
                    
                    /// Use the same x and width as rect
                    let x = rect.origin.x
                    let width = rect.width

                    /// Calculate height based on screen dimensions
                    let height = (width * scrollView.bounds.height) / scrollView.bounds.width

                    /// Calculate y so that its centered vertically
                    let y = rect.origin.y - ((height - rect.height) / 2.0)
                    
                    new = CGRectMake(x, y, width, height)
                    
                } else if rect.size.isTaller(than: scrollView.bounds.size) {
                    /// Use the same y and height as rect
                    let y = rect.origin.y
                    let height = rect.height

                    /// Calculate width based on screen dimensions
                    let width = (height * scrollView.bounds.width) / scrollView.bounds.height

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
            
            print("📏 \(screenRect)")
            let zoomScale: CGFloat
            /// If image itself (not the rect) has wider (or equal) aspect ratio than the screen
            if scrollView.contentSize.isWider(than: scrollView.bounds.size) {
                zoomScale = scrollView.bounds.width / screenRect.width
            } else {
                zoomScale = scrollView.bounds.height / screenRect.height
            }
            
            /// Now use zoomScale and scale the screenAspectRect's origin to get the contentOffset
            let contentOffset = CGPointMake(screenRect.origin.x * zoomScale, screenRect.origin.y * zoomScale)

            /// [ ] See if this works when zoomed-in somewhere and we need to zoom to a certain location
            /// - Assume we have the image size handy
            /// - We'll probably have to do ntihg
            
            UIView.animate(withDuration: 0.3) {
                self.scrollView.zoomScale = zoomScale
                self.scrollView.contentOffset = contentOffset
            }
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
            
            let hostedContentSize = coordinator.hostingController.sizeThatFits(in: view.bounds.size)
            scrollView.minimumZoomScale = min(
                scrollView.bounds.width / hostedContentSize.width,
                scrollView.bounds.height / hostedContentSize.height)
        }
        
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            coordinator.animateAlongsideTransition { [self] context in
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
            print("🥦 scrollViewDidZoom: \(scrollView.contentOffset) \(scrollView.contentSize) \(scrollView.bounds.size) x\(scrollView.zoomScale)")
            self.scrollView.centerContent()
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
//            print("🥦 scrollViewDidScroll: \(scrollView.contentOffset) \(scrollView.contentSize) \(scrollView.bounds.size) x\(scrollView.zoomScale)")
            print("🥦 origin.y: \(max(0, scrollView.bounds.height - scrollView.contentSize.height) / 2)")
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