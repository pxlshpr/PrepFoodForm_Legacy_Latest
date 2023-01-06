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
        
        return {
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
            get: { self.columns.selectedColumnIndex },
            set: { newValue in
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
        
        Task.detached {
            
            /// Now continue our scan sequence by first cropping images
            try await self.cropImages()
        }
    }
}
