import SwiftUI
import PhotosUI
import FoodLabelExtractor
import FoodLabelScanner


extension FoodForm {
    
    func extractorDidDismiss(_ output: ExtractorOutput?) {
        if let output {
            processExtractorOutput(output)
        }
        showingExtractorView = false
        extractor.cancelAllTasks()
    }
    
    func showExtractor(with item: PhotosPickerItem) {
        extractor.setup(didDismiss: extractorDidDismiss)
        
        Task(priority: .low) {
            guard let image = try await loadImage(pickerItem: item) else { return }

            await MainActor.run {
                self.extractor.image = image
//                withAnimation {
                    showingExtractorView = true
//                }
            }
        }
    }
    
    func showExtractorViewWithCamera() {
        extractor.setup(forCamera: true, didDismiss: extractorDidDismiss)
        withAnimation {
            showingExtractorView = true
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
