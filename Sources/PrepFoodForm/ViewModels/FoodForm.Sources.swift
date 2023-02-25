import SwiftUI
import SwiftUISugar
import FoodLabelScanner
import PhotosUI
import MFPScraper
import VisionSugar

extension FoodForm {
    public class Sources: ObservableObject {
        
        public static var shared = Sources()
        
        @Published var canBePublished: Bool = false

        @Published var imageViewModels: [ImageViewModel] = []
        @Published var imageSetStatus: ImageSetStatus = .loading()
        @Published var linkInfo: LinkInfo? = nil

        //MARK: ☣️
//        @Published var columnSelectionInfo: ColumnSelectionInfo? = nil
//        @Published var selectedScanResultsColumn = 1
        
        @Published var selectedPhotos: [PhotosPickerItem] = []

        var presentingImageIndex: Int = 0
        
        var didScanAllPickedImages: (() -> ())? = nil
        
        //MARK: ☣️
//        var autoFillHandler: ColumnSelectionHandler? = nil
        
        public var startWithCamera: Bool = false
        
        let id = UUID()
        
        public init() {
        }
                
        /// Reset this by recreating what it would be with a fresh call to `init()` (for reuse as we have one `@StateObject` in the entire app
        public func reset() {
            canBePublished = false

            imageViewModels = []
            imageSetStatus = .loading()
            linkInfo = nil

            //MARK: ☣️
//            columnSelectionInfo = nil
//            selectedScanResultsColumn = 1
            
            selectedPhotos = []

            presentingImageIndex = 0
            
            didScanAllPickedImages = nil
            
            startWithCamera = false
            //MARK: ☣️
//            autoFillHandler = nil
        }
    }
}

extension FoodForm.Sources {
    
    func add(_ image: UIImage, with scanResult: ScanResult) {
        let imageViewModel = ImageViewModel(image: image, scanResult: scanResult, delegate: self)
        addImageViewModel(imageViewModel)
    }
    
    func selectedPhotosChanged(to items: [PhotosPickerItem]) {
        for item in items {
            let imageViewModel = ImageViewModel(photosPickerItem: item, delegate: self)
            imageViewModels.append(imageViewModel)
        }
        updateCanBePublished()
        selectedPhotos = []
    }
    
    var numberOfSources: Int {
        imageViewModels.count + (linkInfo != nil ? 1 : 0)
    }
    
    func updateCanBePublished() {
        withAnimation {
            canBePublished = numberOfSources > 0
        }
    }
    
    func updateImageSetStatusToScanned() {
        imageSetStatus = .scanned(
            numberOfImages: imageViewModels.count,
            counts: DataPointsCount(total: 0, autoFilled: 0, selected: 0, barcodes: 0) /// do this
        )
    }
    
    //MARK: ☣️
//    func extractFieldsOrSetColumnSelectionInfo() async -> [FieldValue]? {
//
//        await MainActor.run {
//            imageSetStatus = .extracting(numberOfImages: imageViewModels.count)
//        }
//
//        guard let output = await FieldsExtractor.shared.extractFieldsOrGetColumnSelectionInfo(for: allScanResults)
//        else {
//            return nil
//        }
//        switch output {
//        case .needsColumnSelection(let columnSelectionInfo):
//            await MainActor.run {
//                self.columnSelectionInfo = columnSelectionInfo
//            }
//            return nil
//        case .fieldValues(let fieldValues):
//            return fieldValues
//        }
//    }
//
//    func extractFieldsFrom(_ results: [ScanResult], at column: Int) async -> [FieldValue] {
//        let output = await FieldsExtractor.shared.extractFieldsFrom(results, at: column)
//        guard case .fieldValues(let fieldValues) = output else {
//            return []
//        }
//        return fieldValues
//    }
    
    /**
     This is used to know which `ImageViewModel`s should be discarded when the user dismisses the column picker—by setting a flag in the `ImageViewModel` that marks it as completed.
     
     As this only gets called when the actual processing is complete, those without the flag set will be discarded.
     */
    func markAllImageViewModelsAsProcessed() {
        for i in imageViewModels.indices {
            imageViewModels[i].isProcessed = true
        }
    }
    
    func removeUnprocessedImageViewModels() {
        imageViewModels.removeAll(where: { !$0.isProcessed })
    }
    
    func removeBarcodePayload(_ string: String) {
        /// Remove the `RecognizedBarcode` from all `ImageViewModel`s
        for i in imageViewModels.indices {
            imageViewModels[i].recognizedBarcodes.removeAll(where: { $0.string == string })
        }
        
        /// Now remove the redundant `ImageViewModel`s we may have (those that were associated with the scanned barcode and have no other used barcodes remaining in it)
        imageViewModels.removeAll(where: { $0.scanResult == nil && $0.recognizedBarcodes.isEmpty })
    }
}

extension FoodForm.Sources {
    
    func addLink(_ linkInfo: LinkInfo) {
        self.linkInfo = linkInfo
        withAnimation {
            updateCanBePublished()
        }
    }
    func removeLink() {
        linkInfo = nil
        withAnimation {
            updateCanBePublished()
        }
    }
    
    func removeImage(at index: Int) {
        imageViewModels.remove(at: index)
        withAnimation {
            updateCanBePublished()
        }
    }
    
    func addImageViewModel(_ imageViewModel: ImageViewModel) {
        imageViewModels.append(imageViewModel)
        withAnimation {
            updateCanBePublished()
        }
    }
    
}

//MARK: - Convenience
extension FoodForm.Sources {
    
    func id(forImageAtIndex index: Int) -> UUID? {
        guard imageViewModels.indices.contains(index) else {
            return nil
        }
        return imageViewModels[index].id
    }
    
    //MARK: ☣️
//    func imageViewModels(for columnSelectionInfo: ColumnSelectionInfo) -> [ImageViewModel] {
//        imageViewModels.containingTexts(in: columnSelectionInfo)
//    }
    
    var allScanResults: [ScanResult] {
        imageViewModels.compactMap { $0.scanResult }
    }

    /// Returns how many images can still be added to this food
    var availableImagesCount: Int {
        max(5 - imageViewModels.count, 0)
    }
    
    var isEmpty: Bool {
        imageViewModels.isEmpty && linkInfo == nil
    }
    
    var pluralS: String {
        availableImagesCount == 1 ? "" : "s"
    }
    
    func croppedImage(for fill: Fill) async -> UIImage? {
        guard let resultId = fill.imageId,
              let boundingBoxToCrop = fill.boundingBoxToCrop,
              let image = image(for: resultId)
        else {
            return nil
        }
        
        return await image.cropped(boundingBox: boundingBoxToCrop)
    }
    
    func image(for id: UUID) -> UIImage? {
        for imageViewModel in imageViewModels {
            if imageViewModel.id == id {
//            if imageViewModel.scanResult?.id == scanResultId {
                return imageViewModel.image
            }
        }
        return nil
    }
}

//MARK: - ImageViewModelDelegate
extension FoodForm.Sources: ImageViewModelDelegate {
    
    func imageDidFinishScanning(_ imageViewModel: ImageViewModel) {
        guard !imageSetStatus.isScanned else {
            return
        }
        
        if imageViewModels.allSatisfy({ $0.status == .scanned }) {
            didScanAllPickedImages?()
        }
    }

    func imageDidStartScanning(_ imageViewModel: ImageViewModel) {
        withAnimation {
            self.imageSetStatus = .scanning(numberOfImages: imageViewModels.count)
        }
    }

    func imageDidFinishLoading(_ imageViewModel: ImageViewModel) {
        withAnimation {
            self.imageSetStatus = .scanning(numberOfImages: imageViewModels.count)
        }
    }
}

import VisionSugar

//MARK: - Available Texts
extension FoodForm.Sources {
    
    /**
     Returns true if there is at least one available (unused`RecognizedText` in all the `ScanResult`s that is compatible with the `fieldValue`
     */
    func hasAvailableTexts(for fieldValue: FieldValue) -> Bool {
        imageViewModels.contains(where: { $0.scanResult != nil })
        
        //TODO: Bring this back, we're currently rudimentarily returning true if we have any ScanResults
//        !availableTexts(for: fieldValue).isEmpty
    }
    
    func availableTexts(for fieldValue: FieldValue) -> [RecognizedText] {
        var availableTexts: [RecognizedText] = []
        for imageViewModel in imageViewModels {
            let texts = fieldValue.usesValueBasedTexts ? imageViewModel.textsWithFoodLabelValues : imageViewModel.texts
//            let filtered = texts.filter { isNotUsingText($0) }
            availableTexts.append(contentsOf: texts)
        }
        return availableTexts
    }

//    func isNotUsingText(_ text: RecognizedText) -> Bool {
//        fieldValueUsing(text: text) == nil
//    }
//    /**
//     Returns the `fieldValue` (if any) that is using the `RecognizedText`
//     */
//    func fieldValueUsing(text: RecognizedText) -> FieldValue? {
//        allFieldValues.first(where: {
//            $0.fill.uses(text: text)
//        })
//    }
}
