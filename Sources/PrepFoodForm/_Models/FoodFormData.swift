import SwiftUI
import PrepDataTypes

public struct FoodFormData {
    
    public let images: [UUID: UIImage]
    public let data: Data
    public let shouldPublish: Bool
    public let createForm: UserFoodCreateForm
    
    init?(rawData: FoodFormRawData, images: [UUID : UIImage], shouldPublish: Bool) {
        guard let createForm = rawData.createForm
        else {
            return nil
        }
        self.images = images
        self.data = try! JSONEncoder().encode(rawData)
        self.shouldPublish = shouldPublish
        self.createForm = createForm
    }
}
