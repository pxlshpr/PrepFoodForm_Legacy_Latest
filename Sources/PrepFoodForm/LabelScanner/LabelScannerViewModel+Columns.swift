import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer
import VisionSugar

extension LabelScannerViewModel {
    
    func zoomToColumns() async {
        guard let imageSize = image?.size else { return }
        let zoomRect = columns.boundingBox
        let columnZoomBox = ZoomBox(
            boundingBox: zoomRect,
            animated: true,
            padded: true,
            imageSize: imageSize
        )

        await MainActor.run {
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
        withAnimation {
            showingColumnPicker = true
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
        var allowsTaps = !columns.selectedColumn.contains(text)
        print("🥑 Tap handler for: \(text.string) will be: \(allowsTaps) because columns.selectedColumn does not contain it")
        guard allowsTaps else {
            return nil
        }
        return {
            withAnimation {
                print("🥑 Before toggling \(self.columns.selectedColumnIndex)")
                Haptics.feedback(style: .heavy)
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
//            return Color(.systemBackground)
            return Color.white
        }
    }

    /// [ ] Show column picking UI
    func showColumnPickingUI() async {
    }
}
