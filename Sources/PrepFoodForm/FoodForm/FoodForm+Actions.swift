import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import PhotosUI
import VisionSugar
import MFPScraper
import PrepDataTypes

extension FoodForm {

    func appeared() {
        
        if sources.startWithCamera {
            showExtractorViewWithCamera()
        }
        
        sources.didScanAllPickedImages = didScanAllPickedImages
        //MARK: ☣️
//        sources.autoFillHandler = autoFillColumn
        
//        sources.autoFillHandler = { selectedColumn, scanResult in
//            extract(column: selectedColumn,
//                    from: columnSelectionInfo.candidates,
//                    shouldOverwrite: false
//            )
//        }
        
        if shouldShowWizard {
            withAnimation(WizardAnimation) {
                formDisabled = true
                showingWizard = true
                shouldShowWizard = false
            }
        } else {
            showingWizard = false
            showingWizardOverlay = false
            formDisabled = false
        }
        
        if let initialScanImage, let initialScanResult {
            didReceiveScanFromFoodLabelCamera(initialScanResult, image: initialScanImage)
            self.initialScanImage = nil
            self.initialScanResult = nil
        }
        
        if let existingFood {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                prefillExistingFood(existingFood)
            }
        }
    }
    
    func autoFillColumn(_ selectedColumn: Int, from scanResult: ScanResult?) {
        guard let scanResult else {
            /// We shouldn't come here without a `ScanResult`
            return
        }
        extract(column: selectedColumn, from: [scanResult], shouldOverwrite: true)
    }

    func prefill(_ food: MFPProcessedFood) {
        fields.prefill(food)
    }
    
    func handleScannedBarcodes(_ barcodes: [RecognizedBarcode], on image: UIImage) {
        let imageViewModel = ImageViewModel(barcodeImage: image, recognizedBarcodes: barcodes)
        var didAddABarcode = false
        for barcode in barcodes {
            let field = Field(fieldValue:
                    .barcode(FieldValue.BarcodeValue(
                        payloadString: barcode.string,
                        symbology: barcode.symbology,
                        fill: .barcodeScanned(
                            ScannedFillInfo(
                                recognizedBarcode: barcode,
                                imageId: imageViewModel.id)
                        )
                    ))
            )
            didAddABarcode = fields.add(barcodeField: field)
        }
        if didAddABarcode {
            sources.addImageViewModel(imageViewModel)
            sources.updateImageSetStatusToScanned()
        }
    }
    
    func handleTypedOutBarcode(_ payload: String) {
        let barcodeValue = FieldValue.BarcodeValue(payload: payload, fill: .userInput)
        let field = Field(fieldValue: .barcode(barcodeValue))
        withAnimation {
            let didAdd = fields.add(barcodeField: field)
            if didAdd {
                Haptics.successFeedback()
            } else {
                Haptics.errorFeedback()
            }
        }
    }
    
    func deleteBarcodes(at offsets: IndexSet) {
        let indices = Array(offsets)
        for i in indices {
            let field = fields.barcodes[i]
            guard let payload = field.barcodeValue?.payloadString else {
                continue
            }
            sources.removeBarcodePayload(payload)
        }
        fields.barcodes.remove(atOffsets: offsets)
    }

    func didDismissColumnPicker() {
        sources.removeUnprocessedImageViewModels()
    }
    
    func extract(column: Int, from results: [ScanResult], shouldOverwrite: Bool) {
        //MARK: ☣️
//        Task {
//            let fieldValues = await sources.extractFieldsFrom(results, at: column)
//            withAnimation {
//                handleExtractedFieldValues(fieldValues, shouldOverwrite: shouldOverwrite)
//            }
//        }
    }
    
//    func handleSourcesAction(_ action: SourcesAction) {
//        switch action {
//        case .removeLink:
//            showingConfirmRemoveLinkMenu = true
//        case .addLink:
//            break
//        case .showPhotosMenu:
//            showingPhotosMenu = true
//        case .removeImage(index: let index):
//            resetFillForFieldsUsingImage(at: index)
//            sources.removeImage(at: index)
//        }
//    }
    
    /// Change all `.scanned` and `.selection` autofills that depend on this to `.userInput`
    //TODO: Move this to a Fields
    func resetFillForFieldsUsingImage(at index: Int) {
//        guard index < imageViewModels.count else {
//            return
//        }
//
//        let id = imageViewModels[index].id
//
//        /// Selectively reset fills for fields that are using this image
//        for fieldViewModel in allFieldViewModels {
//            fieldViewModel.registerDiscardScanIfUsingImage(withId: id)
//        }
//
//        /// Now remove the saved scanned field values that are also using this image
//        scannedFieldValues = scannedFieldValues.filter {
//            !$0.fill.usesImage(with: id)
//        }
    }

    //MARK: - Wizard Actions
    func tappedWizardButton(_ button: WizardButton) {
        Haptics.feedback(style: .soft)
        switch button {
        case .dismiss:
            Haptics.feedback(style: .soft)
            dismiss()
        case .background, .startWithEmptyFood:
            break
        case .camera:
            showExtractorViewWithCamera()
        case .choosePhotos:
            showingPhotosPicker = true
        case .prefill:
            showingPrefill = true
        case .prefillInfo:
            showingPrefillInfo = true
        }
        
        if button != .prefillInfo {
            dismissWizard()
        }
    }
    
    func dismissWizard() {
        withAnimation(WizardAnimation) {
            showingWizard = false
        }
        withAnimation(.easeOut(duration: 0.1)) {
            showingWizardOverlay = false
        }
        formDisabled = false
    }
}

extension FoodForm {
    func prefillExistingFood(_ food: Food) {
        
        guard !didPrefillFoodFields else {
            return
        }
        
        Task.detached(priority: .background) {
            
            await MainActor.run {
                fields.fillWithExistingFood(food)
                fields.updateFormState()
                didPrefillFoodFields = true
            }
            
            Task.detached(priority: .background) {
                await self.prefillImages(foodId: food.id)
            }
        }
    }
    
    func prefillImages(foodId: UUID) async {

        /// Grab json from server
        let urlString = "https://pxlshpr.app/prep/Uploads/jsons/\(directoryPath(for: foodId.uuidString))/\(foodId.uuidString).json"
        let url = URL(string: urlString)!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let fieldsAndSources = try JSONDecoder().decode(FoodFormFieldsAndSources.self, from: data)
            
            var imageViewModels: [ImageViewModel] = []
            for foodImage in fieldsAndSources.images {
                let imageURL = imageURL(imageId: foodImage.id)
                let (data, _) = try await URLSession.shared.data(from: imageURL)
                guard let image = UIImage(data: data) else {
                    print("⬇️ Couldn't create image from data")
                    continue
                }
                print("⬇️ Got back an image of size: \(image.size)")
                
                if let scanResult = foodImage.scanResult {
                    imageViewModels.append(.init(
                        image: image,
                        scanResult: scanResult
                    ))
                } else {
                    imageViewModels.append(.init(
                        image: image,
                        id: foodImage.id
                    ))
                }
            }
            
            await MainActor.run {

                sources.imageViewModels = imageViewModels
            //TODO: Do this first, and only do the local copy if we don't get the json data successfully
            
            /// Now set the Fills and crop the images
            fields.amount = .init(fieldValue: fieldsAndSources.amount)
            if let serving = fieldsAndSources.serving {
                fields.serving = .init(fieldValue: serving)
            }
            fields.energy = .init(fieldValue: fieldsAndSources.energy)
            fields.carb = .init(fieldValue: fieldsAndSources.carb)
            fields.fat = .init(fieldValue: fieldsAndSources.fat)
            fields.protein = .init(fieldValue: fieldsAndSources.protein)
            if let density = fieldsAndSources.density {
                fields.density = .init(fieldValue: density)
            }
            
            let sizeFields = fieldsAndSources.sizes.map { Field(fieldValue: $0) }
            fields.standardSizes = sizeFields.filter { !$0.isVolumePrefixedSize }
            fields.volumePrefixedSizes = sizeFields.filter { $0.isVolumePrefixedSize }
            
            fields.barcodes = fieldsAndSources.barcodes.map { Field(fieldValue: $0) }
            
            let microFields = fieldsAndSources.micronutrients.map { Field(fieldValue: $0) }
            fields.microsFats = microFields.filter({ $0.nutrientType?.group == .fats })
            fields.microsFibers = microFields.filter({ $0.nutrientType?.group == .fibers })
            fields.microsSugars = microFields.filter({ $0.nutrientType?.group == .sugars })
            fields.microsMinerals = microFields.filter({ $0.nutrientType?.group == .minerals })
            fields.microsVitamins = microFields.filter({ $0.nutrientType?.group == .vitamins })
            fields.microsMisc = microFields.filter({ $0.nutrientType?.group == .misc })
            

            fields.amount.resetAndCropImage()
            fields.energy.resetAndCropImage()
            fields.carb.resetAndCropImage()
            fields.fat.resetAndCropImage()
            fields.protein.resetAndCropImage()
            fields.serving.resetAndCropImage()
            fields.density.resetAndCropImage()
            fields.standardSizes.forEach { $0.resetAndCropImage() }
            fields.volumePrefixedSizes.forEach { $0.resetAndCropImage() }
            fields.barcodes.forEach { $0.resetAndCropImage() }
            fields.microsFats.forEach { $0.resetAndCropImage() }
            fields.microsFibers.forEach { $0.resetAndCropImage() }
            fields.microsSugars.forEach { $0.resetAndCropImage() }
            fields.microsMinerals.forEach { $0.resetAndCropImage() }
            fields.microsVitamins.forEach { $0.resetAndCropImage() }
            fields.microsMisc.forEach { $0.resetAndCropImage() }
            
            if let link = fieldsAndSources.link {
                sources.linkInfo = .init(link)
            }
            
            //TODO: Handle should publish
            
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        didPrefillFoodSources = true
                    }
//                }
            }
            
        } catch {
            print("⬇️ Error retrieving food json: \(error)")
        }
    }
}

func jsonURL(foodId: UUID) -> URL {
    let string = "https://pxlshpr.app/prep/Uploads/json/\(directoryPath(for: foodId.uuidString))/\(foodId.uuidString).json"
    return URL(string: string)!
}

func imageURL(imageId: UUID) -> URL {
    let string = "https://pxlshpr.app/prep/Uploads/images/\(directoryPath(for: imageId.uuidString))/\(imageId.uuidString).jpg"
    return URL(string: string)!
}

func directoryPath(for id: String) -> String {
    let suffix = id.suffix(6)
    guard suffix.count == 6 else { return "" }
    let folder1 = suffix.prefix(3)
    let folder2 = suffix.suffix(3)
    return "\(folder1)/\(folder2)"
}
