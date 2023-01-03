import SwiftUI
import ZoomableScrollView

//extension ZoomBox: Hashable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(boundingBox)
//        hasher.combine(padded)
//        hasher.combine(animated)
//        hasher.combine(imageSize)
//        hasher.combine(imageId)
//    }
//}
//
//extension ZoomBox: Equatable {
//    static func ==(lhs: ZoomBox, rhs: ZoomBox) -> Bool {
//        lhs.hashValue == rhs.hashValue
//    }
//}

struct ImageViewer: View {
    
    let id: UUID
    let image: UIImage
    let contentMode: ContentMode
    
    @Binding var textBoxes: [TextBox]
    @Binding var zoomBox: ZoomBox?
    @Binding var showingBoxes: Bool
    @Binding var textPickerHasAppeared: Bool

    init(
        id: UUID = UUID(),
        image: UIImage,
        textBoxes: Binding<[TextBox]>? = nil,
        contentMode: ContentMode = .fit,
        zoomBox: Binding<ZoomBox?>,
        showingBoxes: Binding<Bool>? = nil,
        textPickerHasAppeared: Binding<Bool>? = nil
    ) {
        self.id = id
        self.image = image
        self.contentMode = contentMode

        _textBoxes = textBoxes ?? .constant([])
        _zoomBox = zoomBox
        _showingBoxes = showingBoxes ?? .constant(true)
        _textPickerHasAppeared = textPickerHasAppeared ?? .constant(true)
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
            zoomBox: $zoomBox,
            backgroundColor: .black
        ) {
            imageView(image)
                .overlay(textBoxesLayer)
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
