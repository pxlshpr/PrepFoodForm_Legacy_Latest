import Foundation
import FoodLabelScanner

typealias SingleSelectionHandler = ((ImageText) -> ())
typealias MultiSelectionHandler = (([ImageText]) -> ())
typealias ColumnSelectionHandler = ((Int, ScanResult?) -> ())
typealias DeleteImageHandler = ((Int) -> ())
typealias DismissHandler = (() -> ())
