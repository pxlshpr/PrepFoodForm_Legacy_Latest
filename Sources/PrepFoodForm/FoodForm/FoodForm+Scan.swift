import SwiftUI
import FoodLabelScanner

extension FoodForm {

    func didReceiveScanFromFoodLabelCamera(_ scanResult: ScanResult, image: UIImage) {
        sources.add(image, with: scanResult)
        extractFieldsOrShowColumnSelectionInfo()
    }
    
    func didScanFoodLabel(notification: Notification) {
        extractFieldsOrShowColumnSelectionInfo()
    }
    
    func didScanAllPickedImages() {
        extractFieldsOrShowColumnSelectionInfo()
    }
    
    func extractFieldsOrShowColumnSelectionInfo() {
        //MARK: ☣️
//        Task {
//            guard let fieldValues = await sources.extractFieldsOrSetColumnSelectionInfo() else {
//                /// Either `sources.columnSelectionInfo` is set, causing us to present the `TextPicker`—or there were no results
//                return
//            }
//            withAnimation {
//                handleExtractedFieldValues(fieldValues, shouldOverwrite: false)
//            }
//        }
    }
    
    func handleExtractedFieldValues(_ fieldValues: [FieldValue], shouldOverwrite: Bool) {
        
        fields.handleExtractedFieldsValues(fieldValues, shouldOverwrite: shouldOverwrite)
        
        /// Set the `ImageSetStatus` in `Sources` with the counts from `Fields`
        sources.imageSetStatus = .scanned(
            numberOfImages: sources.imageViewModels.count,
//            counts: fields.dataPointsCount //TODO: Do this
            counts: DataPointsCount(total: 0, autoFilled: 0, selected: 0, barcodes: 0)
        )
    }
    
}
