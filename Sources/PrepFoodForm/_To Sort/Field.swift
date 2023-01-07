import SwiftUI
import FoodLabelScanner
import SwiftSugar

class Field: ObservableObject, Identifiable {
    
    @Published var id = UUID()
    @Published var value: FieldValue
    
    @Published var image: UIImage? = nil
    @Published var isCropping: Bool = false

    init(fieldValue: FieldValue) {
        self.value = fieldValue
    }
    
//    deinit {
//        image = nil
//    }
    
    func fill(with fieldValue: FieldValue) {
        self.value = fieldValue
        resetAndCropImage()
    }

    //MARK: - Fill Manipulation
    
    func registerUserInput() {
        value.fill = .userInput
        image = nil
    }
    
    func registerDiscardedScan() {
        value.fill = .discardable
        image = nil
    }
    
    func registerDiscardScanIfUsingImage(withId id: UUID) {
        if value.fill.usesImage(with: id) {
            registerDiscardedScan()
        }
    }
    
    func assignNewScannedFill(_ fill: Fill) {
        let previousFill = value.fill
        value.fill = fill

        if fill.usesImage {
            if fill.text?.id != previousFill.text?.id {
                isCropping = true
                cropFilledImage()
            }
        } else {
            isCropping = false
            image = nil
        }
    }
    
    //MARK: - Image Cropping
    func resetAndCropImage() {
        image = nil
        isCropping = true
        cropFilledImage()
    }
    
    func cropFilledImage() {
        guard value.fill.usesImage else {
            withAnimation {
                image = nil
            }
            return
        }
        Task { [weak self] in
            guard let croppedImage = await FoodForm.Sources.shared.croppedImage(for: value.fill) else {
                return
            }

//            try await sleepTask(2)
            
            await MainActor.run { [weak self] in
                withAnimation {
                    self?.image = croppedImage
                    self?.isCropping = false
                }
            }
        }
    }
    
    //MARK: - Copying
    
    var copy: Field {
        let new = Field(fieldValue: value)
        new.copyData(from: self)
        return new
    }
    
    func copyData(from fieldViewModel: Field) {
        value = fieldViewModel.value
        
        if value.fill.usesImage {
            /// If the the image is still being cropped—do the crop ourselves instead of setting it here incorrectly
            if fieldViewModel.isCropping {
                isCropping = true
                cropFilledImage()
            } else {
                image = fieldViewModel.image
                isCropping = false
            }

        } else if value.fill.isPrefill {
//            prefillUrl = FoodFormViewModel.shared.prefilledFood?.sourceUrl
        }
    }
    
    //MARK: - Convenience
    
    var isValid: Bool {
        switch value {
        case .size(let sizeValue):
            return sizeValue.size.isValid
        case .density(let densityValue):
            return densityValue.isValid
        default:
            return false
        }
    }
    
    func contains(_ fieldString: PrefillFieldString) -> Bool {
        guard case .prefill(let info) = value.fill else {
            return false
        }
        return info.fieldStrings.contains(fieldString)
    }
    
    func imageTextMatchingText(of imageText: ImageText) -> ImageText? {
        nil
    }
    
    func toggleComponentText(_ componentText: ComponentText) {
        if value.contains(componentText: componentText) {
            value.fill.removeComponentText(componentText)
        } else {
            value.fill.appendComponentText(componentText)
        }
    }
    
    func toggle(_ fieldString: PrefillFieldString) {
        if contains(fieldString) {
            value.fill.removePrefillFieldString(fieldString)
        } else {
            value.fill.appendPrefillFieldString(fieldString)
        }
    }
    
    var isDiscardable: Bool {
        switch fill {
        case .scanned, .prefill, .discardable:
            return true
        case .userInput:
            return value.isEmpty
        case .selection:
            return false
        case .barcodeScanned:
            return true
        }
    }
}
extension Field: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(value)
        hasher.combine(image)
        hasher.combine(isCropping)
    }
}

extension Field: Equatable {
    static func ==(lhs: Field, rhs: Field) -> Bool {
//        lhs.hashValue == rhs.hashValue
        lhs.id == rhs.id
        && lhs.value == rhs.value
        && lhs.image == rhs.image
        && lhs.isCropping == rhs.isCropping
//        && lhs.prefillUrl == rhs.prefillUrl
//        && lhs.isPrefilled == rhs.isPrefilled
    }
}
