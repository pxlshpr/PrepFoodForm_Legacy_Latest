import Foundation
import SwiftUI
import SwiftHaptics
import SwiftSugar
import VisionSugar
import FoodLabelScanner

extension LabelInteractiveScannerViewModel {

    func startScan(_ image: UIImage) {

        scanTask = Task.detached { [weak self] in
            
            guard let self else { return }
            
            Haptics.selectionFeedback()
            
            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self] in
                self?.zoomOutCompletely(image)
            }
            
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
            
            try await self.processScan(textSet: textSet)
        }
    }

    func processScan(textSet: RecognizedTextSet) async throws {
        
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

            await self.startCroppingImages()

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
        guard let scanResult else { return }

        await MainActor.run { [weak self] in
            self?.shimmering = false
        }
        
        Haptics.feedback(style: .soft)
        
        withAnimation {
            showingValuePicker = true
            showingValuePickerUI = true
        }

        guard let firstAttribute = scanResult.nutrientAttributes.first else {
            /// Handle having no attributes (dismiss immediately)
            return
        }
        await zoomToColumns()
        await focus(on: firstAttribute)
    }
    
    func focus(on attribute: Attribute) async {
        self.focusedAttribute = attribute
//        await zoomIn(for: attribute)
        showTextBoxes(for: attribute)
    }
    
    /// Zooms into an area that encompasses the attribute's text box and its current value, with some padding
    func zoomIn(for attribute: Attribute) async {
        print("Zooming in for: \(attribute)")
        guard let imageSize = image?.size,
              let boundingBox = boundingBox(for: attribute)
        else { return }

        let columnZoomBox = ZoomBox(
            boundingBox: boundingBox,
            animated: true,
            padded: true,
            imageSize: imageSize
        )

        print("🏎 zooming to boundingBox: \(boundingBox)")
        await MainActor.run { [weak self] in
            guard let _ = self else { return }
            NotificationCenter.default.post(
                name: .zoomZoomableScrollView,
                object: nil,
                userInfo: [Notification.ZoomableScrollViewKeys.zoomBox: columnZoomBox]
            )
        }
    }
    
    func didTapCheckmark() {
        moveToNextTextBox()
    }
    
    func moveToNextTextBox() {
        guard let focusedAttribute,
              let nextAttribute = scanResult?.nextAttribute(to: focusedAttribute)
        else { return }
        moveToNextAttributeTask = Task.detached { [weak self] in
            await self?.focus(on: nextAttribute)
        }
    }
    
    /// Shows and highlights text boxes based on the attribute.
    /// - Attribute's text box and value is displayed in accent color with no border
    /// - All other text boxes with compatible values are displayed with secondary color and a border
    func showTextBoxes(for attribute: Attribute) {
        guard let texts = texts(for: attribute) else { return }
        
        self.textBoxes = texts.map {
            TextBox(
                boundingBox: $0.boundingBox,
                color: .green,
                tapHandler: {}
//                color: color(for: $0),
//                tapHandler: tapHandler(for: $0)
            )
        }

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

extension ScanResult {
    /// Returns the next element to `attribute` in `nutrientAttributes`,
    /// cycling back to the first once the end is reached.
    func nextAttribute(to attribute: Attribute) -> Attribute? {
        guard let index = nutrientAttributes.firstIndex(of: attribute) else {
            return nil
        }
        let nextIndex: Int
        if index >= nutrientAttributes.count - 1 {
            nextIndex = 0
        } else {
            nextIndex = index + 1
        }
        return nutrientAttributes[nextIndex]
    }
}
