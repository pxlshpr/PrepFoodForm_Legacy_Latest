import SwiftUI

extension SizeForm {
    func button(_ string: String, placeholder: String = "", action: @escaping () -> ()) -> some View {
        var background: some View {
            var color: Color {
                string.isEmpty ? Color(.tertiarySystemFill) : .accentColor
            }
            
            var opacity: CGFloat {
                string.isEmpty
                ? 1.0
                : colorScheme == .dark ? 0.1 : 0.15
            }
            
            return RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(color.opacity(opacity))
        }
        
        return Button {
            action()
        } label: {
            Group {
                if string.isEmpty {
                    HStack(spacing: 5) {
                        Text(placeholder)
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                } else {
                    Text(string)
                }
            }
//            .foregroundColor(.accentColor)
            .frame(maxHeight: .infinity)
            
            .foregroundColor(.accentColor)
            .padding(.horizontal, viewModel.showingVolumePrefix ? 8 : 12)
            .frame(minWidth: 44)
//            .frame(height: 40)
            .background(
                background
            )

            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }

    func symbol(_ string: String) -> some View {
        Text(string)
            .font(.title3)
            .foregroundColor(Color(.tertiaryLabel))
    }
}
