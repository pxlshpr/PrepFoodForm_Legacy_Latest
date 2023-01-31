import UIKit

struct K {
    
    /// ** Hardcoded **
    static let largeDeviceWidthCutoff: CGFloat = 850.0
    static let keyboardHeight: CGFloat = UIScreen.main.bounds.height < largeDeviceWidthCutoff
    ? 291
    : 301
    
    struct FormStyle {
        struct Padding {
            static let horizontal: CGFloat = 17
            static let vertical: CGFloat = 15
        }
    }
    
    struct ColorHex {
        static let keyboardLight = "CFD3D9"
        static let keyboardDark = "383838"
    }
}
