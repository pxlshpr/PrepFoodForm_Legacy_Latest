import SwiftUI
import PrepDataTypes

extension FoodForm {
    
    var imagesDict: [UUID: UIImage] {
        var dict: [UUID: UIImage] = [:]
        for imageViewModel in sources.imageViewModels {
            guard let image = imageViewModel.image else { continue }
            dict[imageViewModel.id] = image
        }
        return dict
    }
    
    func foodFormOutput(shouldPublish: Bool) -> FoodFormOutput? {
        guard
            let fieldsAndSources = FoodFormFieldsAndSources(fields: fields, sources: sources),
            let createForm = fieldsAndSources.createForm,
            let jsonData = try? JSONEncoder().encode(fieldsAndSources)
        else {
            return nil
        }
        
        return FoodFormOutput(
            createForm: createForm,
            fieldsAndSourcesJSONData: jsonData,
            images: imagesDict,
            shouldPublish: shouldPublish)
    }
}
