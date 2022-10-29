import UIKit
import AVKit
import Vision

enum BarcodeSymbology {
    case code128
    case aztec
    case pdf417
    case qr
    case ean13
    
    var ciFilterName: String {
        switch self {
        case .code128:  return "CICode128BarcodeGenerator"
        case .aztec:    return "CIAztecCodeGenerator"
        case .pdf417:   return "CIPDF417BarcodeGenerator"
        case .qr:       return "CIQRCodeGenerator"
        case .ean13:    return "CICode128BarcodeGenerator"
        }
    }
    
    func generateBarcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii, allowLossyConversion: false)

        if let filter = CIFilter(name: ciFilterName) {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    init?(visionSymbology: VNBarcodeSymbology) {
        switch visionSymbology {
        case .code128:  self = .code128
        case .qr:       self = .qr
        case .aztec:    self = .aztec
        case .pdf417:   self = .pdf417
        case .ean13:    self = .ean13
        default:        return nil
        }
    }
}
