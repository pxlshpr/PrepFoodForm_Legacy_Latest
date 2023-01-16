import SwiftUI

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
