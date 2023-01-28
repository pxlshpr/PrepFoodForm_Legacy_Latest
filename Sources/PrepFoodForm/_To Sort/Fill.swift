import Foundation
import FoodLabelScanner
import VisionSugar
import UIKit
import PrepDataTypes

indirect enum Fill: Hashable, Codable {
    
    case scanned(ScannedFillInfo)
    case selection(SelectionFillInfo)
    case prefill(PrefillFillInfo = .init())
    case userInput
    
    /// Use when a `ScanResult` is discarded (by deleting the image)—and we've lost the associated fill data,
    /// but still want to differentiate this from `.userInput` (as its not been edited since the user scanned it in).
    /// This is so that we can identify fields marked with this as `discardable` when new scans come in.
    case discardable
    
    case barcodeScanned(ScannedFillInfo)
}

extension Fill {
    
    struct SystemImage {
        static let scanned = "text.viewfinder"
        static let prefill = "link"
        static let userInput = "keyboard"
        static let selection = "text.viewfinder" /// "hand.tap"
        static let barcode = "barcode.viewfinder"
    }
    
    var iconSystemImage: String {
        switch self {
        case .userInput:
            return SystemImage.userInput
        case .selection:
            return SystemImage.selection
        case .scanned:
            return SystemImage.scanned
        case .prefill:
            return SystemImage.prefill
        case .barcodeScanned:
            return SystemImage.barcode
        case .discardable:
            return "viewfinder"
        }
    }
    
    var buttonSystemImage: String {
        iconSystemImage
        //        switch self {
        //        case .userInput:
        //            return "circle.dashed"
        //        case .selection:
        //            return "hand.tap"
        //        case .scanResult:
        //            return "viewfinder.circle.fill"
        //        case .prefill:
        //            return "link"
        //        case .barcodeScan:
        //            return "viewfinder.circle.fill"
        //        }
    }
    
    var sectionHeaderString: String {
        switch self {
        case .prefill:
            return "Copied from third-pary food"
        case .scanned:
            return "Auto-filled from image"
        case .selection:
            return "Selected from image"
        case .userInput:
            //            if !fieldValue.isEmpty {
            //                return "Manually entered"
            //            }
            return ""
        default:
            break
        }
        return ""
    }
    
    var isPrefill: Bool {
        switch self {
        case .prefill:
            return true
        default:
            return false
        }
    }
    
    var isImageAutofill: Bool {
        switch self {
        case .scanned:
            return true
        default:
            return false
        }
    }
    
    var usesImage: Bool {
        switch self {
        case .selection, .scanned:
            return true
        default:
            return false
        }
    }
    
    var isImageSelection: Bool {
        switch self {
        case .selection:
            return true
        default:
            return false
        }
    }
    
    var attributeText: RecognizedText? {
        imageText?.attributeText
    }
    
    var texts: [RecognizedText] {
        switch self {
        case .scanned(let info):
            return [info.imageText.text]
        case .selection(let info):
            return [info.imageText?.text].compactMap { $0 }
        default:
            return []
        }
    }
}

//TODO: Selection will return multiple for these
extension Fill {
    var imageText: ImageText? {
        switch self {
        case .scanned(let info):
            return info.imageText
        case .selection(let info):
            return info.imageText
        default:
            return nil
        }
    }
    
    var imageTexts: [ImageText] {
        switch self {
        case .scanned(let scannedFillInfo):
            return [scannedFillInfo.imageText]
        case .selection(let selectionFillInfo):
            guard let imageText = selectionFillInfo.imageText else {
                return selectionFillInfo.componentImageTexts
            }
            return [imageText]
        default:
            return []
        }
    }
    
    var text: RecognizedText? {
        imageText?.text
    }
    
    var imageId: UUID? {
        imageText?.imageId
    }
    
    var boundingBoxToCrop: CGRect? {
        switch self {
        case .scanned(let info):
            if let attributeText = attributeText, attributeText != text {
                return attributeText.boundingBox.union(info.imageText.text.boundingBox)
            } else {
                return info.imageText.text.boundingBox
            }
        case .selection:
            return text?.boundingBox
        default:
            return nil
        }
    }
    
    var boundingBox: CGRect? {
        switch self {
        case .selection, .scanned:
            return text?.boundingBox
        default:
            return nil
        }
    }
    
    var detectedValues: [FoodLabelValue] {
        guard let text else { return [] }
        return text.candidates.map({$0.detectedValues}).reduce([], +)
    }
}

extension Fill {
    
    var isAltValue: Bool {
        altValue != nil
    }

    /// Returns the `FoodLabelValue` represented by this fill type.
    var value: FoodLabelValue? {
        switch self {
        case .scanned(let info):
            return info.altValue ?? info.value
        case .selection(let info):
            return info.altValue ?? info.imageText?.text.firstFoodLabelValue
        default:
            return nil
        }
    }
    
    /// Returns the `FoodLabelValue` associated with this fill type as an alt value. This does not return the actual `FoodLabelValue` that this fill type represents if it doesn't have an alt value.
    var altValue: FoodLabelValue? {
        get {
            switch self {
            case .scanned(let info):
                return info.altValue
            case .selection(let info):
                return info.altValue
            default:
                return nil
            }
        }
        set {
            switch self {
            case .scanned(let info):
                var newInfo = info
                newInfo.altValue = newValue
                self = .scanned(newInfo)
            case .selection(let info):
                var newInfo = info
                newInfo.altValue = newValue
                self = .selection(newInfo)
            default:
                break
            }
        }
    }
}

extension Fill {
    var energyValue: FoodLabelValue? {
        switch self {
        case .scanned(let info):
            return info.altValue ?? info.value
        case .selection(let info):
            return altValue ?? info.imageText?.text.string.energyValue
        default:
            return nil
        }
    }
}

extension Fill {
    func uses(text: RecognizedText) -> Bool {
        switch self {
        case .selection:
            return self.text?.id == text.id
        case .scanned(let info):
            return info.imageText.text.id == text.id || info.imageText.attributeText?.id == text.id
        default:
            return false
        }
    }
}

enum PrefillField: Int, Codable {
    case name
    case detail
    case brand
}

extension Fill {
    mutating func removeComponentText(_ componentText: ComponentText) {
        guard case .selection(let info) = self, let componentTexts = info.componentTexts else {
            return
        }
        var newInfo = info
        var newComponentTexts = componentTexts
        newComponentTexts.removeAll(where: { $0 == componentText })
        newInfo.componentTexts = newComponentTexts
        self = .selection(newInfo)
    }
    
    mutating func appendComponentText(_ componentText: ComponentText) {
        let componentTexts: [ComponentText]
        if case .selection(let info) = self, let existingComponentTexts = info.componentTexts {
            componentTexts = existingComponentTexts + [componentText]
        } else {
            /// ** Note: ** This is now converting a possible `.scanned` Fill into a `.selection` one
            componentTexts = [componentText]
        }
        
        self = .selection(.init(componentTexts: componentTexts))
    }
}

extension SelectionFillInfo {
    var componentImageTexts: [ImageText] {
        guard let componentTexts else { return [] }
        return componentTexts
            .map { $0.imageText }
            .removingDuplicates()
    }
}

extension FieldValue {
    func contains(componentText: ComponentText) -> Bool {
        guard let componentTexts else { return false }
        return componentTexts.contains(componentText)
    }
    
    var componentTexts: [ComponentText]? {
        fill.componentTexts
    }
}

extension Fill {
    var componentTexts: [ComponentText]? {
        guard case .selection(let info) = self else {
            return nil
        }
        return info.componentTexts
    }
}

extension ImageText {
    var componentTexts: [ComponentText] {
        text.string.selectionComponents.map {
            ComponentText(
                componentString: $0.capitalizedIfUppercase,
                imageText: self)
        }
    }
}

extension Array where Element == FillOption {
    func contains(string: String) -> Bool {
        contains(where: { $0.string == string })
    }
}

extension Field {
    func appendComponentTexts(for imageText: ImageText) {
        for componentText in imageText.componentTexts {
            value.fill.appendComponentText(componentText)
        }
    }
}

extension Fill {
    mutating func appendPrefillFieldString(_ fieldString: PrefillFieldString) {
        let fieldStrings: [PrefillFieldString]
        if case .prefill(let info) = self {
            fieldStrings = info.fieldStrings + [fieldString]
        } else {
            /// ** Note: ** This is now converting a possible `.scanned` Fill into a `.selection` one
            fieldStrings = [fieldString]
        }
        
        self = .prefill(.init(fieldStrings: fieldStrings))
    }
    
    mutating func removePrefillFieldString(_ fieldString: PrefillFieldString) {
        guard case .prefill(let info) = self else {
            return
        }
        var newInfo = info
        newInfo.fieldStrings.removeAll(where: { $0 == fieldString })
        self = .prefill(newInfo)
    }
}

//TODO: Sort these

struct ImageText: Hashable, Codable {
    let text: RecognizedText
    let attributeText: RecognizedText?
    let imageId: UUID
    var pickedCandidate: String?
    
    init(text: RecognizedText, attributeText: RecognizedText? = nil, imageId: UUID, pickedCandidate: String? = nil) {
        self.text = text
        self.imageId = imageId
        self.attributeText = attributeText
        self.pickedCandidate = pickedCandidate
    }
    
    init(valueText: ValueText, imageId: UUID, pickedCandidate: String? = nil) {
        self.text = valueText.text
        self.attributeText = valueText.attributeText
        self.imageId = imageId
        self.pickedCandidate = pickedCandidate
    }    
}

extension ImageText {
    var withoutPickedCandidate: ImageText {
        var newImageText = self
        newImageText.pickedCandidate = nil
        return newImageText
    }

    var boundingBoxWithAttribute: CGRect {
        guard let attributeText else { return text.boundingBox }
        return attributeText.boundingBox.union(text.boundingBox)
    }
    
    var boundingBox: CGRect {
        text.boundingBox
    }
}


struct ScannedFillInfo: Hashable, Codable {
    var imageText: ImageText
    var value: FoodLabelValue?
    var altValue: FoodLabelValue? = nil
    var densityValue: FieldValue.DensityValue? = nil
    var size: FormSize? = nil

    init(imageText: ImageText, value: FoodLabelValue? = nil, altValue: FoodLabelValue? = nil, densityValue: FieldValue.DensityValue? = nil, size: FormSize? = nil) {
        self.value = value
        self.imageText = imageText
        self.altValue = altValue
        self.densityValue = densityValue
        self.size = size
    }
    
    init(valueText: ValueText, imageId: UUID, altValue: FoodLabelValue? = nil) {
        self.value = valueText.value
        self.imageText = ImageText(valueText: valueText, imageId: imageId)
        self.altValue = altValue
    }
    
    func withAltValue(_ value: FoodLabelValue) -> ScannedFillInfo {
        var newInfo = self
        newInfo.altValue = value
        return newInfo
    }
    
    init(recognizedBarcode: RecognizedBarcode, imageId: UUID) {
        let imageText = ImageText(text: RecognizedText(recognizedBarcode: recognizedBarcode), imageId: imageId)
        self.imageText = imageText
        self.value = nil
    }
}

struct ScannedBarcodeFillInfo: Hashable {
//    var imageText: ImageText
//
//    init(boundingBox: CGRect, imageId: UUID) {
//        let text = RecognizedText(
//        let imageText = ImageText(text: <#T##RecognizedText#>, imageId: <#T##UUID#>)
//        self.value = value
//        self.imageText = imageText
//        self.altValue = altValue
//        self.densityValue = densityValue
//        self.size = size
//    }
    
}

struct ComponentText: Hashable, Codable {
    let componentString: String
    let imageText: ImageText
}

enum SelectionFillType: Int, Hashable, Codable {
    case primaryValue
    case altValue
    case unitConversion
}

struct SelectionFillInfo: Hashable, Codable {
    
    /// This indicates the `ImageText` that was selected by the user.
    var imageText: ImageText?
    
    var componentTexts: [ComponentText]?
    
    //TODO: Add a 'calculationType' or selectionType here, which has cases like .calculatedUsingEnergyEquation, .convertedUnit, .otherCandidate, or .primaryCandidate which identifies the type of selection
    var type: SelectionFillType = .primaryValue
    
    var altValue: FoodLabelValue? = nil
    var densityValue: FieldValue.DensityValue? = nil

    func withAltValue(_ value: FoodLabelValue) -> SelectionFillInfo {
        var newInfo = self
        newInfo.altValue = value
        return newInfo
    }
    
    var concatenatedComponentStrings: String {
        guard let componentTexts else { return "" }
        return componentTexts
            .map { $0.componentString }
            .joined(separator: " ")
    }
    
    func usesImage(with id: UUID) -> Bool {
        if let imageText, imageText.imageId == id {
            return true
        }
        if let componentTexts {
            return componentTexts.contains(where: { $0.imageText.imageId == id })
        }
        return false
    }
}

struct PrefillFieldString: Hashable, Codable {
    let string: String
    let field: PrefillField
}

struct PrefillFillInfo: Hashable, Codable {
    var fieldStrings: [PrefillFieldString] = []
    var densityValue: FieldValue.DensityValue? = nil
    var size: FormSize? = nil
    
    var concatenated: String {
        fieldStrings
            .map { $0.string.capitalized }
            .joined(separator: " ")
    }
}
