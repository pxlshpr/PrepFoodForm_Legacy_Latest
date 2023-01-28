import SwiftUI
import PhotosUI
import FoodLabelExtractor
import FoodLabelScanner

extension FoodForm {
    
    /// ** Next Steps **
    /// [ ] Make tuple a struct that's returned, call it `ExtractorOutput`, include the image and selected cropped images in it too
    /// [ ] Have this function construct the fields as we did earlier, but simpler
    /// [ ] Do the same thing for serving and size info
    /// [ ] For the nutrients, go through the extracted nutrients and add them as either user input or autofill
    /// [ ] Use the cropped images we have so that we don't have to crop them again
    func processExtractorOutput(scanResult: ScanResult, extractedNutrients: [ExtractedNutrient]) {
        
    }
}
