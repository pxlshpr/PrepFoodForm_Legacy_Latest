import SwiftUI
import PrepDataTypes
import ActivityIndicatorView

extension FoodForm.NutrientsList {
    struct Cell: View {
        @Environment(\.colorScheme) var colorScheme
        @EnvironmentObject var fields: FoodForm.Fields
        @ObservedObject var field: Field
        @Binding var showImage: Bool
    }
}

extension FoodForm.NutrientsList.Cell {
    
    var body: some View {
        ZStack {
            content
            if showImage {
                imageLayer
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 13)
        .padding(.top, 13)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding(.bottom, 10)
    }
    
    var content: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                topRow
                bottomRow
            }
        }
    }
    
    //MARK: - Components
    
    var topRow: some View {
        HStack {
            Spacer().frame(width: 2)
            HStack(spacing: 4) {
                Image(systemName: field.value.iconImageName)
                    .font(.system(size: 14))
                Text(field.value.description)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            Spacer()
            fillTypeIcon
            disclosureArrow
        }
        .foregroundColor(field.value.labelColor(for: colorScheme))
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
            amountText
                .multilineTextAlignment(.leading)
            if !isEmpty {
                unitText
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    var fillTypeIcon: some View {
        if fields.hasNonUserInputFills, !isEmpty {
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
            } else if field.fill.usesImage {
                activityIndicator
            }
        }
    }
    
    //MARK: Convenience
    
    var isEmpty: Bool {
        field.value.double == nil
    }
}
