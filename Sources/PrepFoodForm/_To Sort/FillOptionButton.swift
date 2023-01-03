import SwiftUI

struct FillOptionButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let fillOption: FillOption
    let didTap: () -> ()
    
    init(fillOption: FillOption, didTap: @escaping () -> Void) {
        self.fillOption = fillOption
        self.didTap = didTap
    }

    var body: some View {
        Button {
            didTap()
        } label: {
            ZStack {
                Capsule(style: .continuous)
                    .foregroundColor(fillOption.backgroundColor(for: colorScheme))
                HStack(spacing: 5) {
                    Image(systemName: fillOption.systemImage)
                        .foregroundColor(fillOption.imageColor)
                        .imageScale(.small)
                        .frame(height: 25)
                    Text(fillOption.string)
                        .foregroundColor(fillOption.textColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
            }
            .fixedSize(horizontal: true, vertical: true)
            .contentShape(Rectangle())
//            .background(
//                RoundedRectangle(cornerRadius: 15, style: .continuous)
//                    .foregroundColor(isSelected.wrappedValue ? .accentColor : Color(.secondarySystemFill))
//            )
        }
        .grayscale(fillOption.isSelected ? 1 : 0)
        .disabled(fillOption.disableWhenSelected ? fillOption.isSelected : false)
    }
}

extension FillOption {
    var textColor: Color {
        switch type {
        case .select:
//            return .secondary
            return .accentColor
        case .fill:
            return isSelected ? .white : .primary
        }
    }
    
    var imageColor: Color {
        switch type {
        case .select:
//            return Color(.tertiaryLabel)
            return .accentColor
        case .fill:
            return isSelected ? .white : .secondary
        }
    }

    func backgroundColor(for colorScheme: ColorScheme) -> Color {
        let selectionColorDark = Color(hex: "6c6c6c")
        let selectionColorLight = Color(hex: "959596")

        switch type {
//        case .select:
//            return .accentColor
        case .fill, .select:
            guard isSelected else {
                return Color(.secondarySystemFill)
            }
            if disableWhenSelected {
                return .accentColor
            } else {
                return colorScheme == .light ? selectionColorLight : selectionColorDark
            }
        }
    }
}
