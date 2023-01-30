import SwiftUI
import PrepDataTypes
import ActivityIndicatorView
import SwiftUISugar

struct FieldCell: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var fields: FoodForm.Fields
    @ObservedObject var field: Field
    @Binding var showImage: Bool
    
    var body: some View {
        ZStack {
            content
//            if showImage {
//                imageLayer
//            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 13)
        .padding(.top, 13)
        .background(FormCellBackground())
        .cornerRadius(10)
        .frame(height: 100)
        .padding(.bottom, 10)
    }
    
    var content: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 20) {
                topRow
                Spacer()
            }
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                bottomRow
            }
        }
    }
    
    //MARK: - Components
    
    var topRow: some View {
        HStack {
            Spacer().frame(width: 2)
            HStack(spacing: 4) {
                if !field.value.iconImageName.isEmpty {
                    Image(systemName: field.value.iconImageName)
                        .font(.system(size: 14))
                }
                Text(field.value.description.capitalized)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .layoutPriority(1)
            Spacer()
            VStack {
                croppedImage
                    .frame(maxWidth: 200, alignment: .trailing)
//                    .frame(maxWidth: 150, alignment: .trailing)
                    .frame(maxHeight: 40, alignment: .top)
                    .grayscale(1.0)
                Spacer()
            }
//            fillTypeIcon
//            disclosureArrow
        }
        .foregroundColor(field.value.labelColor(for: colorScheme))
//        .background(.green.opacity(0.5))
    }
    
    var amountText: Text {
        Text(field.value.amountString)
            .foregroundColor(field.value.amountColor)
            .font(.system(size: field.value.isEmpty ? 20 : 28, weight: .medium, design: .rounded))
    }
    
    var unitText: Text {
        Text(field.value.unitString)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .bold()
            .foregroundColor(Color(.secondaryLabel))
    }
    
    var amountAndUnitText: some View {
        if !isEmpty {
            return amountText + unitText
        } else {
            return amountText
        }
    }
    
    var bottomRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            switch field.value {
            case .density(let densityValue):
                densityContents(densityValue)
            default:
                amountText
                if !isEmpty {
                    unitText
                }
            }
            Spacer()
        }
        .frame(height: 34)
//        .background(.yellow.opacity(0.5))
    }
    
    func densityContents(_ densityValue: FieldValue.DensityValue) -> some View {
        
        func stack(_ doubleValue: FieldValue.DoubleValue) -> some View {
            Group {
                Text(doubleValue.value?.amount.cleanAmount ?? "")
                    .foregroundColor(.primary)
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                Text(doubleValue.value?.unit?.description ?? "")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .bold()
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
        
        var weightStack: some View {
            stack(densityValue.weight)
        }

        var volumeStack: some View {
            stack(densityValue.volume)
        }

        return Group {
            if densityValue.isValid {
                if fields.isWeightBased {
                    weightStack
                } else {
                    volumeStack
                }
                Text("↔")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(.tertiaryLabel))
                if fields.isWeightBased {
                    volumeStack
                } else {
                    weightStack
                }
            } else {
                amountText
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    @ViewBuilder
    var fillTypeIcon: some View {
        if fields.hasNonUserInputFills, !isEmpty, field.fill != .userInput {
            Image(systemName: field.fill.iconSystemImage)
                .foregroundColor(Color(.secondaryLabel))
        }
    }
    
    var disclosureArrow: some View {
        Image(systemName: "chevron.forward")
            .font(.system(size: 14))
            .foregroundColor(Color(.tertiaryLabel))
            .fontWeight(.semibold)
    }
    
    //MARK: - Image
    
    var imageLayer: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                Spacer()
                VStack {
                    Spacer()
                    croppedImage
                    .frame(maxWidth: 200, alignment: .trailing)
                    .grayscale(1.0)
                }
                .frame(height: 40)
                .padding(.trailing, 16)
                .padding(.bottom, 6)
            }
        }
    }

    var croppedImage: some View {

        var activityIndicator: some View {
            ZStack {
                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots())
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }

        return Group {
            if let image = field.image {
                ZStack {
                    if field.isCropping {
                        activityIndicator
                    } else {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                            )
                            .shadow(radius: 3, x: 0, y: 3)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            } else if field.fill.usesImage {
                activityIndicator
            }
        }
    }
    
    //MARK: Convenience
    
    var isEmpty: Bool {
        switch field.value {
        case .density(let densityValue):
            return !densityValue.isValid
        case .size:
            return false
        default:
            return field.value.double == nil
        }
    }
}
