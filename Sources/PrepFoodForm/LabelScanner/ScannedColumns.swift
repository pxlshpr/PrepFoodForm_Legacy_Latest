import SwiftUI
import FoodLabelScanner
import VisionSugar

class ScannedColumns: ObservableObject {
    
    var column1: TextColumn
    var column2: TextColumn
    
    @Published var selectedColumnIndex: Int
    
    let id = UUID()
    
    init() {
        self.column1 = .init(column: 1, name: "", imageTexts: [])
        self.column2 = .init(column: 2, name: "", imageTexts: [])
        self.selectedColumnIndex = 1
        print("🔄 ScannedColumns \(self.id) was _inited 🌱")
    }
    
    init(column1: TextColumn, column2: TextColumn, selectedColumnIndex: Int) {
        self.column1 = column1
        self.column2 = column2
        self.selectedColumnIndex = selectedColumnIndex
        print("🔄 ScannedColumns \(self.id) was _inited 🌱")
    }
    
    deinit {
        print("🔄 ScannedColumns \(self.id) was deinited 🔥")
    }
    
    var selectedColumn: TextColumn {
        selectedColumnIndex == 1 ? column1 : column2
    }
    
    var selectedImageTexts: [ImageText] {
        selectedColumnIndex == 1 ? column1.imageTexts : column2.imageTexts
    }
    
    var texts: [RecognizedText] {
        var texts: [RecognizedText] = []
        for column in [column1, column2] {
            texts.append(
                contentsOf: column.imageTexts
                    .map { $0.text }
                )
        }
        return texts
    }
    
    var boundingBox: CGRect {
        var boundingBoxes: [CGRect] = []
        for column in [column1, column2] {
            boundingBoxes.append(
                contentsOf: column.imageTexts
                    .map { $0.boundingBoxWithAttribute }
            )
        }
        return boundingBoxes.union
    }
    
    func toggleSelectedColumnIndex() {
        selectedColumnIndex = selectedColumnIndex == 1 ? 2 : 1
    }
}

extension ScanResult {
    var scannedColumns: ScannedColumns {
        let column1 = TextColumn(
            column: 1,
            name: headerTitle1,
            imageTexts: imageTextsForColumnSelection(at: 1)
        )
        let column2 = TextColumn(
            column: 2,
            name: headerTitle2,
            imageTexts: imageTextsForColumnSelection(at: 2)
        )
        return ScannedColumns(
            column1: column1,
            column2: column2,
            selectedColumnIndex: bestColumn
        )
    }
}
