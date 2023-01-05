import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import PhotosUI
import VisionSugar
import MFPScraper

extension FoodForm {

    func appeared() {
        sources.didScanAllPickedImages = didScanAllPickedImages
        sources.autoFillHandler = autoFillColumn
        
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
        Task {
            let fieldValues = await sources.extractFieldsFrom(results, at: column)
            withAnimation {
                handleExtractedFieldValues(fieldValues, shouldOverwrite: shouldOverwrite)
            }
        }
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
        case .takePhotos:
            showingCamera = true
        case .scanAFoodLabel:
            
            showingLabelScanner = true
            withAnimation {
                animateLabelScannerUp = true
            }
            
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
