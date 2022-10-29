import Foundation
import AVKit
import RSBarcodes_Swift
import Vision

extension FieldValue.BarcodeValue {
    /// When we don't have a symbology provided (with typed out barcodes for instance),
    /// try and find a symbology that it is valid for—otherwise reverting to `.qr`
    init(payload: String, fill: Fill) {
        self.payloadString = payload
        self.fill = fill
        self.symbology = Self.compatibleType(to: payload)
    }
    
    static func compatibleType(to payload: String) -> VNBarcodeSymbology {
        let symbologies: [VNBarcodeSymbology] = [.ean13, .ean8, .code128, .upce]
        var picked: VNBarcodeSymbology? = nil
        for symbology in symbologies {
            if RSUnifiedCodeValidator.shared.isValid(payload, machineReadableCodeObjectType: symbology.objectType.rawValue)
            {
                picked = symbology
            }
        }
        return picked ?? .qr
    }
}
