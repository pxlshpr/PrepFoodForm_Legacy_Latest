//TODO: 🗑

import SwiftUI
import SwiftSugar

//MARK: - Notifications

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

//MARK: - ZBox

/// This identifies an area to zoom onto
public struct ZBox {
    
    /// This is the boundingBox—in terms of a 0 to 1 ratio on each dimension of what the CGRect is (similar to the boundingBox in Vision, with the y-axis starting from the bottom)
    public let boundingBox: CGRect
    public let padded: Bool
    public let paddedForSingleBox: Bool
    public let animated: Bool
    public let imageSize: CGSize
    public let imageId: UUID?
    
    public init(boundingBox: CGRect, animated: Bool = true, padded: Bool = true, paddedForSingleBox: Bool = false, imageSize: CGSize, imageId: UUID? = nil) {
        self.boundingBox = boundingBox
        self.padded = padded
        self.paddedForSingleBox = paddedForSingleBox
        self.animated = animated
        self.imageSize = imageSize
        self.imageId = imageId
    }
}

//MARK: - Extensions
extension CGSize {
    func isWider(than other: CGSize) -> Bool {
        widthToHeightRatio > other.widthToHeightRatio
    }
    func isTaller(than other: CGSize) -> Bool {
        widthToHeightRatio < other.widthToHeightRatio
    }
}

extension CGRect {
    var horizontallyPaddedBoundingBox: CGRect {
        let padding = (self.width / 2.0)
        return CGRect(
            x: max(0.0, self.origin.x - (padding / 2.0)),
            y: self.origin.y,
            width: min(self.width + padding, 1.0),
            height: self.size.height
        )
    }
}

extension CGFloat {
    func rounded(toPlaces places: Int) -> CGFloat {
        Double(self).rounded(toPlaces: places)
    }
}
