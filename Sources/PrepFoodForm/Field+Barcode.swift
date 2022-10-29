import UIKit
import RSBarcodes_Swift
import Vision

extension FieldValue {
    
    func barcodeThumbnail(asSquare: Bool = false) -> UIImage? {
        let width = 100
        let height = asSquare ? 100 : 40
        return barcodeImage(within: CGSize(width: width, height: height))
    }
    
    func barcodeImage(within size: CGSize) -> UIImage? {
        guard let barcodeValue else { return nil }
        return RSUnifiedCodeGenerator.shared.generateCode(
            barcodeValue.payloadString,
            machineReadableCodeObjectType: barcodeValue.symbology.objectType.rawValue,
            targetSize: size
        )
    }
}

extension VNBarcodeSymbology {
    var isSquare: Bool {
        switch self {
        case .qr, .aztec, .microQR:
            return true
        default:
            return false
        }
    }
}

//TODO: Remove this
extension Field {
    func barcodeThumbnail(asSquare: Bool = false) -> UIImage? {
        let width = 100
        let height = asSquare ? 100 : 40
        return barcodeImage(within: CGSize(width: width, height: height))
    }
    
    func barcodeImage(within size: CGSize) -> UIImage? {
        guard let barcodeValue else { return nil }
        return RSUnifiedCodeGenerator.shared.generateCode(
            barcodeValue.payloadString,
            machineReadableCodeObjectType: barcodeValue.symbology.objectType.rawValue,
            targetSize: size
        )
    }
}
