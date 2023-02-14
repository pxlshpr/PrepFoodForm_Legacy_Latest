import Foundation
import MFPScraper
import PrepDataTypes

struct FoodFormFieldsAndSources: Codable {

    let name: String
    let emoji: String
    let detail: String?
    let brand: String?
    
    let amount: FieldValue
    let serving: FieldValue?
    let energy: FieldValue
    let carb: FieldValue
    let fat: FieldValue
    let protein: FieldValue
    let density: FieldValue?
    
    let sizes: [FieldValue]
    let barcodes: [FieldValue]
    let micronutrients: [FieldValue]
    
    let link: String?
    
    let prefilledFood: MFPProcessedFood?
    let images: [FoodImage]
    
    let shouldPublish: Bool
    
    init?(fields: FoodForm.Fields, sources: FoodForm.Sources, shouldPublish: Bool) {
//        guard fields.isValid else { return nil }
        
        self.name = fields.name
        self.emoji = fields.emoji
        self.detail = fields.detail
        self.brand = fields.brand
        self.amount = fields.amount.value
        self.serving = fields.serving.value
        self.energy = fields.energy.value
        self.carb = fields.carb.value
        self.fat = fields.fat.value
        self.protein = fields.protein.value
        self.density = fields.density.value
        
        self.sizes = fields.allSizeFields.map { $0.value }
        self.barcodes = fields.barcodes.map { $0.value }
        self.micronutrients = fields.allMicronutrientFieldValues

        self.prefilledFood = fields.prefilledFood

        self.link = sources.linkInfo?.urlString
        self.images = sources.imageViewModels.map { FoodImage($0) }
        
        self.shouldPublish = shouldPublish
    }
    
    static func save(_ fields: FoodForm.Fields) {
//        persistOnDevice(ffvm)
//        uploadToServer(ffvm)
    }
    
    static func uploadToServer(_ fields: FoodForm.Fields) {
        //TODO: Bring this back
//        guard let serverFoodForm = fields.serverFoodForm,
//              let request = NetworkController.server.postRequest(for: serverFoodForm)
//        else {
//            return
//        }
//
//        Task {
//            let (data, response) = try await URLSession.shared.data(for: request)
//            cprint("🌐 Here's the response:")
//            cprint("🌐 \(response)")
//        }
    }
    
    static func persistOnDevice(_ fields: FoodForm.Fields, sources: FoodForm.Sources, shouldPublish: Bool) {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        Task {
            let directoryUrl = documentsUrl.appending(component: UUID().uuidString)
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false)
            
            for imageViewModel in sources.imageViewModels {
                try await imageViewModel.writeImage(to: directoryUrl)
            }

            let encoder = JSONEncoder()
            let data = try encoder.encode(FoodFormFieldsAndSources(fields: fields, sources: sources, shouldPublish: shouldPublish))

            let foodUrl = directoryUrl.appending(component: "FoodFormRawData.json")
            try data.write(to: foodUrl)
            cprint("📝 Wrote food to: \(directoryUrl)")
        }
    }
}
