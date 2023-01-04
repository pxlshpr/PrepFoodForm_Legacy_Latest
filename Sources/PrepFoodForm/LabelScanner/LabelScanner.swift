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
    
    @State var showingImageViewer = false
    
    @Binding var animatingCollapse: Bool
    
    let animateCollapse: (() -> ())?
    
    let imageHandler: ((UIImage, ScanResult) -> ())?
    let scanResultHandler: ((ScanResult) -> ())?
    
    public init(
        mock: (ScanResult, UIImage)? = nil,
        animatingCollapse: Binding<Bool>? = nil,
        animateCollapse: (() -> ())? = nil,
        imageHandler: ((UIImage, ScanResult) -> ())? = nil,
        scanResultHandler: ((ScanResult) -> ())? = nil
    ) {
        self.mock = mock
        self.animateCollapse = animateCollapse
        self.imageHandler = imageHandler
        self.scanResultHandler = scanResultHandler
        _animatingCollapse = animatingCollapse ?? .constant(false)
    }
    
    @State var hideCamera: Bool = false
    
    public var body: some View {
        ZStack {
            imageViewerLayer
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
            get: { textBoxes },
            set: { _ in }
        )
    }

    @State var showingBoxes = false
//    var zoomBoxBinding: Binding<ZoomBox?> {
//        Binding<ZoomBox?>(
//            get: {
//            },
//            set: { _ in }
//        )
//    }
    
    @State var zoomBox: ZoomBox? = nil
    @State var isLoadingImageViewer = false
    
    var imageViewerLayer: some View {
        
        func imageViewer(_ image: UIImage) -> some View {
            ImageViewer(
                id: UUID(),
                image: image,
                textBoxes: $textBoxes,
                scannedTextBoxes: $scannedTextBoxes,
                contentMode: .fit,
                zoomBox: $zoomBox,
                showingBoxes: $showingBoxes,
                shimmering: $shimmering
            )
            .edgesIgnoringSafeArea(.all)
            .background(.black)
//            .shimmering(active: isLoadingImageViewer)
            .scaleEffect(animatingCollapse ? 0 : 1)
            .padding(.top, animatingCollapse ? 400 : 0)
            .padding(.trailing, animatingCollapse ? 300 : 0)
//            .task {
//                try? await sleepTask(0.1, tolerance: 0.001)
//                await MainActor.run {
//                    withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
//                        isLoadingImageViewer = true
//                    }
//                }
//            }
        }
        
        return Group {
            if let image {
                ZStack {
                    imageViewer(image)
//                    Color.clear
//                        .background(.thinMaterial)
//                        .opacity(isLoadingImageViewer ? 0.6 : 0)
                    croppedImagesCutoutLayer
                        .scaleEffect(animatingCollapseOfCutouts ? 0 : 1)
                        .padding(.top, animatingCollapseOfCutouts ? 400 : 0)
                        .padding(.trailing, animatingCollapseOfCutouts ? 300 : 0)
                    croppedImagesLayer
                        .scaleEffect(animatingCollapseOfCroppedImages ? 0 : 1)
                        .padding(.top, animatingCollapseOfCroppedImages ? 0 : 0)
                        .padding(.trailing, animatingCollapseOfCroppedImages ? 300 : 0)
                }
            }
        }
    }
    
    @State var animatingCollapseOfCutouts = false
    @State var animatingCollapseOfCroppedImages = false

    @State var showingCroppedImages = false
    
    func getScreenFillZoomBox(for image: UIImage) -> ZoomBox {
        ZoomBox(
            boundingBox: image.boundingBoxForScreenFill,
            animated: false,
            padded: false,
            imageSize: image.size
        )
    }
    
    var foodLabelCamera: some View {
        LabelCamera(mockData: mock, imageHandler: handleCapturedImage)
    }
    
    @State var textBoxes: [TextBox] = []
    @State var scannedTextBoxes: [TextBox] = []
    @State var shimmering = true
    
    func handleCapturedImage(_ image: UIImage) {
        self.image = image
        Haptics.successFeedback()
        
        Task(priority: .high) {
            let screenFillZoomBox = getScreenFillZoomBox(for: image)
//            self.zoomBox = screenFillZoomBox
            try await transitionToImageViewer(with: screenFillZoomBox)
            
            /// Now capture recognized texts
            /// - captures all the RecognizedTexts
            let textSet = try await image.recognizedTextSet(for: .accurate, includeBarcodes: true)
            let textBoxes = textSet.texts.map {
                TextBox(
                    id: $0.id,
                    boundingBox: $0.boundingBox,
                    color: .accentColor,
                    opacity: 0.8,
                    tapHandler: {}
                )
            }
            await MainActor.run {
                withAnimation {
                    self.textBoxes = textBoxes
                    showingBoxes = true
//                    isLoadingImageViewer = false
                }
            }
            
            /// - Sets them in a state variable
            /// - Have the loading animation stop and the texts appear
            let start = CFAbsoluteTimeGetCurrent()
            let scanResult = textSet.scanResult
            
            self.scanResult = scanResult
            
            let resultBoxes = scanResult.textBoxes
            
            await MainActor.run {
                withAnimation {
                    self.shimmering = false
                    self.scannedTextBoxes = resultBoxes
                }
            }
            
            let startCut = CFAbsoluteTimeGetCurrent()
            for box in resultBoxes {
                guard let cropped = await image.cropped(boundingBox: box.boundingBox) else {
                    print("Couldn't get image for box: \(box)")
                    continue
                }
                
                let screen = await UIScreen.main.bounds
                let scaledWidth: CGFloat = (image.size.width * screen.height) / image.size.height
                let scaledSize = CGSize(width: scaledWidth, height: screen.height)

                let rectForSize = box.boundingBox.rectForSize(scaledSize)
                let correctedRect = CGRect(
                    x: rectForSize.origin.x - ((scaledWidth - screen.width) / 2.0),
                    y: rectForSize.origin.y,
                    width: rectForSize.size.width,
                    height: rectForSize.size.height
                )
                
                print("🌱 box.boundingBox: \(box.boundingBox)")
                print("🌱 scaledSize: \(scaledSize)")
                print("🌱 rectForSize: \(rectForSize)")
                print("🌱 correctedRect: \(correctedRect)")
                print("🌱 image.boundingBoxForScreenFill: \(image.boundingBoxForScreenFill)")
                
                if !self.images.contains(where: { $0.2 == box.id }) {
                    self.images.append((
                        cropped,
                        correctedRect,
                        box.id,
                        Angle.degrees(CGFloat.random(in: -20...20)))
                    )
                }
            }
            print("Took: \(CFAbsoluteTimeGetCurrent()-startCut)s, have \(images.count) images")

            
            await MainActor.run {
                withAnimation {
                    showingCroppedImages = true
                    scannedTextBoxes = []
                    self.textBoxes = []
                }
            }
            
            try await sleepTask(0.5, tolerance: 0.01)
            
            let Bounce: Animation = .interactiveSpring(response: 0.35, dampingFraction: 0.66, blendDuration: 0.35)

            await MainActor.run {
                withAnimation(Bounce) {
                    stackedOnTop = true
                }
            }

            try await sleepTask(1.0, tolerance: 0.01)

            collapse()
//            return textSet.scanResult
            /// Now run texts through FoodLabelScanner
            /// - Have the texts now show a flashing occuring from left to right
            /// - Once received
        }
    }
    
    @State var images: [(UIImage, CGRect, UUID, Angle)] = []
    
    @ViewBuilder
    var croppedImagesCutoutLayer: some View {
        if showingCroppedImages {
            ZStack {
                Color.clear
                ForEach(images.indices, id: \.self) { i in
                    croppedImageCutout(rect: images[i].1)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .transition(.opacity)
        }
    }

    @ViewBuilder
    var croppedImagesLayer: some View {
        if showingCroppedImages {
            ZStack {
                Color.clear
//                Color.blue.opacity(0.3)
                ForEach(images.indices, id: \.self) { i in
                    croppedImage(images[i].0, rect: images[i].1, randomAngle: images[i].3)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .transition(.opacity)
        }
    }
    
    @State var stackedOnTop: Bool = false
    
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
    
    func croppedImage(_ image: UIImage, rect: CGRect, randomAngle: Angle) -> some View {
        var x: CGFloat {
            stackedOnTop ? UIScreen.main.bounds.midX : rect.midX
        }
        
        var y: CGFloat {
            stackedOnTop ? 150 : rect.midY
        }
        
        var angle: Angle {
            stackedOnTop ? randomAngle : .degrees(0)
        }

        var scale: CGFloat {
            stackedOnTop ? 2.0 : 1.0
        }

        return Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: rect.width, height: rect.height)
            .rotationEffect(angle, anchor: .center)
            .scaleEffect(scale, anchor: .center)
            .position(x: x, y: y)
            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
    }
    
    func transitionToImageViewer(with screenFillZoomBox: ZoomBox) async throws {
        
        /// This delay is necessary to ensure that the zoom actually occurs and give the seamless transition from
        /// that the capture layer of `LabelCamera` to the `ImageViewer`
        try await sleepTask(0.03, tolerance: 0.005)
        
        await MainActor.run {
            /// Zoom to ensure that the `ImageViewer` matches the camera preview layer
            let userInfo = [Notification.ZoomableScrollViewKeys.zoomBox: screenFillZoomBox]
            NotificationCenter.default.post(name: .zoomZoomableScrollView, object: nil, userInfo: userInfo)
            
            withAnimation {
                hideCamera = true
            }
        }
        
    }
    
    func collapse() {
        Task(priority: .high) {
            await MainActor.run {
                withAnimation {
                    self.animatingCollapse = true
                    self.animatingCollapseOfCutouts = true
                    imageHandler?(image!, scanResult!)
                }
            }
            
            try await sleepTask(0.5, tolerance: 0.01)
            
            await MainActor.run {
                withAnimation {
                    self.animatingCollapseOfCroppedImages = true
                }
            }

            try await sleepTask(0.2, tolerance: 0.01)

            await MainActor.run {
                withAnimation {
                    scanResultHandler?(scanResult!)
                }
            }

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
                color: .green,
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
