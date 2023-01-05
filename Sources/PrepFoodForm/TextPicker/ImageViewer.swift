import SwiftUI
import ZoomableScrollView

struct ImageViewer: View {
    
    let id: UUID
    let image: UIImage
    let contentMode: ContentMode
    
    @Binding var textBoxes: [TextBox]
    @Binding var scannedTextBoxes: [TextBox]
    @Binding var zoomBox: ZoomBox?
    @Binding var showingBoxes: Bool
    @Binding var textPickerHasAppeared: Bool
    
    @Binding var shimmering: Bool

    init(
        id: UUID = UUID(),
        image: UIImage,
        textBoxes: Binding<[TextBox]>? = nil,
        scannedTextBoxes: Binding<[TextBox]>? = nil,
        contentMode: ContentMode = .fit,
        zoomBox: Binding<ZoomBox?>,
        showingBoxes: Binding<Bool>? = nil,
        textPickerHasAppeared: Binding<Bool>? = nil,
        shimmering: Binding<Bool>? = nil
    ) {
        self.id = id
        self.image = image
        self.contentMode = contentMode

        _textBoxes = textBoxes ?? .constant([])
        _scannedTextBoxes = scannedTextBoxes ?? .constant([])
        _zoomBox = zoomBox
        _showingBoxes = showingBoxes ?? .constant(true)
        _textPickerHasAppeared = textPickerHasAppeared ?? .constant(true)
        _shimmering = shimmering ?? .constant(false)
    }
    
    var body: some View {
        zoomableScrollView
            .background(.black)
//            .onChange(of: zoomBox) { newValue in
//                print("Zoombox changed")
//            }
    }
    
    
    var zoomableScrollView: some View {
        ZoomableScrollView(
            id: id,
//            zoomBox: $zoomBox,
            backgroundColor: .black
        ) {
            imageView(image)
                .overlay(textBoxesLayer)
                .overlay(scannedTextBoxesLayer)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .background(.black)
//            .opacity(showingBoxes ? 0.7 : 1)
            .animation(.default, value: showingBoxes)
    }
    
    var textBoxesLayer: some View {
        var shouldShow: Bool {
            (textPickerHasAppeared && showingBoxes && scannedTextBoxes.isEmpty)
        }
        return TextBoxesLayer(textBoxes: $textBoxes)
            .opacity(shouldShow ? 1 : 0)
            .animation(.default, value: textPickerHasAppeared)
            .animation(.default, value: showingBoxes)
            .animation(.default, value: scannedTextBoxes.count)
            .shimmering(active: shimmering)
    }
    
    var scannedTextBoxesLayer: some View {
        TextBoxesLayer(textBoxes: $scannedTextBoxes, isCutOut: true)
            .opacity((textPickerHasAppeared && showingBoxes) ? 1 : 0)
            .animation(.default, value: textPickerHasAppeared)
            .animation(.default, value: showingBoxes)
//            .shimmering(active: shimmering)
    }

}
