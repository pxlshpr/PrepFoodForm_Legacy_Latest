import FoodLabelScanner
import PrepDataTypes

extension ScanResult.Headers {
    var serving: HeaderText.Serving? {
        if header1Type == .perServing {
            return headerText1?.serving
        } else if header2Type == .perServing {
            return headerText2?.serving
        } else {
            return nil
        }
    }
}

extension FoodLabelUnit {
    func isCompatibleForDensity(with other: FoodLabelUnit) -> Bool {
        guard let unitType, let otherUnitType = other.unitType else {
            return false
        }
        return (unitType == .weight && otherUnitType == .volume)
        ||
        (unitType == .volume && otherUnitType == .weight)
    }
    
    var unitType: UnitType? {
        switch self {
        case .cup, .ml, .tbsp:
            return .volume
        case .mcg, .mg, .g, .oz:
            return .weight
        default:
            return nil
        }
    }
    
    var weightFormUnit: FormUnit? {
        switch self {
        case .mcg:
            return nil /// Not yet supported
        case .mg:
            return .weight(.mg)
        case .g:
            return .weight(.g)
        case .oz:
            return .weight(.oz)
        default:
            return nil
        }
    }
    
    var volumeFormUnit: FormUnit? {
        switch self {
        case .cup:
            return .volume(.cup)
        case .ml:
            return .volume(.mL)
        case .tbsp:
            return .volume(.tablespoon)
        default:
            return nil
        }
    }
}
extension ScanResult {
    func headerDoubleValue(for column: Int) -> FieldValue.DoubleValue? {
        guard let headerAmount = headerAmount(for: column),
              let headerValueText = headerValueText(for: column)
        else {
            return nil
        }
        return FieldValue.DoubleValue(
            double: headerAmount,
            string: headerAmount.cleanAmount,
            unit: headerFormUnit(for: column),
            fill: scannedFill(
                for: headerValueText,
                value: FoodLabelValue(
                    amount: headerAmount,
                    unit: headerFormUnit(for: column).foodLabelUnit
                )
            )
        )
    }
    
    func amountValueText(for column: Int) -> ValueText? {
        if let servingAmountValueText {
            return servingAmountValueText
        } else {
            return headerValueText(for: column)
        }
    }
    
    var headerServingValueText: ValueText? {
        guard let headers else { return nil }
        if headers.header1Type == .perServing {
            return headers.headerText1?.text.asValueText
        } else if headers.header2Type == .perServing {
            return headers.headerText2?.text.asValueText
        } else {
            return nil
        }
    }
    
    var headerServingAmount: Double? {
        return headers?.serving?.amount
    }
    
    func headerAmount(for column: Int) -> Double? {
        guard let headerType = headerType(for: column) else {
            return nil
        }
        switch headerType {
        case .per100g, .per100ml:
            return 100
        case .perServing:
            return headerServingAmount
        }
    }

    func headerText(for column: Int) -> HeaderText? {
        column == 1 ? headers?.headerText1 : headers?.headerText2
    }
    
    func headerValueText(for column: Int) -> ValueText? {
        guard let headerText = headerText(for: column) else { return nil }
        return headerText.text.asValueText
    }
    
    func headerType(for column: Int) -> HeaderType? {
        column == 1 ? headers?.header1Type : headers?.header2Type
    }
    
    func headerFormUnit(for column: Int) -> FormUnit {
        guard let headerType = headerType(for: column) else {
            return .serving
        }
        
        switch headerType {
        case .per100g:
            return .weight(.g)
        case .per100ml:
            return .volume(.mL)
        case .perServing:
            return headerServingFormUnit
        }
    }

    var headerServingFormUnit: FormUnit {
        if let headerServingUnitName {
            let size = FormSize(
                name: headerServingUnitName,
                amount: headerServingUnitAmount,
                unit: headerServingUnitSizeUnit
            )
            return .size(size, nil)
        } else {
            return headerServingUnit?.formUnit ?? .weight(.g)
        }
    }
    
    var headerServingUnitName: String? {
        headers?.serving?.unitName
    }
    
    var headerServingUnitAmount: Double {
        if let headerEquivalentSize {
            return headerEquivalentSize.amount
        } else {
            return headers?.serving?.amount ?? 1
        }
    }
    
    var headerServingUnitSizeUnit: FormUnit {
        headerEquivalentSizeFormUnit ?? .serving
    }
    
    var headerServingUnit: FoodLabelUnit? {
        headers?.serving?.unit
    }

    var headerEquivalentSize: HeaderText.Serving.EquivalentSize? {
        headers?.serving?.equivalentSize
    }
    var servingFormUnit: FormUnit {
        if let servingUnitNameText {
            let size = FormSize(
                name: servingUnitNameText.string,
                amount: servingUnitAmount,
                unit: servingUnitSizeUnit
            )
            return .size(size, nil)
        } else {
            return servingUnit?.formUnit ?? .weight(.g)
        }
    }

    var servingUnitAmount: Double {
        if let equivalentSize {
            return equivalentSize.amount
        } else {
            return servingAmount ?? 1
        }
    }
    
    var servingUnitSizeUnit: FormUnit {
        equivalentSizeFormUnit ?? .serving
    }
    
    var equivalentSizeFormUnit: FormUnit? {
        if let equivalentSizeUnitSize {
            return .size(equivalentSizeUnitSize, nil)
        } else {
            return equivalentSize?.unit?.formUnit ?? .weight(.g)
        }
    }
    
    var headerEquivalentSizeFormUnit: FormUnit? {
        if let headerEquivalentSizeUnitSize {
            return .size(headerEquivalentSizeUnitSize, nil)
        } else {
            return headerEquivalentSize?.unit?.formUnit ?? .weight(.g)
        }
    }
    
    var headerEquivalentSizeUnitSize: FormSize? {
        guard let headerEquivalentSize, headerEquivalentSize.amount > 0,
              let headerServingAmount, headerServingAmount > 0
        else {
            return nil
        }
        
        if let unitName = headerEquivalentSize.unitName {
            return FormSize(
                name: unitName,
                amount: 1.0/headerServingAmount/headerEquivalentSize.amount,
                unit: .serving)
        } else {
            return nil
        }
    }
    
    var equivalentSizeUnitSize: FormSize? {
        guard let equivalentSize, equivalentSize.amount > 0,
              let servingAmount, servingAmount > 0
        else {
            return nil
        }
        
        if let unitNameText = equivalentSize.unitNameText {
            return FormSize(
                name: unitNameText.string,
                amount: 1.0/servingAmount/equivalentSize.amount,
                unit: .serving)
        } else {
            return nil
        }
    }
    
    var servingAmount: Double? {
        serving?.amount
    }
    
    var servingUnitNameText: StringText? {
        serving?.unitNameText
    }
    
    var servingUnit: FoodLabelUnit? {
        serving?.unit
    }
    var equivalentSize: ScanResult.Serving.EquivalentSize? {
        serving?.equivalentSize
    }
}

import VisionSugar

extension ScanResult {
    var textsWithFoodLabelValues: [RecognizedText] {
        texts.filter { $0.hasFoodLabelValues }
    }

    var textsWithoutFoodLabelValues: [RecognizedText] {
        texts.filter { !$0.hasFoodLabelValues }
    }

    var textsWithDensities: [RecognizedText] {
        texts.filter { $0.densityValue != nil }
    }
}
