import Foundation
import FoodLabelScanner

class FieldsExtractor {
    
    static let shared = FieldsExtractor()
    
    /**
     Tries to process `ScanResult`s, by first checking if the candidates are single or double columned.
     
     If they are single columned—the `ScanResult`s are processed immediately, and the `FieldValues` are returned in a `.fieldValues` output.
     
     If they are double columned—a `ColumnSelectionInfo` is generated and returned with a `.needsColumnSelection` output, so that the user may be presented with UI to select the desired column, after which the actual process function would be called (with an explicit column provided).
     */
    func extractFieldsOrGetColumnSelectionInfo(for scanResults: [ScanResult]) async -> FieldsExtractorOutput? {
        
        let candidates = scanResults.candidateScanResults
        if candidates.minimumNumberOfColumns == 2 {
            return await columnSelectionOutput(candidates: candidates)
        } else {
            return await extractFieldsFrom(candidates, at: 1)
        }
    }
    
    func columnSelectionOutput(candidates: [ScanResult]) async -> FieldsExtractorOutput? {
        guard let best = candidates.bestScanResult else {
            return nil
        }
        let column1 = TextColumn(
            column: 1,
            name: best.headerTitle1,
            imageTexts: candidates.imageTextsForColumnSelection(at: 1)
        )
        let column2 = TextColumn(
            column: 2,
            name: best.headerTitle2,
            imageTexts: candidates.imageTextsForColumnSelection(at: 2)
        )
        
        /// Determine the best column to preset the selection with.
        /// This is currently the column with the most nutrients, or largest values (if both have the same number of nutrients)
        let bestColumn = best.bestColumn
        
        let columnSelectionInfo = ColumnSelectionInfo(
            candidates: candidates,
            column1: column1,
            column2: column2,
            bestColumn: bestColumn
        )
        return .needsColumnSelection(columnSelectionInfo)
    }
    
    func extractFieldsFrom(_ results: [ScanResult], at column: Int) async -> FieldsExtractorOutput {
        .fieldValues(results.bestFieldValues(at: column))
    }
}
