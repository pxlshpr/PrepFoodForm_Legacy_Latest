//TODO: 🗑

import SwiftUI

enum TextBoxType {
    case attribute
    case value
    case undefined
}

struct TextBox {
    let id: UUID
    var boundingBox: CGRect
    var color: Color
    var opacity: CGFloat
    var type: TextBoxType
    var tapHandler: (() -> ())?
    
    init(
        id: UUID = UUID(),
        type: TextBoxType = .undefined,
        boundingBox: CGRect,
        color: Color,
        opacity: CGFloat = 0.3,
        tapHandler: (() -> ())? = nil)
    {
        self.id = id
        self.type = type
        self.boundingBox = boundingBox
        self.color = color
        self.opacity = opacity
        self.tapHandler = tapHandler
    }
}
