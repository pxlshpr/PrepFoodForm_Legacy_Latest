import SwiftUI

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
