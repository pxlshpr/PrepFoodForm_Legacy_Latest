import SwiftUI

struct FormInlineDoneButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    let disabled: Bool
    let onTap: () -> ()
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Image(systemName: "checkmark")
                .bold()
                .foregroundColor(foregroundColor)
                .frame(width: 38, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 19)
                        .foregroundStyle(Color.accentColor.gradient)
                        .shadow(color: Color(.black).opacity(0.2), radius: 2, x: 0, y: 2)
                )
        }
        .disabled(disabled)
        .opacity(disabled ? 0.2 : 1)
    }

    var foregroundColor: Color {
        (colorScheme == .light && disabled)
        ? .black
        : .white
    }
}

struct FormTextFieldClearButton: View {
    
    let isEmpty: Bool
    let onTap: () -> ()

    var body: some View {
        Button {
            onTap()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    Color(.tertiaryLabel),
                    Color(.tertiarySystemFill)
                )
        }
        .opacity(!isEmpty ? 1 : 0)
        .buttonStyle(.borderless)
        .padding(.trailing, 5)
    }
}
