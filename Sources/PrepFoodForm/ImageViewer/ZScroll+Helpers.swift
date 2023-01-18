import SwiftUI
import SwiftSugar

enum RelativeAspectRatioType {
    case taller
    case wider
    case equal
}

extension Notification.Name {
    public static var zoomableScrollViewDidEndZooming: Notification.Name { return .init("zoomableScrollViewDidEndZooming") }
    public static var zoomableScrollViewDidEndScrollingAnimation: Notification.Name { return .init("zoomableScrollViewDidEndScrollingAnimation") }
    
    public static var scannerDidPresentKeyboard: Notification.Name { return .init("scannerDidPresentKeyboard") }
    public static var scannerDidDismissKeyboard: Notification.Name { return .init("scannerDidDismissKeyboard") }
    public static var scannerDidSetImage: Notification.Name { return .init("scannerDidSetImage") }
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

extension CGFloat {
    func rounded(toPlaces places: Int) -> CGFloat {
        Double(self).rounded(toPlaces: places)
    }
}
