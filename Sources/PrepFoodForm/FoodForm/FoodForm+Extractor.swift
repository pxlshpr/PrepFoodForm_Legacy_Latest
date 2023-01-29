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

    func extractorDidDismiss(_ output: ExtractorOutput?) {
        if let output {
            processExtractorOutput(output)
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
