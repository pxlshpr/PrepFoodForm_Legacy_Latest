import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer

extension LabelInteractiveScanner {
    
    @ViewBuilder
    var croppedImagesCutoutLayer: some View {
        if viewModel.showingCroppedImages {
            ZStack {
                Color.clear
                ForEach(viewModel.images.indices, id: \.self) { i in
                    croppedImageCutout(rect: viewModel.images[i].1)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .transition(.opacity)
        }
    }
    
    func croppedImageCutout(rect: CGRect) -> some View {
        var r: CGFloat {
            1
        }
        return Rectangle()
            .fill(
                .shadow(.inner(color: Color(red: 197/255, green: 197/255, blue: 197/255),radius: r, x: r, y: r))
                .shadow(.inner(color: .white, radius: r, x: -r, y: -r))
            )
            .foregroundColor(Color(red: 236/255, green: 234/255, blue: 235/255))
//            .fill(.shadow(.inner(radius: 1, y: 1)))
//            .foregroundColor(.black)
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
    }
}
