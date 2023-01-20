import Foundation
import SwiftUI
import SwiftHaptics
import SwiftSugar
import VisionSugar
import FoodLabelScanner
import PrepDataTypes

extension ScannerViewModel {

    func startRecognizingTexts(from image: UIImage) {

        setState(to: .recognizingTexts)

        scanTask = Task.detached { [weak self] in
            
            guard let self else { return }
            
            Haptics.selectionFeedback()
            
//            guard !Task.isCancelled else { return }
//            await MainActor.run { [weak self] in
//                self?.zoomOutCompletely(image)
//            }
            
            guard !Task.isCancelled else { return }
            if await self.isCamera {
                await MainActor.run { [weak self] in
                    withAnimation {
                        self?.hideCamera = true
                    }
                }
            } else {
                /// Ensure the sliding up animation is complete first
                try await sleepTask(0.2, tolerance: 0.005)
            }
            
            /// Now capture recognized texts
            /// - captures all the RecognizedTexts
            guard !Task.isCancelled else { return }
            let textSet = try await image.recognizedTextSet(for: .accurate, includeBarcodes: true)
            await MainActor.run { [weak self] in
                withAnimation {
                    self?.textSet = textSet
                }
            }
            
            guard !Task.isCancelled else { return }
            let textBoxes = textSet.texts.map {
                TextBox(
                    id: $0.id,
                    boundingBox: $0.boundingBox,
                    color: .accentColor,
                    opacity: 0.8,
                    tapHandler: {}
                )
            }
            
            Haptics.selectionFeedback()

            /// **VisionKit Scan Completed**: Show all `RecognizedText`'s
            guard !Task.isCancelled else { return }
            await MainActor.run {  [weak self] in
                guard let self else { return }
                withAnimation {
                    self.shimmeringImage = false
                    self.textBoxes = textBoxes
                    self.showingBoxes = true
                }
            }

            try await sleepTask(0.2, tolerance: 0.005)
            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self] in
                self?.shimmering = true
            }

            try await sleepTask(1, tolerance: 0.005)
            
            guard !Task.isCancelled else { return }
            
            try await self.classifyRecognizedTextSet(textSet)
        }
    }

    func classifyRecognizedTextSet(_ textSet: RecognizedTextSet) async throws {

        setState(to: .classifyingTexts)

        processScanTask = Task.detached { [weak self] in
            guard let self else { return }
            let scanResult = textSet.scanResult

            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.scanResult = scanResult
//                self.showingBlackBackground = false
            }
            
            guard !Task.isCancelled else { return }

//            await self.startCroppingImages()

            if scanResult.columnCount == 2 {
                try await self.showColumnPicker()
            } else {
                /// If we're not showing the column picker, go straight to the values picker
                try await self.showValuesPicker()
                
                /// zoom into the texts we'll be extracting, and wait for long enough to get the new `contentOffset` and `contentSize`
//                if await self.shouldZoomToTextsToCrop == true {
//                    await self.zoomToTextsToCrop()
//                    await MainActor.run { [weak self] in
//                        self?.waitingForZoomToEndToShowCroppedImages = true
//                    }
//                } else {
//                    await MainActor.run { [weak self] in
//                        self?.waitingToShowCroppedImages = true
//                    }
//                }
            }
        }
    }

    func showValuesPicker() async throws {
        
        setState(to: .awaitingConfirmation)
        withAnimation {
            showingValuePicker = true
            showingValuePickerUI = true
        }

        await MainActor.run { [weak self] in
            self?.shimmering = false
        }
        
        Haptics.feedback(style: .soft)
        
//        withAnimation {
//            showingValuePicker = true
//            showingValuePickerUI = true
//        }
//
//        zoom(to: self.nutrients.texts)
        await zoomToColumns()
    }
    
    /// Zooms into an area that encompasses the attribute's text box and its current value, with some padding
    func zoom(to texts: [RecognizedText]) {
        guard let imageSize = image?.size else { return }

        let columnZoomBox = ZBox(
            boundingBox: texts.boundingBox,
            animated: true,
            padded: true,
            paddedForSingleBox: texts.count == 1,
            imageSize: imageSize
        )

        NotificationCenter.default.post(
            name: .zoomZoomableScrollView,
            object: nil,
            userInfo: [Notification.ZoomableScrollViewKeys.zoomBox: columnZoomBox]
        )
    }
    
    /// Shows and highlights text boxes based on the attribute.
    /// - Attribute's text box and value is displayed in accent color with no border
    /// - All other text boxes with compatible values are displayed with secondary color and a border
    func showTextBoxesFor(
        attributeText: RecognizedText?,
        valueText: RecognizedText?
    ) {
        var textBoxes: [TextBox] = []
        var texts: [RecognizedText] = []
        if let attributeText {
            textBoxes.append(TextBox(
                boundingBox: attributeText.boundingBox,
                color: .accentColor,
                tapHandler: {}
            ))
            texts.append(attributeText)
        }
        if let valueText {
            textBoxes.append(TextBox(
                boundingBox: valueText.boundingBox,
                color: .blue,
                tapHandler: {}
            ))
            texts.append(valueText)
        }

        self.textBoxes = textBoxes
        
//        zoom(to: texts)
//        Task { [weak self] in
//            await self?.zoomToColumns()
//        }
        
//        zoom(to: self.nutrients.texts)
    }
    
    func showTappableTextBoxesForCurrentAttribute() {
        guard let currentAttribute, let scanResult else { return }
        let texts = scanResult.textsWithFoodLabelValues.filter { text in
            !self.textBoxes.contains(where: { $0.boundingBox == text.boundingBox })
        }
        let textBoxes = texts.map { text in
            TextBox(
                id: text.id,
                boundingBox: text.boundingBox,
                color: .yellow,
                opacity: 0.3,
                tapHandler: { self.tappedText(text) }
            )
        }
        self.textBoxes.append(contentsOf: textBoxes)
    }
    
    func tappedText(_ text: RecognizedText) {
        guard let firstValue = text.firstFoodLabelValue else {
            return
        }
        self.textFieldAmountString = firstValue.amount.cleanAmount
        if let unit = firstValue.unit {
            self.pickedAttributeUnit = unit
        }
    }

    func hideTappableTextBoxesForCurrentAttribute() {
        /// All we need to do is remove the text boxes that don't have a tap handler assigned to them
        textBoxes = textBoxes.filter { $0.tapHandler == nil }
    }

    func texts(for attribute: Attribute) -> [RecognizedText]? {
        guard let scanResult, let row = scanResult.row(for: attribute)
        else { return nil }
        
        let selectedColumn = columns.selectedColumnIndex
        var texts = [row.attributeText.text]
        if let text1 = row.valueText1?.text, selectedColumn == 1 {
            texts.append(text1)
        }
        if let text2 = row.valueText2?.text, selectedColumn == 2 {
            texts.append(text2)
        }
        return texts
    }
    
    func boundingBox(for attribute: Attribute) -> CGRect? {
        texts(for: attribute)?.boundingBox
    }
}
