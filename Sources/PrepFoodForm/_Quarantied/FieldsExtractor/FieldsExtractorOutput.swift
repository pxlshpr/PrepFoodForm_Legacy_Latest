//import Foundation
//import FoodLabelScanner
//
//enum FieldsExtractorOutput {
//    case needsColumnSelection(ColumnSelectionInfo)
//    case fieldValues([FieldValue])
//}
//
//struct ColumnSelectionInfo: Identifiable, Equatable {
//    let id = UUID()
//    let candidates: [ScanResult]
//    let column1: TextColumn
//    let column2: TextColumn
//    let bestColumn: Int
//    
//    static func == (lhs: ColumnSelectionInfo, rhs: ColumnSelectionInfo) -> Bool {
//        lhs.id == rhs.id
//    }
//}
