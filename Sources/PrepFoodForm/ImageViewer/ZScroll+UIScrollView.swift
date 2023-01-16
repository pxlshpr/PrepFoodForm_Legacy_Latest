import SwiftUI
import UIKit
import VisionSugar
import SwiftUISugar

extension UIScrollView {

    func zoomToScale(_ newZoomScale: CGFloat, on point: CGPoint) {
        let scaleChange = newZoomScale / zoomScale
        let rect = zoomRect(forFactorChangeInZoomScaleOf: scaleChange, on: point)
        zoom(to: rect, animated: true)
    }

    func zoomRect(forFactorChangeInZoomScaleOf factor: CGFloat, on point: CGPoint) -> CGRect {
        let size = CGSize(width: frame.size.width / factor,
                          height: frame.size.height / factor)
        let zoomSize = CGSize(width: size.width / zoomScale,
                              height: size.height / zoomScale)

        let origin = CGPoint(x: point.x - (zoomSize.width / factor),
                             y: point.y - (zoomSize.height / factor))
        return CGRect(origin: origin, size: zoomSize)
    }
    
    func zoom(onTo zoomBox: ZBox, animated: Bool = true) {
        zoomIn(
            boundingBox: zoomBox.boundingBox,
            padded: zoomBox.padded,
            imageSize: zoomBox.imageSize,
            animated: zoomBox.animated
        )
    }

    func zoomIn(boundingBox: CGRect, padded: Bool, imageSize: CGSize, animated: Bool = true) {

        let zoomRect = boundingBox.zoomRect(forImageSize: imageSize, fittedInto: frame.size, padded: padded)
//        var zoomRect = boundingBox.rectForSize(imageSize, fittedInto: frame.size)
//        if padded {
//            let ratio = min(frame.size.width / (zoomRect.size.width * 5), 3.5)
//            zoomRect.pad(within: frame.size, ratio: ratio)
//        }

        print("🔍 zoomIn on: \(zoomRect) within \(frame.size)")
        let zoomScaleX = frame.size.width / zoomRect.width
        print("🔍 zoomScaleX is \(zoomScaleX)")
        let zoomScaleY = frame.size.height / zoomRect.height
        print("🔍 zoomScaleY is \(zoomScaleY)")
        print("🔍 🤖 calculated zoomScale is: \(zoomRect.zoomScale(within: frame.size))")

        zoom(to: zoomRect, animated: animated)
    }
}
