import SwiftUI
import SwiftHaptics

struct TextBoxView: View {
    
    @Binding var textBox: TextBox
    let size: CGSize
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let tapHandler = textBox.tapHandler {
                    button(tapHandler)
                } else {
                    box
                }
                Spacer()
            }
            Spacer()
        }
        .offset(x: rect.minX, y: rect.minY)
    }
    
    var rect: CGRect {
        textBox.boundingBox.rectForSize(size)
    }
    
    func button(_ didTap: @escaping () -> ()) -> some View {
        Button {
//            Haptics.successFeedback()
            didTap()
        } label: {
            box
        }
    }
    
    var box: some View {
        RoundedRectangle(cornerRadius: 3)
            .foregroundColor(textBox.color)
            .opacity(textBox.opacity)
            .frame(width: rect.width,
                   height: rect.height)
        
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(textBox.color, lineWidth: 1)
                    .opacity(0.8)
            )
            .shadow(radius: 3, x: 0, y: 2)
        //            .opacity(isPaging ? 0 : 1)
        //            .animation(.default, value: isPaging)
    }
}
