import SwiftUI
import ZoomableScrollView

struct ImageViewer: View {
    
    let id: UUID
    let image: UIImage
    let textBoxes: [TextBox]
    let contentMode: ContentMode
    
    @Binding var zoomBox: ZoomBox?
    @Binding var showingBoxes: Bool
    @Binding var textPickerHasAppeared: Bool

    init(
        id: UUID = UUID(),
        image: UIImage,
        textBoxes: [TextBox] = [],
        contentMode: ContentMode = .fit,
        zoomBox: Binding<ZoomBox?>? = nil,
        showingBoxes: Binding<Bool>? = nil,
        textPickerHasAppeared: Binding<Bool>? = nil
    ) {
        self.id = id
        self.image = image
        self.textBoxes = textBoxes
        self.contentMode = contentMode
        
        _zoomBox = zoomBox ?? .constant(nil)
        _showingBoxes = showingBoxes ?? .constant(true)
        _textPickerHasAppeared = textPickerHasAppeared ?? .constant(true)
    }
    
    var body: some View {
        zoomableScrollView
            .background(.black)
    }
    
    
    var zoomableScrollView: some View {
        ZoomableScrollView(
            id: id,
            zoomBox: $zoomBox,
            backgroundColor: .black
        ) {
            imageView(image)
//                .overlay(textBoxesLayer)
        }
    }
    
    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .edgesIgnoringSafeArea(.all)
//            .aspectRatio(contentMode: .fit)
//            .scaledToFit()
            .background(.black)
//            .opacity(showingBoxes ? 0.7 : 1)
            .animation(.default, value: showingBoxes)
    }
    
    var textBoxesLayer: some View {
        TextBoxesLayer(textBoxes: textBoxes)
            .opacity((textPickerHasAppeared && showingBoxes) ? 1 : 0)
            .animation(.default, value: textPickerHasAppeared)
            .animation(.default, value: showingBoxes)
    }
}
