import SwiftUI

struct TextBox {
    let id: UUID
    var boundingBox: CGRect
    var color: Color
    var opacity: CGFloat
    var tapHandler: (() -> ())?
    
    init(
        id: UUID = UUID(),
        boundingBox: CGRect,
        color: Color,
        opacity: CGFloat = 0.3,
        tapHandler: (() -> ())? = nil)
    {
        self.id = id
        self.boundingBox = boundingBox
        self.color = color
        self.opacity = opacity
        self.tapHandler = tapHandler
    }
}
