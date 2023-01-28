////TODO: 🗑
//
//import SwiftUI
//
//struct ImageViewer: View {
//    
//    let id: UUID
//    let image: UIImage
//    let contentMode: ContentMode
//    
//    @Binding var textBoxes: [TextBox]
//    @Binding var scannedTextBoxes: [TextBox]
//    @Binding var zoomBox: ZBox?
//    @Binding var showingBoxes: Bool
//    @Binding var showingCutouts: Bool
//    @Binding var textPickerHasAppeared: Bool
//    
//    @Binding var shimmering: Bool
//    @Binding var isFocused: Bool
//    
//    init(
//        id: UUID = UUID(),
//        image: UIImage,
//        textBoxes: Binding<[TextBox]>? = nil,
//        scannedTextBoxes: Binding<[TextBox]>? = nil,
//        contentMode: ContentMode = .fit,
//        zoomBox: Binding<ZBox?>,
//        showingBoxes: Binding<Bool>? = nil,
//        showingCutouts: Binding<Bool>? = nil,
//        textPickerHasAppeared: Binding<Bool>? = nil,
//        shimmering: Binding<Bool>? = nil,
//        isFocused: Binding<Bool>? = nil
//    ) {
//        self.id = id
//        self.image = image
//        self.contentMode = contentMode
//        
//        _textBoxes = textBoxes ?? .constant([])
//        _scannedTextBoxes = scannedTextBoxes ?? .constant([])
//        _zoomBox = zoomBox
//        _showingBoxes = showingBoxes ?? .constant(true)
//        _showingCutouts = showingCutouts ?? .constant(true)
//        _textPickerHasAppeared = textPickerHasAppeared ?? .constant(true)
//        _shimmering = shimmering ?? .constant(false)
//        _isFocused = isFocused ?? .constant(false)
//    }
//    
//    var body: some View {
//        ZStack {
//            Color(.systemBackground)
//            zoomableScrollView
//        }
////        .edgesIgnoringSafeArea(.all)
//    }
//    
//    
//    var zoomableScrollView: some View {
//        ZoomScrollView {
////        OriginalZScroll {
////        ZScroll {
//            VStack(spacing: 0) {
//                imageView(image)
//                    .overlay(textBoxesLayer)
//                    .overlay(scannedTextBoxesLayer)
//            }
//        }
////        .edgesIgnoringSafeArea(.all)
//    }
//    
//    @ViewBuilder
//    func imageView(_ image: UIImage) -> some View {
//        Image(uiImage: image)
//            .resizable()
//            .aspectRatio(contentMode: contentMode)
//            .background(.black)
//            .opacity((showingBoxes && isFocused) ? 0.7 : 1)
//            .animation(.default, value: showingBoxes)
//    }
//    
//    var textBoxesLayer: some View {
//        var shouldShow: Bool {
//            (textPickerHasAppeared && showingBoxes && scannedTextBoxes.isEmpty)
//        }
//        var opacity: CGFloat {
//            guard shouldShow else { return 0 }
//            if shimmering || isFocused { return 1 }
//            return 0.3
//        }
//        return TextBoxesLayer(
//            textBoxes: $textBoxes,
//            shimmering: $shimmering
//        )
//        .opacity(opacity)
//        .animation(.default, value: textPickerHasAppeared)
//        .animation(.default, value: showingBoxes)
//        .animation(.default, value: shimmering)
//        .animation(.default, value: scannedTextBoxes.count)
//        .shimmering(active: shimmering)
//    }
//    
//    var scannedTextBoxesLayer: some View {
//        var shouldShow: Bool {
//            (textPickerHasAppeared && showingBoxes && showingCutouts)
//        }
//        
//        return TextBoxesLayer(textBoxes: $scannedTextBoxes, isCutOut: true)
//            .opacity(shouldShow ? 1 : 0)
//            .animation(.default, value: textPickerHasAppeared)
//            .animation(.default, value: showingBoxes)
//            .animation(.default, value: showingCutouts)
//        //            .shimmering(active: shimmering)
//    }
//    
//}
