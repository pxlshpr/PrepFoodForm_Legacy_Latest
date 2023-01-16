import SwiftUI

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
                print("    🌻 Y: centering - \(y)")
            } else {
                let maxY = contentSize.height - screenSize.height + BottomOffsetToBePassedIn
                y = min(max(self.contentOffset.y, 0), maxY)
                print("    🌻 Y: untouched - \(y)")
            }
            
            /// Get the (scaled) x position of the zoom rect.
            let widthRatio =  scaledImageSize.width / screenSize.width
            let x: CGFloat
            if zoomRect != .zero {
                x = zoomRect.origin.x * widthRatio
                print("    🌻 X: setting to zoomRect")
            } else {
                if !widerThanScreen {
                    x = -(screenSize.width - scaledImageSize.width) / 2
                    print("    🌻 X: centering - \(x)")
                } else {
                    let maxX = contentSize.width - screenSize.width
                    x = min(max(self.contentOffset.x, 0), maxX)
                    print("    🌻 X: untouched - \(x)")
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
        
        if zoomRect != .zero {
            print("    🌻 zoomRect: resetting to .zero")
            zoomRect = .zero
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
    
    func zoomTo(_ zoomBox: ZBox) {
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
                zoomRect = paddedForUI(zoomRect, paddedForSingleBox: zoomBox.paddedForSingleBox)
            }
            
            self.zoomRect = zoomRect
            print("🌻🔵 zooming to: \(zoomRect)")
            zoom(to: zoomRect, animated: zoomBox.animated)
        }
        
//        isAtDefaultScale = false
    }
    
    func paddedForUI(_ zoomRect: CGRect, paddedForSingleBox: Bool) -> CGRect {
        
        /// Modify this as needed to define a minimum aspect ratio for the area we're zooming into (so it does not get obstructed by the UI elements)
        //TODO: Make this responsive (currently for the Pro Max models)
        let safeSize = CGSize(width: 430, height: 530)
        
        let horizontalPadding: CGFloat
        if zoomRect.size.isTaller(than: safeSize) {
            horizontalPadding = (zoomRect.size.height * safeSize.widthToHeightRatio) - zoomRect.size.width
        } else {
            horizontalPadding = zoomRect.size.width * (paddedForSingleBox ? 0.6 : 0.1)
        }

        return zoomRect.padHorizontally(by: horizontalPadding, in: frame)
    }
}

