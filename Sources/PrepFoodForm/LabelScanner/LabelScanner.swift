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

    @Binding var animatingCollapse: Bool
    
    let animateCollapse: (() -> ())?
    
    let imageHandler: ((UIImage, ScanResult) -> ())?
    let scanResultHandler: ((ScanResult) -> ())?
    
    let isCamera: Bool
    
    @State var showingBlackBackground = false

    public init(
        mock: (ScanResult, UIImage)? = nil,
        isCamera: Bool = true,
        image: Binding<UIImage?> = .constant(nil),
        animatingCollapse: Binding<Bool>? = nil,
        animateCollapse: (() -> ())? = nil,
        imageHandler: ((UIImage, ScanResult) -> ())? = nil,
        scanResultHandler: ((ScanResult) -> ())? = nil
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
            imageLayer
            imageViewerLayer
            cameraLayer
        }
        .onChange(of: selectedImage) { newValue in
            guard let newValue else { return }
            handleCapturedImage(newValue)
        }
    }
    
    @ViewBuilder
    var cameraLayer: some View {
        if isCamera {
            foodLabelCamera
                .opacity(hideCamera ? 0 : 1)
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
    
    @State var shimmeringImage = false

    @ViewBuilder
    var imageLayer: some View {
        if let selectedImage {
            ZStack {
                ZStack {
                    Color.black
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Color.black
                        .opacity(shimmeringImage ? 0.6 : 0)
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
    
    var textBoxesLayer: some View {
        func textBoxView(_ box: TextBox) -> some View {
            
            var rect: CGRect {
                guard let image else { return .zero }
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
            ForEach(textBoxes.indices, id: \.self) { i in
                textBoxView(textBoxes[i])
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
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
//            .shimmering(active: shimmeringImage)
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
            if isCamera, let image {
                ZStack {
                    imageViewer(image)
//                    Color.clear
//                        .background(.thinMaterial)
//                    Color.black
//                        .opacity(shimmeringImage ? 0.8 : 0)
//                    croppedImagesCutoutLayer
//                        .scaleEffect(animatingCollapseOfCutouts ? 0 : 1)
//                        .opacity(animatingCollapseOfCutouts ? 0 : 1)
//                        .padding(.top, animatingCollapseOfCutouts ? 400 : 0)
//                        .padding(.trailing, animatingCollapseOfCutouts ? 300 : 0)
                    croppedImagesLayer
                        .scaleEffect(animatingCollapseOfCroppedImages ? 0 : 1)
                        .padding(.top, animatingCollapseOfCroppedImages ? 0 : 0)
                        .padding(.trailing, animatingCollapseOfCroppedImages ? 300 : 0)
                }
            }
        }
    }
    
    func getZoomBox(for image: UIImage) -> ZoomBox {
        let boundingBox = isCamera
        ? image.boundingBoxForScreenFill
        : CGRect(x: 0, y: 0, width: 1, height: 1)
        
        return ZoomBox(
            boundingBox: boundingBox,
            animated: false,
            padded: false,
            imageSize: image.size
        )
    }
    
    var foodLabelCamera: some View {
        LabelCamera(mockData: mock, imageHandler: handleCapturedImage)
    }
    
    func handleCapturedImage(_ image: UIImage) {
        withAnimation(.easeInOut(duration: 0.7).repeatForever()) {
            self.image = image
            shimmeringImage = true
        }
        Haptics.successFeedback()
        print("🔵 WE here")
        
        Task(priority: .high) {
//            if !isCamera {
//                try await sleepTask(0.5)
//            }
            try await startScan(image)
        }
    }
    
    func startScan(_ image: UIImage) async throws {
        let zoomBox = getZoomBox(for: image)
//            self.zoomBox = screenFillZoomBox
        Haptics.selectionFeedback()

        try await transitionToImageViewer(with: zoomBox)
        
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
        
        Haptics.selectionFeedback()
        
        await MainActor.run {
            withAnimation {
                shimmeringImage = false
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
        showingBlackBackground = false

        let resultBoxes = scanResult.textBoxes
        
//            await MainActor.run {
//                withAnimation {
//                    self.shimmering = false
//                    self.scannedTextBoxes = resultBoxes
//                }
//            }
        
        let startCut = CFAbsoluteTimeGetCurrent()
        for box in resultBoxes {
            guard let cropped = await image.cropped(boundingBox: box.boundingBox) else {
                print("Couldn't get image for box: \(box)")
                continue
            }
            
            let screen = await UIScreen.main.bounds
            
            let correctedRect: CGRect
            if isCamera {
                let scaledWidth: CGFloat = (image.size.width * screen.height) / image.size.height
                let scaledSize = CGSize(width: scaledWidth, height: screen.height)
                let rectForSize = box.boundingBox.rectForSize(scaledSize)
                
                correctedRect = CGRect(
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
                

            } else {
                
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
                    
                    print("🌱 scaledSize: \(scaledSize)")
                } else {
                    let scaledWidth = (image.size.width * screen.height) / image.size.height
                    let scaledSize = CGSize(width: scaledWidth, height: screen.height)
                    rectForSize = box.boundingBox.rectForSize(scaledSize)
                    x = rectForSize.origin.x + ((screen.width - scaledWidth) / 2.0)
                    y = rectForSize.origin.y
                }

                correctedRect = CGRect(
                    x: x,
                    y: y,
                    width: rectForSize.size.width,
                    height: rectForSize.size.height
                )
                
                print("🌱 rectForSize: \(rectForSize)")
                print("🌱 correctedRect: \(correctedRect), screenHeight: \(screen.height)")

            }
            
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

        Haptics.selectionFeedback()

        await MainActor.run {
            withAnimation {
                showingCroppedImages = true
//                    scannedTextBoxes = []
                self.textBoxes = []
                self.scannedTextBoxes = scanResult.textBoxes
            }
        }
        
        try await sleepTask(0.5, tolerance: 0.01)
        
        let Bounce: Animation = .interactiveSpring(response: 0.35, dampingFraction: 0.66, blendDuration: 0.35)

        await MainActor.run {
            Haptics.feedback(style: .soft)
            withAnimation(Bounce) {
                stackedOnTop = true
            }
        }

        try await sleepTask(0.5, tolerance: 0.01)

        collapse()
//            return textSet.scanResult
        /// Now run texts through FoodLabelScanner
        /// - Have the texts now show a flashing occuring from left to right
        /// - Once received
    }
        
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
        
        var shadow: CGFloat {
            3
//            stackedOnTop ? 3 : 0
        }

        return Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: rect.width, height: rect.height)
            .rotationEffect(angle, anchor: .center)
            .scaleEffect(scale, anchor: .center)
            .position(x: x, y: y)
            .shadow(color: .black.opacity(0.3), radius: shadow, x: 0, y: shadow)
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
