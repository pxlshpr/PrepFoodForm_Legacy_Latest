import Foundation
import FoodLabelScanner
import VisionSugar

struct FoodImage: Codable {
    
    let id: UUID
    let scanResult: ScanResult?
    let barcodes: [RecognizedBarcode]
    
    init(_ imv: ImageViewModel) {
        self.id = imv.id
        self.scanResult = imv.scanResult
        self.barcodes = imv.recognizedBarcodes
    }
}
