import SwiftUI
import SwiftUISugar
import FoodLabelScanner
import PhotosUI
import MFPScraper
import PrepDataTypes
import SwiftHaptics
import FoodLabelExtractor

struct TestView: View {
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        var saveIsDisabled: Bool { false }
        var saveSecondaryIsDisabled: Bool { false }

        var buttonWidth: CGFloat { UIScreen.main.bounds.width - (20 * 2) }
        var buttonHeight: CGFloat { 52 }
        var buttonCornerRadius: CGFloat { 10 }
        var shadowSize: CGFloat { 2 }
        var shadowOpacity: CGFloat { 0.2 }

        var publicButton: some View {
            var foregroundColor: Color {
                (colorScheme == .light && saveIsDisabled) ? .black : .white
            }
            
            var opacity: CGFloat {
                saveIsDisabled ? (colorScheme == .light ? 0.2 : 0.2) : 1
            }
            
            return Button {
                
            } label: {
                Text("Submit to Public Foods")
                    .bold()
                    .foregroundColor(foregroundColor)
                    .frame(width: buttonWidth, height: buttonHeight)
                    .background(
                        RoundedRectangle(cornerRadius: buttonCornerRadius)
                            .foregroundStyle(Color.accentColor.gradient)
                            .shadow(
                                color: Color(.black).opacity(shadowOpacity),
                                radius: shadowSize,
                                x: 0, y: shadowSize
                            )
                    )
            }
            .disabled(saveIsDisabled)
            .opacity(opacity)
        }
        
        var privateButton: some View {
            var foregroundColor: Color {
                (colorScheme == .light && saveSecondaryIsDisabled) ? .black : .white
            }
            
            var opacity: CGFloat {
                saveSecondaryIsDisabled ? (colorScheme == .light ? 0.2 : 0.2) : 1
            }
            
            return Button {
                
            } label: {
                Text("Add as Private Food")
                .frame(width: buttonWidth, height: buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: buttonCornerRadius)
                        .foregroundStyle(.ultraThinMaterial)
                        .shadow(
                            color: Color(.black).opacity(0.2),
                            radius: shadowSize,
                            x: 0, y: shadowSize
                        )
                        .opacity(0)
                )
            }
            .disabled(saveSecondaryIsDisabled)
            .opacity(opacity)
        }
        
        func infoButton(_ info: FormSaveInfo) -> some View {
            var titleColor: Color {
                info.tapHandler == nil ? Color(.tertiaryLabel) : .secondary
            }
            
            var label: some View {
                HStack {
                    if let systemImage = info.systemImage {
                        Image(systemName: systemImage)
                            .symbolRenderingMode(.multicolor)
                            .imageScale(.medium)
                            .fontWeight(.medium)
                    }
                    if let badge = info.badge {
                        Text("\(badge)")
                            .foregroundColor(Color(.secondaryLabel))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .frame(width: 25, height: 25)
                            .background(
                                Circle()
                                    .foregroundColor(Color(.secondarySystemFill))
                            )
                    }
                    Text(info.title)
                        .foregroundColor(titleColor)
                        .padding(.trailing, 3)
                }
                .padding(.horizontal, 12)
                .frame(height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 19)
                        .foregroundStyle(.ultraThinMaterial)
                        .shadow(color: Color(.black).opacity(shadowOpacity), radius: shadowSize, x: 0, y: shadowSize)
                )
            }
            
            func button(_ tapHandler: @escaping () -> ()) -> some View {
                Button {
                    tapHandler()
                } label: {
                    label
                }
            }
            
            return Group {
                if let tapHandler = info.tapHandler {
                    button(tapHandler)
                } else {
                    label
                }
            }
        }
        
        var validationInfo: some View {
            let r: CGFloat = 2.0
            
            let topLeft: Color = colorScheme == .light
            ? Color(red: 197/255, green: 197/255, blue: 197/255)
            : Color(hex: "050505")
//            : Color(hex: "131313")

            let bottomRight: Color = colorScheme == .light
            ? .white
//            : Color(hex: "5E5E5E")
            : Color(hex: "2A2A2C")

            let fill: Color = colorScheme == .light
            ? Color(red: 236/255, green: 234/255, blue: 235/255)
//            : Color(hex: "404040")
            : Color(.secondarySystemFill)

//            let validationMessage: ValidationMessage = .needsSource
//            let validationMessage: ValidationMessage = .missingFields(["Carbohydrate"])
            let validationMessage: ValidationMessage = .missingFields([
                "Name",
                "Carbohydrate"
            ])

            return VStack {
                
                switch validationMessage {
                case .needsSource:
                    Text("No source provided.")
                case .missingFields(let fieldNames):
                    if let fieldName = fieldNames.first, fieldNames.count == 1 {
                        Text("Please fill in the \(Text(fieldName).bold()) to be able to save this food.")
                    } else {
                        VStack(alignment: .leading) {
                            Text("Please fill in the following to be able to save this food:")
                                .padding(.bottom, 1)
                            ForEach(fieldNames, id: \.self) { fieldName in
                                Text("• \(fieldName)")
                                    .bold()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .foregroundColor(.secondary)
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            .shadow(.inner(color: topLeft, radius: r, x: r, y: r))
                            .shadow(.inner(color: bottomRight,radius: r, x: -r, y: -r))
                        )
                        .foregroundColor(fill)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 5)
        }
        
        return VStack {
            validationInfo
            publicButton
            privateButton
        }
    }
}

enum ValidationMessage {
    case needsSource
    case missingFields([String])
}

struct Temp_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
