import SwiftUI
import SwiftUISugar
import SwiftHaptics

struct SaveSheet: View {
    
    @EnvironmentObject var fields: FoodForm.Fields
    @EnvironmentObject var sources: FoodForm.Sources
    
    @Environment(\.colorScheme) var colorScheme
    @State var size: CGSize = .zero
    @State var safeAreaInsets: EdgeInsets = .init()
    @State var height: CGFloat = 0

    @Binding var isPresented: Bool
    @Binding var validationMessage: ValidationMessage?
    let didTapSavePublic: () -> ()
    let didTapSavePrivate: () -> ()

    let hardcodedSafeAreaBottomInset: CGFloat = 34.0
    
    @State var dragOffsetY: CGFloat = 0.0

    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(colorScheme == .light ? 0.2 : 0.5)
                    .transition(.opacity)
                    .edgesIgnoringSafeArea(.all)
                shadowLayer
                    .edgesIgnoringSafeArea(.all)
            }
            if isPresented {
                VStack {
                    Spacer()
                    sheet
                }
                .edgesIgnoringSafeArea(.all)
                .transition(.move(edge: .bottom))
            }
        }
    }
    
    var shadowLayer: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Spacer()
                ZStack {
                    VStack {
                        Rectangle()
                            .fill(.green)
                            .frame(height: 210)
                            .shadow(radius: 70.0, y: 0)
                            .position(x: proxy.size.width / 2.0, y: 210 + 70.0 + 35)
                        Spacer()
                    }
                }
                .frame(height: 210)
                .clipped()
                .offset(y: dragOffsetY)
                Color.clear
                    .frame(height: height + 38.0 - 10.0) /// not sure what the 38 is, 10 is corner radius
            }
        }
    }
    
    var sheet: some View {
        contents
            .readSafeAreaInsets { insets in
                safeAreaInsets = insets
            }
            .onChange(of: size) { newValue in
                self.height = calculatedHeight
            }
            .onChange(of: safeAreaInsets) { newValue in
                self.height = calculatedHeight
            }
            .onChange(of: colorScheme) { newValue in
                /// Workaround for a bug where color scheme changes shifts the presented sheet downwards for some reason
                /// (This seems to happen only when we have a dynamic height—even if we're not actually changing the height)
                height = height + 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    height = height - 1
                }
            }
            .safeAreaInset(edge: .bottom) {
                Spacer().frame(height: hardcodedSafeAreaBottomInset)
            }
            .gesture(dragGesture)
    }
    
    var dragGesture: some Gesture {
        func logC(val: Double, forBase base: Double) -> Double {
            return log(val)/log(base)
        }
        
        func changed(_ value: DragGesture.Value) {
            let y = value.translation.height
//            guard y < 0 else {
            guard y < -22 else {
                dragOffsetY = y
                return
            }
            let log = logC(val: (-y) + 11.5, forBase: 1.05) - 50
            dragOffsetY = -log
        }
        
        func ended(_ value: DragGesture.Value) {
            withAnimation {
                dragOffsetY = 0.0
            }
        }
        
        return DragGesture()
            .onChanged(changed)
            .onEnded(ended)
    }

    var contents: some View {
        ZStack {
            FormBackground()
                .cornerRadius(10.0, corners: [.topLeft, .topRight])
                .edgesIgnoringSafeArea(.all)
                .frame(height: height)
                .offset(y: max(0, dragOffsetY))
//            shadowLayer
            form
//                .edgesIgnoringSafeArea(.bottom)
                .frame(height: height)
                .offset(y: dragOffsetY)
        }
    }
    
    var form: some View {
        var closeButton: some View {
            Button {
                Haptics.feedback(style: .soft)
                withAnimation {
                    isPresented = false
                }
            } label: {
                CloseButtonLabel()
            }
        }

        var topRow: some View {
            HStack {
                Text("Save")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .padding(.top, 5)
                Spacer()
                closeButton
            }
            .frame(height: 30)
            .padding(.leading, 20)
            .padding(.trailing, 14)
            .padding(.top, 12)
            .padding(.bottom, 18)
        }
        
        var content: some View {
//            GeometryReader { proxy in
                VStack(spacing: 0) {
                    topRow
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
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
                .background(
                    FormBackground()
                        .edgesIgnoringSafeArea(.all)
                        .cornerRadius(10.0)
                )
//                .frame(height: proxy.size.height, alignment: .top)
//            }
        }
        
        return content
    }
    
    var quickForm: some View {
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

    var calculatedHeight: CGFloat {
        size.height + 60.0
    }

    var saveIsDisabled: Binding<Bool> {
        Binding<Bool>(
            get: { sources.numberOfSources == 0 || !fields.hasMinimumRequiredFields },
            set: { _ in }
        )
    }
    
    var saveSecondaryIsDisabled: Binding<Bool> {
        Binding<Bool>(
            //TODO: Save Override
            get: { false },
//            get: { !fields.hasMinimumRequiredFields },
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
            didTapSavePublic()
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
            didTapSavePrivate()
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
                Text("Provide a source if you'd like to submit this as a Verified Food, or add it as a private food visible only to you.")
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

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
