import SwiftUI
import PrepDataTypes

/**
 Encompasses all the data output by the `FoodForm`.
 */
public struct FoodFormOutput {
    
    public let images: [UUID: UIImage]
    public let data: Data
    public let shouldPublish: Bool
    public let createForm: UserFoodCreateForm
    
    init?(fieldsAndSources: FoodFormFieldsAndSources,
          images: [UUID : UIImage],
          shouldPublish: Bool
    ) {
        guard let createForm = fieldsAndSources.createForm
        else {
            return nil
        }
        self.images = images
        self.data = try! JSONEncoder().encode(fieldsAndSources)
        self.shouldPublish = shouldPublish
        self.createForm = createForm
    }
}
