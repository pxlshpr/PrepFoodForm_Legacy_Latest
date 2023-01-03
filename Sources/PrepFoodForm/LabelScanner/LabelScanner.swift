import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView

public struct LabelScanner: View {
    
    enum Route: Hashable {
        case foodForm
    }
    
    let mock: (ScanResult, UIImage)?
    
    @State var startTransition: Bool = false
    @State var endTransition: Bool = false
    @State var path: [Route] = []
    
    @State var scanResult: ScanResult? = nil
    @State var image: UIImage? = nil
    
    @State var showingImageViewer = false
    
    @Binding var animatingCollapse: Bool
    
    let animateCollapse: (() -> ())?
    
    public init(
        mock: (ScanResult, UIImage)? = nil,
        animatingCollapse: Binding<Bool>? = nil,
        animateCollapse: (() -> ())? = nil
    ) {
        self.mock = mock
        self.animateCollapse = animateCollapse
        _animatingCollapse = animatingCollapse ?? .constant(false)
    }
    
    @State var hideCamera: Bool = false
    
    public var body: some View {
        ZStack {
            imageViewer
            foodLabelCamera
                .opacity(hideCamera ? 0 : 1)
//            if showingImageViewer {
//            } else {
//            }
        }
    }
    
    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .foodForm:
            Color.blue
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    var textBoxesBinding: Binding<[TextBox]>? {
        Binding<[TextBox]>(
            get: {
                scanResult?.textBoxes ?? []
            },
            set: { _ in }
        )
    }

//    var zoomBoxBinding: Binding<ZoomBox?> {
//        Binding<ZoomBox?>(
//            get: {
//            },
//            set: { _ in }
//        )
//    }
    
    @State var zoomBox: ZoomBox? = nil

    @ViewBuilder
    var imageViewer: some View {
        if let image, let scanResultId = scanResult?.id {
            HStack {
                ImageViewer(
                    id: scanResultId,
                    image: image,
                    textBoxes: textBoxesBinding,
                    contentMode: .fit,
                    zoomBox: $zoomBox
                )
                .edgesIgnoringSafeArea(.all)
                .background(.black)
                .scaleEffect(animatingCollapse ? 0 : 1)
                .padding(.top, animatingCollapse ? 400 : 0)
                .padding(.trailing, animatingCollapse ? 300 : 0)
//                Color.clear
//                    .frame(width: animatingCollapse ? 400 : 0)
            }
        }
    }
    
    func getZoomBox() -> ZoomBox? {
        guard let image,
              let scanResult
        else { return nil }
        print("getting zoomBox() with id: \(scanResult.id)")
        return ZoomBox(
            boundingBox: image.boundingBoxForScreenFill,
            animated: false,
            padded: false,
            imageSize: image.size,
            imageId: scanResult.id
        )
    }
    
    var foodLabelCamera: some View {
        FoodLabelCamera(mockData: mock) { scanResult, image in
            self.image = image
            self.scanResult = scanResult
            
            Haptics.successFeedback()
            
//            withAnimation {
//                showingImageViewer = true
//            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                
                self.zoomBox = getZoomBox()
                print("Zoom box is: \(image.boundingBoxForScreenFill)")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    let userInfo = [Notification.ZoomableScrollViewKeys.zoomBox: zoomBox!]
                    NotificationCenter.default.post(name: .zoomZoomableScrollView, object: nil, userInfo: userInfo)
                    
                    withAnimation {
                        hideCamera = true
                    }
                }

                
//                withAnimation {
//                    self.animatingCollapse = true
//                }
//                self.animateCollapse?()
            }
            
//            path.append(.foodForm)
        }
    }
}

extension ScanResult {
    
    var textBoxes: [TextBox] {
        
        var textBoxes: [TextBox] = []
        textBoxes = texts.map {
            TextBox(
                boundingBox: $0.boundingBox,
                color: .blue,
                tapHandler: {}
            )
        }
        
//        textBoxes.append(
//            contentsOf: barcodes(for: imageViewModel).map {
//                TextBox(boundingBox: $0.boundingBox,
//                        color: color(for: $0),
//                        tapHandler: tapHandler(for: $0)
//                )
//        })
        return textBoxes
    }
    
}

extension UIImage {
    var boundingBoxForScreenFill: CGRect {
        
        
        let screen = UIScreen.main.bounds
        
        let scaledWidth: CGFloat = (size.width * screen.height) / size.height

        let x: CGFloat = ((scaledWidth - screen.width) / 2.0)
        let h: CGFloat = size.height
        
        let rect = CGRect(
            x: x / scaledWidth,
            y: 0,
            width: (screen.width / scaledWidth),
            height: h / size.height
        )

        print("🧮 scaledWidth: \(scaledWidth)")
        print("🧮 screen: \(screen)")
        print("🧮 imageSize: \(size)")
        print("🧮 rect: \(rect)")
        return rect
    }
}
