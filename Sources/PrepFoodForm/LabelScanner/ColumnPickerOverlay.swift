import SwiftUI
import SwiftHaptics

struct ColumnPickerOverlay: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Binding var isVisibleBinding: Bool
    @Binding var selectedColumn: Int
    var didTapDismiss: (() -> ())?
    let didTapAutofill: () -> ()
    
    var body: some View {
        VStack {
            if isVisibleBinding {
                title
                    .transition(.move(edge: .top))
            }
            Spacer()
            if isVisibleBinding {
                bottomVStack
                    .transition(.move(edge: .bottom))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 50)
        .edgesIgnoringSafeArea(.all)
    }
    
    var bottomVStack: some View {
        VStack {
            dismissButtonRow
            segmentedPicker
            autoFillButton
        }
    }
    
    var segmentedPicker: some View {
        ZStack {
            background
            button
            texts
        }
        .frame(height: 50)
    }
    
    var r: CGFloat { 3 }
    
    var innerTopLeftShadowColor: Color {
        colorScheme == .light
        ? Color(red: 197/255, green: 197/255, blue: 197/255)
        : Color(hex: "232323")
    }

    var innerBottomRightShadowColor: Color {
        colorScheme == .light
        ? Color.white
        : Color(hex: "3D3E44")
    }

    var backgroundColor: Color {
        colorScheme == .light
        ? Color(red: 236/255, green: 234/255, blue: 235/255)
        : Color(hex: "303136")
    }
    
    var background: some View {
        RoundedRectangle(cornerRadius: 15, style: .continuous)
            .fill(
                .shadow(.inner(color: innerTopLeftShadowColor,radius: r, x: r, y: r))
                .shadow(.inner(color: innerBottomRightShadowColor, radius: r, x: -r, y: -r))
            )
            .foregroundColor(backgroundColor)
    }
    
    var leftButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            withAnimation(.interactiveSpring()) {
                selectedColumn = 1
            }
        } label: {
            Text("Per Serving")
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundColor(selectedColumn == 1 ? .white : .secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
    }
    
    var rightButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            withAnimation(.interactiveSpring()) {
                selectedColumn = 2
            }
        } label: {
            Text("Per 100")
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundColor(selectedColumn == 2 ? .white : .secondary)
                .contentShape(Rectangle())
        }
    }
    
    var autoFillButton: some View {
        Button {
            didTapAutofill()
        } label: {
//            Text("Autofill this column")
            Text("Use this column")
                .font(.system(size: 22, weight: .semibold, design: .default))
//                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .foregroundStyle(Color.accentColor.gradient)
                        .shadow(color: .black, radius: 2, x: 0, y: 2)
                )
                .contentShape(Rectangle())
        }
    }
    
    var button: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .foregroundStyle(Color.accentColor.gradient)
            .shadow(color: innerTopLeftShadowColor, radius: 2, x: 0, y: 2)
            .padding(3)
            .frame(width: buttonWidth)
            .position(x: buttonXPosition, y: 25)
    }

    var texts: some View {
        HStack(spacing: 0) {
            VStack {
                leftButton
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            VStack {
                rightButton
            }
            .frame(minWidth: 0, maxWidth: .infinity)

        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
    
    var buttonWidth: CGFloat {
        (UIScreen.main.bounds.width - 40) / 2.0
    }
    
    var buttonXPosition: CGFloat {
        (buttonWidth / 2.0) + (selectedColumn == 2 ? buttonWidth : 0)
    }
    
    var title: some View {
        Text("Select a column")
            .font(.title3)
            .bold()
            .padding(.horizontal, 22)
//            .padding(.vertical, 20)
            .frame(height: 55)
            .foregroundColor(colorScheme == .light ? .primary : .secondary)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.clear)
                    .background(.ultraThinMaterial)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 15)
            )
            .shadow(radius: 3, x: 0, y: 3)
            .padding(.top, 62)
    }
    
    var dismissButtonRow: some View {
        HStack {
            Button {
                didTapDismiss?()
            } label: {
                Image(systemName: "chevron.down")
                    .imageScale(.medium)
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .light ? .primary : .secondary)
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .foregroundStyle(.ultraThinMaterial)
                            .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                    )
            }
            Spacer()
        }
    }
}
