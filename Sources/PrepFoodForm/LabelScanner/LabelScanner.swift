import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer

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
    @Binding var selectedImage: UIImage?
    @State var showingImageViewer = false
    @State var hideCamera: Bool
    @State var showingBoxes = false
    @State var zoomBox: ZoomBox? = nil
    @State var isLoadingImageViewer = false
    @State var animatingCollapseOfCutouts = false
    @State var animatingCollapseOfCroppedImages = false
    @State var showingCroppedImages = false
    @State var textBoxes: [TextBox] = []
    @State var scannedTextBoxes: [TextBox] = []
    @State var shimmering = true
    @State var images: [(UIImage, CGRect, UUID, Angle)] = []
    @State var stackedOnTop: Bool = false
    @State var shimmeringImage = false

    @Binding var animatingCollapse: Bool
    
    let animateCollapse: (() -> ())?
    
    let imageHandler: (UIImage, ScanResult) -> ()
    let scanResultHandler: (ScanResult) -> ()
    
    let isCamera: Bool
    
    @State var showingBlackBackground = false

    public init(
        mock: (ScanResult, UIImage)? = nil,
        isCamera: Bool = true,
        image: Binding<UIImage?> = .constant(nil),
        animatingCollapse: Binding<Bool>? = nil,
        animateCollapse: (() -> ())? = nil,
        imageHandler: @escaping (UIImage, ScanResult) -> (),
        scanResultHandler: @escaping (ScanResult) -> ()
    ) {
        self.isCamera = isCamera
        
        self.mock = mock
        self.animateCollapse = animateCollapse
        self.imageHandler = imageHandler
        self.scanResultHandler = scanResultHandler
        
        _selectedImage = image
        _hideCamera = State(initialValue: !isCamera)
        _animatingCollapse = animatingCollapse ?? .constant(false)
        
        _showingBlackBackground = State(initialValue: !isCamera)
    }
    
    public var body: some View {
        ZStack {
            if showingBlackBackground {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
//            imageLayer
            imageViewerLayer
            cameraLayer
        }
        .onChange(of: selectedImage) { newValue in
            guard let newValue else { return }
            handleCapturedImage(newValue)
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

    @ViewBuilder
    var imageLayer: some View {
        if let selectedImage {
            ZStack {
                ZStack {
                    Color.black

                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .opacity(shimmeringImage ? 0.4 : 1)
//                    Color.black
//                        .opacity(shimmeringImage ? 0.6 : 0)
                }
                .scaleEffect(animatingCollapse ? 0 : 1)
                .padding(.top, animatingCollapse ? 400 : 0)
                .padding(.trailing, animatingCollapse ? 300 : 0)
                textBoxesLayer
                croppedImagesCutoutLayer
                    .scaleEffect(animatingCollapseOfCutouts ? 0 : 1)
                    .opacity(animatingCollapseOfCutouts ? 0 : 1)
                    .padding(.top, animatingCollapseOfCutouts ? 400 : 0)
                    .padding(.trailing, animatingCollapseOfCutouts ? 300 : 0)
                croppedImagesLayer
                    .scaleEffect(animatingCollapseOfCroppedImages ? 0 : 1)
                    .padding(.top, animatingCollapseOfCroppedImages ? 0 : 0)
                    .padding(.trailing, animatingCollapseOfCroppedImages ? 300 : 0)
            }
            .edgesIgnoringSafeArea(.all)
//            .transition(.move(edge: .bottom))
            .transition(.opacity)
        }
    }
}

import VisionSugar

extension ScanResult {

    var relevantTexts: [RecognizedText] {
        let texts = nutrientValueTexts + resultTexts
        return texts.removingDuplicates()
    }

    var textBoxes: [TextBox] {
        
        var textBoxes: [TextBox] = []
        textBoxes = allTexts.map {
            TextBox(
                id: $0.id,
                boundingBox: $0.boundingBox,
                color: .accentColor,
                opacity: 0.8,
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
    
    //TODO: Make this work for images that are TALLER than the screen width
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

struct PreviewView: PreviewProvider {
    static let r: CGFloat = 1
    static var previews: some View {
        Rectangle()
            .fill(
//                .shadow(.inner(color: Color(red: 197/255, green: 197/255, blue: 197/255),radius: r, x: r, y: r))
//                .shadow(.inner(color: .white, radius: r, x: -r, y: -r))
                .shadow(.inner(color: Color(red: 197/255, green: 197/255, blue: 197/255),radius: r, x: r, y: r))
                .shadow(.inner(color: .white, radius: r, x: -r, y: -r))
            )
//            .foregroundColor(Color(red: 236/255, green: 234/255, blue: 235/255))
            .foregroundColor(Color(hex: "2A2A2C"))
            .frame(width: 100, height: 100)
    }
}
