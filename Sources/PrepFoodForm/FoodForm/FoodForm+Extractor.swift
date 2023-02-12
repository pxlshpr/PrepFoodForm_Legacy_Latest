import SwiftUI
import PhotosUI
import FoodLabelExtractor
import FoodLabelScanner

extension FoodForm {
    
    var filledInAttributes: [Attribute] {
        var attributes: [Attribute] = []
        if !fields.energy.value.isEmpty { attributes.append(.energy) }
        if !fields.carb.value.isEmpty { attributes.append(.carbohydrate) }
        if !fields.fat.value.isEmpty { attributes.append(.fat) }
        if !fields.protein.value.isEmpty { attributes.append(.protein) }        
        for field in fields.allMicronutrientFields {
            if !field.value.isEmpty, let attribute = field.nutrientType?.attribute {
                attributes.append(attribute)
            }
        }

        return attributes
    }
    
    func extractorDidDismiss(_ output: ExtractorOutput?) {
        if let output {
            processExtractorOutput(output)
        }
        showingExtractorView = false
        extractor.cancelAllTasks()
        /// Do this now so that the cropped images are cleared out of memeory
        extractor.setup(
            attributesToIgnore: filledInAttributes,
            didDismiss: extractorDidDismiss
        )
        
        /// Allow the animation of food label appearing to complete before refreshing it (mitigating the sources view sometimes sliding into view only as we scroll past it)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            /// Only refresh the bool for the first image, since
            /// - there would already be the food label, so we wouldn't need to refresh it
            /// - the user has most likely scrolled down the list at this point, so refreshing would cause the
            /// scroll offset to reset
            if sources.imageViewModels.count == 1 {
                refreshBool.toggle()
            }
        }
    }
    
    func showExtractor(with item: PhotosPickerItem) {
        extractor.setup(
            attributesToIgnore: filledInAttributes,
            didDismiss: extractorDidDismiss
        )
        showingExtractorView = true
        
        Task(priority: .low) {
            guard let image = try await loadImage(pickerItem: item) else { return }
            
            await MainActor.run {
                self.extractor.image = image
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
