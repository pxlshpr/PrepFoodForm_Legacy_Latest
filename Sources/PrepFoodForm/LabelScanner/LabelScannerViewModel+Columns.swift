import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer
import VisionSugar

extension ScanResult {

    var columnsTexts: [RecognizedText] {
        var texts: [RecognizedText] = []
        texts = headerTexts
        for nutrient in nutrients.rows {
//            texts.append(nutrient.attributeText.text)
            if let text = nutrient.valueText1?.text {
                texts.append(text)
            }
            if let text = nutrient.valueText2?.text {
                texts.append(text)
            }
        }
        return texts
    }

    var columnsBoundingBox: CGRect {
        columnsTexts
            .filter { $0.id != defaultUUID }
            .boundingBox
    }
}

extension CGRect {
    /// Assuming this was a `boundingBox` (ie with the y coordinate starting from the bottom)
    /// it gets converted to one with the y coordinate starting from the top.
//    var boundingRect: CGRect {
//
//    }
}

extension Array where Element == RecognizedText {
    var topMostText: RecognizedText? {
        sorted(by: { $0.boundingBox.minY < $1.boundingBox.minY }).first
    }
    
    var bottomMostText: RecognizedText? {
        sorted(by: { $0.boundingBox.maxY > $1.boundingBox.maxY }).first
    }
}
extension LabelScannerViewModel {
    
    func zoomToColumns() async {
        guard let imageSize = image?.size,
              let boundingBox = scanResult?.columnsBoundingBox
        else { return }
        
//        let zoomRect = columns.boundingBox
//        let zoomRect = CGRectMake(0.3537906976744186, 0.3771300995936023, 0.6, 0.2529084471421345)

        let columnZoomBox = ZoomBox(
            boundingBox: boundingBox,
            animated: true,
//            padded: true,
            padded: false,
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

    func showColumnPicker() async throws {
        guard let scanResult else { return }

        self.shimmering = false
//        Haptics.warningFeedback()
        Haptics.feedback(style: .soft)
        withAnimation {
            showingColumnPicker = true
            showingColumnPickerUI = true
        }

        columns = scanResult.scannedColumns
        selectedImageTexts = columns.selectedImageTexts

        print("🥑 selectedColumnIndex is \(columns.selectedColumnIndex)")
        await zoomToColumns()
        showColumnTextBoxes()
        await showColumnPickingUI()
    }

    /// [ ] Show column boxes (animate changes, have default column preselected)
    func showColumnTextBoxes() {
        self.textBoxes = columns.texts.map {
            TextBox(
                boundingBox: $0.boundingBox,
                color: color(for: $0),
                tapHandler: tapHandler(for: $0)
            )
        }
    }

    func tapHandler(for text: RecognizedText) -> (() -> ())? {
        let allowsTaps = !columns.selectedColumn.contains(text)
        guard allowsTaps else { return nil }
        
        return { [weak self] in
            guard let self else { return }
            withAnimation(.interactiveSpring()) {
                print("🥑 Before toggling \(self.columns.selectedColumnIndex)")
                Haptics.feedback(style: .soft)
                self.columns.toggleSelectedColumnIndex()
                self.selectedImageTexts = self.columns.selectedImageTexts
                print("🥑 AFTER toggling \(self.columns.selectedColumnIndex)")
            }
            self.showColumnTextBoxes()
        }
    }

    func color(for text: RecognizedText) -> Color {
        if selectedImageTexts.contains(where: { $0.text == text }) {
            return Color.accentColor
        } else {
            return Color(.systemBackground).opacity(0.8)
//            return Color.white
        }
    }

    /// [ ] Show column picking UI
    func showColumnPickingUI() async {
    }
    
    
    var selectedColumnBinding: Binding<Int> {
        Binding<Int>(
            get: { [weak self] in
                guard let self else { return 0 }
                return self.columns.selectedColumnIndex
            },
            set: { [weak self] newValue in
                guard let self else { return }
                print("Setting column to \(newValue)")
//                withAnimation {
                    self.columns.selectedColumnIndex = newValue
                    self.selectedImageTexts = self.columns.selectedImageTexts
//                }
                self.showColumnTextBoxes()
            }
        )
    }
    
    func columnSelectionHandler() {
        Haptics.feedback(style: .soft)
        withAnimation {
            self.showingColumnPickerUI = false
        }
        
        Task.detached { [weak self] in
            /// Now continue our scan sequence by first cropping images
            try await self?.cropImages()
        }
    }
}
