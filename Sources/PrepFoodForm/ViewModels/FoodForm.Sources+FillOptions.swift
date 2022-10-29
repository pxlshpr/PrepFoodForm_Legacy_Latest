//import Foundation
//
//extension FoodForm.Sources {
//
//    func haveFillOptions(for fieldValue: FieldValue) -> Bool {
//        !fillOptions(for: fieldValue).isEmpty
//    }
//
//    func fillOptions(for fieldValue: FieldValue) -> [FillOption] {
//        var fillOptions: [FillOption] = []
//
//        /// Detected text option (if its available) + its alts
//        fillOptions.append(contentsOf: scannedFillOptions(for: fieldValue))
//        fillOptions.append(contentsOf: selectionFillOptions(for: fieldValue))
//        fillOptions.append(contentsOf: prefillOptions(for: fieldValue))
//
//
//        if let selectFillOption = selectFillOption(for: fieldValue) {
//            fillOptions .append(selectFillOption)
//        }
//
//        return fillOptions
//    }
//
//    //MARK: - Scanned
//
//    func scannedFillOptions(for fieldValue: FieldValue) -> [FillOption] {
//        let scannedFieldValues = FoodFormViewModel.shared.scannedFieldValues(for: fieldValue)
//        var fillOptions: [FillOption] = []
//
//        for scannedFieldValue in scannedFieldValues {
//            guard case .scanned(let info) = scannedFieldValue.fill else {
//                continue
//            }
//
//            fillOptions.append(
//                FillOption(
//                    string: fillButtonString(for: scannedFieldValue),
//                    systemImage: Fill.SystemImage.scanned,
//                    //                isSelected: self.value == autofillFieldValue.value,
//                    isSelected: fieldValue.equalsScannedFieldValue(scannedFieldValue),
//                    type: .fill(scannedFieldValue.fill)
//                )
//            )
//
//            /// Show alts if selected (only check the text because it might have a different value attached to it)
//            for altValue in scannedFieldValue.altValues {
//                fillOptions.append(
//                    FillOption(
//                        string: altValue.fillOptionString,
//                        systemImage: Fill.SystemImage.scanned,
//                        isSelected: fieldValue.value == altValue && fieldValue.fill.isImageAutofill,
//                        type: .fill(.scanned(info.withAltValue(altValue)))
//                    )
//                )
//            }
//        }
//
//        return fillOptions
//    }
//
//    //MARK: - Selection
//
//    func selectionFillOptions(for fieldValue: FieldValue) -> [FillOption] {
//        guard case .density = fieldValue else {
//            return fieldValue.selectionFillOptions
//        }
//
//        guard case .selection(let info) = fieldValue.fill,
//              let selectedText = info.imageText?.text,
//              selectedText != FoodFormViewModel.shared.firstScannedText(for: fieldValue)
//        else {
//            return []
//        }
//
//        return [
//            FillOption(
//                string: fillButtonString(for: fieldValue),
//                systemImage: Fill.SystemImage.selection,
//                isSelected: true,
//                type: .fill(fieldValue.fill)
//            )
//        ]
//    }
//
//    //MARK: - Prefill
//
//    func prefillOptions(for fieldValue: FieldValue) -> [FillOption] {
//        var fillOptions: [FillOption] = []
//
//        for prefillFieldValue in prefillOptionFieldValues(for: fieldValue) {
//
//            let info = prefillInfo(for: prefillFieldValue)
//            let option = FillOption(
//                string: prefillString(for: prefillFieldValue),
//                systemImage: Fill.SystemImage.prefill,
//                isSelected: fieldValue.shouldSelectFieldValue(prefillFieldValue),
//                disableWhenSelected: fieldValue.usesValueBasedTexts, /// disable selected value-based prefills (so not string-based ones that act as toggles)
//                type: .fill(.prefill(info))
//            )
//            fillOptions.append(option)
//        }
//        return fillOptions
//    }
//
//    func prefillOptionFieldValues(for fieldValue: FieldValue) -> [FieldValue] {
//        guard let food = prefilledFood else { return [] }
//
//        switch fieldValue {
//        case .name, .detail, .brand:
//            return food.stringBasedFieldValues
//        case .macro(let macroValue):
//            return [food.macroFieldValue(for: macroValue.macro)]
//        case .micro(let microValue):
//            return [food.microFieldValue(for: microValue.nutrientType)].compactMap { $0 }
//        case .energy:
//            return [food.energyFieldValue]
//        case .serving:
//            return [food.servingFieldValue].compactMap { $0 }
//        case .amount:
//            return [food.amountFieldValue].compactMap { $0 }
//        case .density:
//            return [food.densityFieldValue].compactMap { $0 }
//        case .size:
//            return prefillOptionSizeFieldValues(for: fieldValue)
////        case .size:
//
////            return food.detail
////        case .barcode(let stringValue):
////            return nil
////        case .density(let densityValue):
////
//        default:
//            return []
//        }
//    }
//
//    func prefillOptionSizeFieldValues(for fieldValue: FieldValue) -> [FieldValue] {
//        guard let food = prefilledFood else { return [] }
//        return prefillSizeOptionFieldValues(for: fieldValue, from: food.sizeFieldValues)
//    }
//
//    func prefillSizeOptionFieldValues(for fieldValue: FieldValue, from sizeFieldValues: [FieldValue]) -> [FieldValue] {
//        sizeFieldValues
//            .filter { $0.isSize }
//            .filter {
//                /// Always include the size that's being used by this fieldValue currently (so that we can see it toggled on)
//                guard fieldValue.size != $0.size, let size = $0.size else {
//                    return true
//                }
//
//                /// If we're currently editing a size—it may not be filtered in as we'd want it to if the user has edited it slightly.
//                /// This is because it would not match the current `fieldValue.size` (since the user has edited it)
//                ///     while still being present in the `allSizes` array—as the user hasn't commited the change yet.
//                /// So we will always store the current size being edited here so that we can disregard the following check and include it anyway.
////                if let sizeBeingEdited, sizeBeingEdited == $0.size {
////                    return true
////                }
//
//                /// Make sure we're not using it already
//                return !containsSize(withName: size.name, andVolumePrefixUnit: size.volumePrefixUnit, ignoring: sizeBeingEdited)
//            }
//    }
//
//    func prefillInfo(for fieldValue: FieldValue) -> PrefillFillInfo {
//        switch fieldValue {
//        case .name, .brand, .detail:
//            return PrefillFillInfo(fieldStrings: fieldValue.prefillFieldStrings)
//        case .density(let densityValue):
//            return PrefillFillInfo(densityValue: densityValue)
//        case .size(let sizeValue):
//            return PrefillFillInfo(size: sizeValue.size)
//        default:
//            return PrefillFillInfo()
//        }
//    }
//
//    func prefillString(for fieldValue: FieldValue) -> String {
//        ""
////        switch fieldValue {
////        case .name(let stringValue), .emoji(let stringValue), .brand(let stringValue), .detail(let stringValue):
////            return stringValue.string
////        case .amount(let doubleValue), .serving(let doubleValue):
////            return doubleValue.description
////
////        case .energy(let energyValue):
////            return energyValue.description
////        case .macro(let macroValue):
////            return macroValue.description
////        case .micro(let microValue):
////            return microValue.description
////        case .density(let densityValue):
////            return densityValue.description(weightFirst: isWeightBased)
////
////        case .size(let sizeValue):
////            return sizeValue.size.fullNameString.lowercased()
////
////        case .barcode:
////            return "(barcodes prefill not supported)"
////        }
//    }
//
//    //MARK: - Select Button
//
//    func selectFillOption(for fieldValue: FieldValue) -> FillOption? {
//        //TODO: Only show this when we actually have sources
////        guard fieldValue.supportsSelectingText,
////              hasAvailableTexts(for: fieldValue) else {
////            return nil
////        }
//        return FillOption(
//            string: "Select",
//            systemImage: Fill.SystemImage.selection,
//            isSelected: false, /// never selected as we only use this to pop up the `TextPicker`
//            type: .select
//        )
//    }
//
//    //MARK: - Helpers
//
//    func fillButtonString(for fieldValue: FieldValue) -> String {
//        ""
////        switch fieldValue {
////        case .amount(let doubleValue), .serving(let doubleValue):
////            return doubleValue.description
////        case .energy(let energyValue):
////            return energyValue.description
////        case .macro(let macroValue):
////            return macroValue.description
////        case .micro(let microValue):
////            return microValue.description
////        case .density(let densityValue):
////            return densityValue.description(weightFirst: isWeightBased)
////        case .size(let sizeValue):
////            return sizeValue.size.fullNameString
////        default:
////            return "(not implemented)"
////        }
//    }
//}
