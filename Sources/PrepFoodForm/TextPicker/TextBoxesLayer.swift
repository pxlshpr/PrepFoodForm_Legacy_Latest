import SwiftUI

struct TextBoxesLayer: View {
    
    @Binding var textBoxes: [TextBox]
    @Binding var shimmering: Bool
    
    //TODO: Replace this with style
    let isCutOut: Bool
    
    init(textBoxes: Binding<[TextBox]>, shimmering: Binding<Bool> = .constant(false), isCutOut: Bool = false) {
        _textBoxes = textBoxes
        _shimmering = shimmering
        self.isCutOut = isCutOut
    }
    
    var body: some View {
        boxesLayer
    }
    
    var boxesLayer: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(textBoxes.indices, id: \.self) { i in
                    if isCutOut {
                        cutoutView(at: i, size: geometry.size)
                    } else {
                        textBoxView(at: i, size: geometry.size)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    func textBoxView(at index: Int, size: CGSize) -> some View {
        let binding = Binding<TextBox>(
            get: { textBoxes[index] },
            set: { _ in }
        )
        return TextBoxView(
            textBox: binding,
            size: size,
            shimmering: $shimmering
        )
    }
    
    func cutoutView(at index: Int, size: CGSize) -> some View {
        let rect = textBoxes[index].boundingBox.rectForSize(size)
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

}
