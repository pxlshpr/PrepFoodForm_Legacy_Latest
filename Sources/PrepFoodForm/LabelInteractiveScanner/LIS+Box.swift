import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer

extension LabelInteractiveScanner {

    var textBoxesLayer: some View {
        func textBoxView(_ box: TextBox) -> some View {
            
            var rect: CGRect {
                guard let image = viewModel.image else { return .zero }
                let screen = UIScreen.main.bounds
                let rectForSize: CGRect
                let x: CGFloat
                let y: CGFloat
                
                if image.size.widthToHeightRatio > screen.size.widthToHeightRatio {
                    /// This means we have empty strips at the top, and image gets width set to screen width
                    let scaledHeight = (image.size.height * screen.width) / image.size.width
                    let scaledSize = CGSize(width: screen.width, height: scaledHeight)
                    rectForSize = box.boundingBox.rectForSize(scaledSize)
                    x = rectForSize.origin.x
                    y = rectForSize.origin.y + ((screen.height - scaledHeight) / 2.0)
                } else {
                    let scaledWidth = (image.size.width * screen.height) / image.size.height
                    let scaledSize = CGSize(width: scaledWidth, height: screen.height)
                    rectForSize = box.boundingBox.rectForSize(scaledSize)
                    x = rectForSize.origin.x + ((screen.width - scaledWidth) / 2.0)
                    y = rectForSize.origin.y
                }

                return CGRect(x: x, y: y, width: rectForSize.size.width, height: rectForSize.size.height)
            }
            
            return RoundedRectangle(cornerRadius: 3)
                .foregroundColor(box.color)
                .opacity(box.opacity)
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 3)
//                        .stroke(box.color, lineWidth: 1)
//                        .opacity(0.8)
//                )
                .shimmering()
        }
        
        return ZStack {
            Color.clear
            ForEach(viewModel.textBoxes.indices, id: \.self) { i in
                textBoxView(viewModel.textBoxes[i])
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
}
