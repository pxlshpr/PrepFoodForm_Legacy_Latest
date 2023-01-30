import SwiftUI
import PrepDataTypes

public struct ServingsAndSizesCell: View {
    
    @EnvironmentObject var fields: FoodForm.Fields
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            nutrientsPerContents
            densityContents
            sizesContents
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var nutrientsPerContents: some View {
        VStack(alignment: .leading) {
            Text("Nutrients Per")
                .font(.headline)
                .bold()
                .foregroundColor(.primary)
            HStack {
                Text(fields.amount.doubleValueDescription)
                    .foregroundColor(.primary)
                if let servingDescription {
                    Text("•")
                        .foregroundColor(Color(.quaternaryLabel))
                    Text(servingDescription)
                        .foregroundColor(.secondary)
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
                VStack(alignment: .leading) {
                    Text("Unit Conversion")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.tertiaryLabel))
                    Text("\(leftAmount) \(Text(leftUnit).foregroundColor(.secondary)) \(Text("↔").foregroundColor(Color(.quaternaryLabel))) \(rightAmount) \(Text(rightUnit).foregroundColor(.secondary))")
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    @ViewBuilder
    var sizesContents: some View {
        if !fields.allSizeFields.isEmpty {
            VStack(alignment: .leading) {
                Text("Sizes")
//                    .font(.headline)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.tertiaryLabel))
                ForEach(fields.allSizeFields, id: \.self) { sizeField in
                    Text("\(sizeField.sizeNameString.capitalized) • \(Text("\(sizeField.sizeAmountDescription)").foregroundColor(.secondary))")
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    var servingDescription: String? {
        fields.serving.value.isEmpty ? nil : fields.serving.doubleValueDescription
    }
}
