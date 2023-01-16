import SwiftUI

/// This identifies an area of the ZoomableScrollView to focus on
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
    
//    public static let none = Self.init(boundingBox: .zero, imageSize: .zero, imageId: UUID())
}
