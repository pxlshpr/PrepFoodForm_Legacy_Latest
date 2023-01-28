import SwiftUI
import PhotosUI
import FoodLabelExtractor
import FoodLabelScanner


extension FoodForm {
    func addExtractorView() {
        showingExtractorView = true
    }
    
    func removeExtractorView() {
        showingExtractorView = false
    }

    func extractorDidDismiss(_ outputTuple: (ScanResult, [ExtractedNutrient])?) {
        if let outputTuple {
            processExtractorOutput(
                scanResult: outputTuple.0,
                extractedNutrients: outputTuple.1
            )
        }
        removeExtractorView()
    }
    
    func showExtractor(with item: PhotosPickerItem) {
        extractor.setup(didDismiss: extractorDidDismiss)
        withAnimation {
            addExtractorView()
        }
        
        Task(priority: .userInitiated) {
            guard let image = try await loadImage(pickerItem: item) else { return }
            await MainActor.run {
                self.extractor.image = image
            }
        }
    }
    
    func showExtractorViewWithCamera() {
        extractor.setup(forCamera: true, didDismiss: extractorDidDismiss)
        withAnimation {
            addExtractorView()
        }
    }

    func loadImage(pickerItem: PhotosPickerItem) async throws -> UIImage? {
        guard let data = try await pickerItem.loadTransferable(type: Data.self) else {
            return nil
//            throw PhotoPickerError.load
        }
        guard let image = UIImage(data: data) else {
            return nil
//            throw PhotoPickerError.image
        }
        return image
    }

}
