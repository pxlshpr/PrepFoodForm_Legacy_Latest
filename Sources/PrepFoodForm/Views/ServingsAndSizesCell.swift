import SwiftUI
import PrepDataTypes

public struct ServingsAndSizesCell: View {
    
    @EnvironmentObject var fields: FoodForm.Fields
    
    public var body: some View {
        VStack(alignment: .leading) {
            nutrientsPerContents
            densityContents
            sizesContents
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var nutrientsPerContents: some View {
//        VStack(alignment: .leading) {
//            Text("Nutrients Per")
//                .font(.headline)
//                .bold()
//                .foregroundColor(.primary)
//            HStack {
//                Text(fields.amount.doubleValueDescription)
//                    .foregroundColor(.primary)
//                if let servingDescription {
//                    Text("•")
//                        .foregroundColor(Color(.quaternaryLabel))
//                    Text(servingDescription)
//                        .foregroundColor(.secondary)
//                }
//            }
//        }
        VStack(alignment: .leading, spacing: 3) {
            Text("Nutrients Per")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundColor(Color(.secondaryLabel))
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("1")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("serving")
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundColor(.primary)
                }
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("of")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundColor(Color(.secondaryLabel))
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .foregroundColor(Color(.tertiarySystemFill))
                        )
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("0.25")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text("cup")
                            .font(.system(.body, design: .rounded, weight: .medium))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }
            }
        }

    }

    var densityContents: some View {
        
        var leftValue: FieldValue.DoubleValue {
            fields.isWeightBased
            ? fields.density.value.weight
            : fields.density.value.volume
        }

        var rightValue: FieldValue.DoubleValue {
            fields.isWeightBased
            ? fields.density.value.volume
            : fields.density.value.weight
        }

        var leftAmount: String {
            leftValue.double?.cleanAmount ?? ""
        }
        var rightAmount: String {
            rightValue.double?.cleanAmount ?? ""
        }
        var leftUnit: String {
            leftValue.unit.shortDescription
        }
        var rightUnit: String {
            rightValue.unit.shortDescription
        }

        return Group {
            if fields.hasValidDensity {
                Divider()
//                VStack(alignment: .leading) {
//                    Text("Unit Conversion")
//                        .font(.subheadline)
//                        .fontWeight(.semibold)
//                        .foregroundColor(Color(.tertiaryLabel))
//                    Text("\(leftAmount) \(Text(leftUnit).foregroundColor(.secondary)) \(Text("↔").foregroundColor(Color(.quaternaryLabel))) \(rightAmount) \(Text(rightUnit).foregroundColor(.secondary))")
//                        .foregroundColor(.primary)
//                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Unit Conversion")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundColor(Color(.tertiaryLabel))
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("0.25")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text("cup")
                                .font(.system(.footnote, design: .rounded, weight: .medium))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text("↔")
                                .font(.system(.footnote, design: .rounded, weight: .semibold))
                                .foregroundColor(Color(.secondaryLabel))
                                .padding(.vertical, 3)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .foregroundColor(Color(.tertiarySystemFill))
                                )
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("30")
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .foregroundColor(.secondary)
                                Text("g")
                                    .font(.system(.footnote, design: .rounded, weight: .medium))
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var sizesContents: some View {
        if !fields.allSizeFields.isEmpty {
            Divider()
//            VStack(alignment: .leading) {
//                Text("Sizes")
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(Color(.tertiaryLabel))
//                ForEach(fields.allSizeFields, id: \.self) { sizeField in
//                    Text("\(sizeField.sizeNameString.capitalized) • \(Text("\(sizeField.sizeAmountDescription)").foregroundColor(.secondary))")
//                        .foregroundColor(.primary)
//                }
//            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Sizes")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundColor(Color(.tertiaryLabel))
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text("Balls")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundColor(.secondary)
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("3")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text("g")
                                .font(.system(.footnote, design: .rounded, weight: .medium))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .foregroundColor(Color(.tertiarySystemFill))
                        )
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text("Container")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundColor(.secondary)
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("11")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text("balls")
                                .font(.system(.footnote, design: .rounded, weight: .medium))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .foregroundColor(Color(.tertiarySystemFill))
                        )
                    }                }
            }
        }
    }
    
    var servingDescription: String? {
        fields.serving.value.isEmpty ? nil : fields.serving.doubleValueDescription
    }
}
