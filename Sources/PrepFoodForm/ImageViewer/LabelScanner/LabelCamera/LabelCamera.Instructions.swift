import SwiftUI

extension LabelCamera {
    struct Instructions: View {
        let tappedStart: () -> ()
    }
}

extension LabelCamera.Instructions {
    
    var body: some View {
        ZStack {
            vstackBased
        }
        .frame(width: UIScreen.main.bounds.width)
        .edgesIgnoringSafeArea(.all)
    }

    var vstackBased: some View {
        VStack {
            instructionOne
            instructionTwo
            label
                .padding()
        }
        .padding(.top, 70)
        .padding(.bottom, 130)
    }
    
    var label: some View {
        var background: some View {
            var strokeForeground: some ShapeStyle {
                Material.thinMaterial
            }
            
            return ZStack {
//                RoundedRectangle(cornerRadius: 20, style: .continuous)
//                    .foregroundStyle(.ultraThinMaterial)
//                    .opacity(0.2)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .trim(from: 0.13, to: 0.19)
                    .stroke(strokeForeground, lineWidth: 10)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .trim(from: 0.31, to: 0.37)
                    .stroke(strokeForeground, lineWidth: 10)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .trim(from: 0.63, to: 0.69)
                    .stroke(strokeForeground, lineWidth: 10)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .trim(from: 0.81, to: 0.87)
                    .stroke(strokeForeground, lineWidth: 10)
            }
        }
        
        return Color.clear
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
            .background(
                background
            )
    }
    
    var instructionOne: some View {
        HStack {
            Image(systemName: "1.circle.fill")
                .foregroundStyle(Color(.secondaryLabel))
            Text("Make sure the food label is clearly visible")
                .foregroundColor(.secondary)
                .font(.callout)
                .fontWeight(.semibold)
                .frame(width: 250, alignment: .leading)
//                            .background(.green)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(
            Capsule(style: .continuous)
                .foregroundStyle(.regularMaterial)
        )
    }
    
    var instructionTwo: some View {
        HStack {
            Image(systemName: "2.circle.fill")
                .foregroundStyle(Color(.secondaryLabel))
            Text("Keep your phone steady until the scan is complete")
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.trailing)
                .font(.callout)
                .frame(width: 250, alignment: .leading)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(
            Capsule(style: .continuous)
                .foregroundStyle(.regularMaterial)
        )
    }
}
