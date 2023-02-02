import SwiftUI

struct SaveSheet: View {
    
    @EnvironmentObject var fields: FoodForm.Fields
    @EnvironmentObject var sources: FoodForm.Sources
    @Binding var validationMessage: ValidationMessage?

    @Environment(\.colorScheme) var colorScheme
    @State var size: CGSize = .zero
    @State var safeAreaInsets: EdgeInsets = .init()

    @State var height: CGFloat = 0
    @State var heightCopy: CGFloat = 0

    @State var refresh: Bool = false
    
    var body: some View {
        return contents
            .id(refresh)
            .readSafeAreaInsets { insets in
                safeAreaInsets = insets
            }
            .presentationDetents([.height(height)])
            .presentationDragIndicator(.hidden)
            .onChange(of: size) { newValue in
                if self.height == 0 {
                    self.height = calculatedHeight
                    self.heightCopy = self.height
                }
            }
            .onChange(of: safeAreaInsets) { newValue in
                if self.height == 0 {
                    self.height = calculatedHeight
                    self.heightCopy = self.height
                }
            }
            .onChange(of: colorScheme) { newValue in
                /// Workaround for a bug where color scheme changes shifts the presented sheet downwards for some reason
                /// (This seems to happen only when we have a dynamic height—even if we're not actually changing the height)
                height = height + 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    height = height - 1
                }
            }
    }
    
    var calculatedHeight: CGFloat {
        
        let height = size.height + 60.0
        print("👨🏽‍🚀 height: \(height) = size.height: \(size.height) + safeAreaInsets.bottom: \(safeAreaInsets.bottom)")
        return height
    }

    var contents: some View {
        QuickForm(title: "Save") {
            VStack {
                if let validationMessage {
                    validationInfo(validationMessage)
                }
                publicButton
                privateButton
            }
            .readSize { size in
                self.size = size
            }
        }
    }
    
    var saveIsDisabled: Binding<Bool> {
        Binding<Bool>(
            get: { sources.numberOfSources == 0 || !fields.hasMinimumRequiredFields },
            set: { _ in }
        )
    }
    
    var saveSecondaryIsDisabled: Binding<Bool> {
        Binding<Bool>(
            get: { !fields.hasMinimumRequiredFields },
            set: { _ in }
        )
    }
    
    var buttonWidth: CGFloat { UIScreen.main.bounds.width - (20 * 2) }
    var buttonHeight: CGFloat { 52 }
    var buttonCornerRadius: CGFloat { 10 }
    var shadowSize: CGFloat { 2 }
    var shadowOpacity: CGFloat { 0.2 }
    
    var saveTitle: String {
        /// [ ] Do this
        //            if isEditingPublicFood {
        //                return "Resubmit to Public Foods"
        //            } else {
        //                return "Submit to Public Foods"
        //                return "Submit as Public Food"
        return "Submit as Verified Food"
        //            }
    }
    
    var saveSecondaryTitle: String {
        /// [ ] Do this
        //            if isEditingPublicFood {
        //                return "Save and Make Private"
        //            } else if isEditingPrivateFood {
        //                return "Save Private Food"
        //            } else {
        return "Add as Private Food"
        //            return "Save as Private Food"
        //            }
    }
    
    var publicButton: some View {
        var foregroundColor: Color {
            (colorScheme == .light && saveIsDisabled.wrappedValue) ? .black : .white
        }
        
        var opacity: CGFloat {
            saveIsDisabled.wrappedValue ? (colorScheme == .light ? 0.2 : 0.2) : 1
        }
        
        return Button {
            
        } label: {
            Text(saveTitle)
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
        .disabled(saveIsDisabled.wrappedValue)
        .opacity(opacity)
    }
    
    var privateButton: some View {
        var foregroundColor: Color {
            (colorScheme == .light && saveSecondaryIsDisabled.wrappedValue) ? .black : .white
        }
        
        var opacity: CGFloat {
            saveSecondaryIsDisabled.wrappedValue ? (colorScheme == .light ? 0.2 : 0.2) : 1
        }
        
        return Button {
            
        } label: {
            Text(saveSecondaryTitle)
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
        .disabled(saveSecondaryIsDisabled.wrappedValue)
        .opacity(opacity)
    }
    
    func validationInfo(_ validationMessage: ValidationMessage) -> some View {
        let fill: Color = colorScheme == .light
//        ? Color(hex: "EFEFF0")
        ? Color(.quaternarySystemFill)
        : Color(.secondarySystemFill)
        
        return VStack {
            
            switch validationMessage {
            case .needsSource:
                Text("Provide a source if you'd like to submit this as a Verified Food, or add it as a private food only visible to you.")
                    .fixedSize(horizontal: false, vertical: true)
            case .missingFields(let fieldNames):
                if let fieldName = fieldNames.first, fieldNames.count == 1 {
                    Text("Please fill in the \(Text(fieldName).bold()) value to be able to save this food.")
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    VStack(alignment: .leading) {
                        Text("Please fill in the following to be able to save this food:")
                            .fixedSize(horizontal: false, vertical: true)
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
                .foregroundColor(fill)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}