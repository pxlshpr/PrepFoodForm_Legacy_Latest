import SwiftUI

struct TextBoxesLayer: View {
    
    @Binding var textBoxes: [TextBox]
    
    var body: some View {
        boxesLayer
    }
    
    var boxesLayer: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(textBoxes.indices, id: \.self) { i in
                    textBoxView(at: i, size: geometry.size)
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
        return TextBoxView(textBox: binding, size: size)
    }
}
