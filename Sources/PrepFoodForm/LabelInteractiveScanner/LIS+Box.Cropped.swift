import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer

extension LabelInteractiveScanner {
    
    @ViewBuilder
    var croppedImagesLayer: some View {
        if viewModel.showingCroppedImages {
            ZStack {
                Color.clear
//                Color.blue.opacity(0.3)
                ForEach(viewModel.images.indices, id: \.self) { i in
                    croppedImage(
                        viewModel.images[i].0,
                        rect: viewModel.images[i].1,
                        stackedAngle: viewModel.images[i].3,
                        wiggleAngles: viewModel.images[i].4
                    )
                }
            }
            .edgesIgnoringSafeArea(.all)
            .transition(.opacity)
        }
    }
    
    func croppedImage(
        _ image: UIImage,
        rect: CGRect,
        stackedAngle: Angle,
        wiggleAngles: (Angle, Angle, Angle, Angle)
    ) -> some View {
        var x: CGFloat {
            viewModel.stackedOnTop ? UIScreen.main.bounds.midX : rect.midX
        }
        
        var y: CGFloat {
            viewModel.stackedOnTop ? 150 : rect.midY
        }
        
        var angle: Angle {
            if viewModel.stackedOnTop {
                return stackedAngle
            } else if viewModel.animatingFirstWiggleOfCroppedImages {
                return wiggleAngles.0
            } else if viewModel.animatingSecondWiggleOfCroppedImages {
                return wiggleAngles.1
            } else if viewModel.animatingThirdWiggleOfCroppedImages {
                return wiggleAngles.2
            } else if viewModel.animatingFourthWiggleOfCroppedImages {
                return wiggleAngles.3
            } else {
                return .degrees(0)
            }
        }

        var scale: CGFloat {
            if viewModel.stackedOnTop {
                return 2
            } else if viewModel.animatingFirstWiggleOfCroppedImages {
                return 1.1
            } else if viewModel.animatingSecondWiggleOfCroppedImages {
                return 1.15
            } else if viewModel.animatingThirdWiggleOfCroppedImages {
                return 1.2
            } else if viewModel.animatingFourthWiggleOfCroppedImages {
                return 1.25
            } else if viewModel.animatingLiftingUpOfCroppedImages {
                return 1.05
            } else {
                return 1.0
//                return 1.03
            }
        }
        
        var shadow: CGFloat {
            if viewModel.stackedOnTop {
                return 3
            } else if viewModel.animatingFirstWiggleOfCroppedImages {
                return 7
            } else if viewModel.animatingSecondWiggleOfCroppedImages {
                return 8
            } else if viewModel.animatingThirdWiggleOfCroppedImages {
                return 9
            } else if viewModel.animatingFourthWiggleOfCroppedImages {
                return 10
            } else if viewModel.animatingLiftingUpOfCroppedImages {
                return 6
            } else {
                return 5
            }
        }

        return Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: rect.width, height: rect.height)
            .rotationEffect(angle, anchor: .center)
            .scaleEffect(scale, anchor: .center)
            .position(x: x, y: y)
            .shadow(radius: shadow, x: 0, y: shadow)
    }
}
