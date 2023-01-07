import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer
import VisionSugar

public struct LabelScanner: View {
    
    @Binding var selectedImage: UIImage?

    //TODO: Remove these after moving to ViewModel

//    @StateObject var viewModel: LabelScannerViewModel
    @ObservedObject var viewModel: LabelScannerViewModel

//    public init(
//        isCamera: Bool = true,
//        image: Binding<UIImage?> = .constant(nil),
//        animatingCollapse: Binding<Bool>? = nil,
//        animateCollapse: (() -> ())? = nil,
//        imageHandler: @escaping (UIImage, ScanResult) -> (),
//        scanResultHandler: @escaping (ScanResult, Int?) -> (),
//        dismissHandler: @escaping () -> ()
//    ) {
//        self.animateCollapse = animateCollapse
//        _selectedImage = image
//        _animatingCollapse = animatingCollapse ?? .constant(false)
//
//
//        let viewModel = LabelScannerViewModel(
//            isCamera: isCamera,
//            animatingCollapse: animatingCollapse?.wrappedValue ?? false,
//            imageHandler: imageHandler,
//            scanResultHandler: scanResultHandler,
//            dismissHandler: dismissHandler
//        )
//        _viewModel = StateObject(wrappedValue: viewModel)
//    }
    
    public init(
        scanner: LabelScannerViewModel,
        image: Binding<UIImage?> = .constant(nil)
    ) {
        _selectedImage = image
        self.viewModel = scanner
    }
    
    public var body: some View {
        ZStack {
//            if viewModel.showingBlackBackground {
//                Color.black
//                    .edgesIgnoringSafeArea(.all)
//            }
//            imageLayer
            imageViewerLayer
            cameraLayer
            columnPickerLayer
        }
        .onChange(of: selectedImage) { newValue in
            guard let newValue else { return }
            handleCapturedImage(newValue)
        }
//        .onChange(of: viewModel.animatingCollapse) { newValue in
//            withAnimation {
//                self.animatingCollapse = newValue
//            }
//        }
        .onChange(of: viewModel.clearSelectedImage) { newValue in
            guard newValue else { return }
            withAnimation {
                self.selectedImage = nil
            }
        }
    }
    
    var columnPickerLayer: some View {
        ColumnPickerOverlay(
            isVisibleBinding: $viewModel.showingColumnPickerUI,
            selectedColumn: viewModel.selectedColumnBinding,
            didTapDismiss: viewModel.dismissHandler,
            didTapAutofill: { viewModel.columnSelectionHandler() }
        )
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
//                    Color.black
//                        .opacity(shimmeringImage ? 0.6 : 0)
                }
                .scaleEffect(viewModel.animatingCollapse ? 0 : 1)
                .padding(.top, viewModel.animatingCollapse ? 400 : 0)
                .padding(.trailing, viewModel.animatingCollapse ? 300 : 0)
                textBoxesLayer
                croppedImagesCutoutLayer
                    .scaleEffect(viewModel.animatingCollapseOfCutouts ? 0 : 1)
                    .opacity(viewModel.animatingCollapseOfCutouts ? 0 : 1)
                    .padding(.top, viewModel.animatingCollapseOfCutouts ? 400 : 0)
                    .padding(.trailing, viewModel.animatingCollapseOfCutouts ? 300 : 0)
                croppedImagesLayer
                    .scaleEffect(viewModel.animatingCollapseOfCroppedImages ? 0 : 1)
                    .padding(.top, viewModel.animatingCollapseOfCroppedImages ? 0 : 0)
                    .padding(.trailing, viewModel.animatingCollapseOfCroppedImages ? 300 : 0)
            }
            .edgesIgnoringSafeArea(.all)
//            .transition(.move(edge: .bottom))
            .transition(.opacity)
        }
    }
}

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
