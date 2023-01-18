import SwiftUI
import SwiftHaptics
import SwiftUISugar

let Bounce: Animation = .interactiveSpring(response: 0.35, dampingFraction: 0.66, blendDuration: 0.35)
let Bounce2: Animation = .easeInOut
let colorHexKeyboardLight = "CDD0D6"
let colorHexKeyboardDark = "303030"
let colorHexSearchTextFieldDark = "535355"
let colorHexSearchTextFieldLight = "FFFFFF"

public struct ValuesPickerOverlay: View {
    
    @Environment(\.colorScheme) var colorScheme
//    let colorScheme: ColorScheme = .dark
    
    @Binding var isVisibleBinding: Bool
    var didTapDismiss: (() -> ())?
    var didTapCheckmark: () -> ()
    let didTapAutofill: () -> ()
    
    @Namespace var namespace
    @State var showingAttributePicker = false
//    @State var showingTextField = false

    let attributesListAnimation: Animation = Bounce
//    let attributesListAnimation: Animation = Bounce2
//    let attributesListAnimation: Animation = .interactiveSpring()

    @ObservedObject var viewModel: ScannerViewModel
    
    public init(
        viewModel: ScannerViewModel,
        isVisibleBinding: Binding<Bool>,
        didTapDismiss: (() -> ())? = nil,
        didTapCheckmark: @escaping () -> (),
        didTapAutofill: @escaping () -> ()
    ) {
        self.viewModel = viewModel
        _isVisibleBinding = isVisibleBinding
        self.didTapDismiss = didTapDismiss
        self.didTapCheckmark = didTapCheckmark
        self.didTapAutofill = didTapAutofill
    }
    
    public var body: some View {
        ZStack {
//            if !viewModel.showingTextField {
            baseLayer
                .edgesIgnoringSafeArea(.all)
//            }
//            if showingAttributePicker {
//                attributeLayer
//            }
            if viewModel.showingTextField {
                searchLayer
                    .transition(.move(edge: .bottom))
            }
        }
        .sheet(isPresented: $showingAttributePicker) { attributePickerSheet }
    }
    
    var baseLayer: some View {
        VStack {
//            if isVisibleBinding {
//                title
//                    .transition(.move(edge: .top))
//                    .edgesIgnoringSafeArea(.all)
//            }
            Text("")
                .frame(maxWidth: .infinity)
                .frame(height: TopBarHeight)
                .background(.thinMaterial)
                .edgesIgnoringSafeArea(.all)
            Spacer()
            if isVisibleBinding {
                bottomVStack
                    .edgesIgnoringSafeArea(.all)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .background(.thinMaterial)
                .transition(.move(edge: .bottom))
            }
        }
    }
    
    var attributesList: some View {
        List {
            ForEach(viewModel.nutrients, id: \.self) {
                Text($0.attribute.description)
            }
        }
    }
    
    var attributePickerSheet: some View {
        NavigationStack {
            attributesList
                .navigationTitle("Nutrients")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
    
    var attributeLayer: some View {
        var dismissButton: some View {
            Button {
                Haptics.feedback(style: .soft)
                withAnimation(attributesListAnimation) {
                    showingAttributePicker = false
                }
            } label: {
                Image(systemName: "chevron.down")
                    .imageScale(.medium)
                    .fontWeight(.medium)
                    .foregroundColor(Color(.secondaryLabel))
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .foregroundStyle(.ultraThinMaterial)
                            .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                    )
            }
        }
        
        var background: some View {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundStyle(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                .matchedGeometryEffect(id: "rect", in: namespace)
        }
        
        var topBar: some View {
            HStack {
                Text("Nutrients")
                    .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                Spacer()
                dismissButton
            }
            .padding(.horizontal)
            .padding(.top)
        }
        
        return VStack {
            Spacer()
            ZStack {
                background
                VStack(spacing: 0) {
                    topBar
                    attributesList
                }
//                    .matchedGeometryEffect(id: "label", in: namespace)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 500)
        }
        .edgesIgnoringSafeArea(.all)
    }

    var keyboardColor: Color {
        colorScheme == .light ? Color(hex: colorHexKeyboardLight) : Color(hex: colorHexKeyboardDark)
    }
    
    
    var expandedTextFieldColor: Color {
        colorScheme == .light ? Color(hex: colorHexSearchTextFieldLight) : Color(hex: colorHexSearchTextFieldDark)
    }

    var textFieldBackground: some View {
        var width: CGFloat { UIScreen.main.bounds.width - 18 }
        var height: CGFloat { 48 }
        var xOffset: CGFloat { 0 }
        var foregroundColor: Color { expandedTextFieldColor }
        var background: some View { Color.clear }
        
        return RoundedRectangle(cornerRadius: 15, style: .circular)
            .foregroundColor(foregroundColor)
            .background(background)
            .frame(height: height)
            .frame(width: width)
            .offset(x: xOffset)
    }

    var textField: some View {
        TextField("Enter Value", text: .constant(""))
            .focused($isFocused)
            .keyboardType(.decimalPad)
            .onSubmit {
                withAnimation {
//                    HardcodedBounds = CGRectMake(0, 0, 430, HeightWithoutKeyboard)
                    viewModel.showingTextField = false
                }
                NotificationCenter.default.post(
                    name: .scannerDidDismissKeyboard,
                    object: nil,
                    userInfo: userInfoForAllAttributesZoom
                )
            }
    }

    var textFieldLabel: some View {
        Text("Polyunsaturated Fat")
            .foregroundColor(.secondary)
            .font(.footnote)
            .textCase(.uppercase)
            .padding(.vertical, 5)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .foregroundColor(Color(.secondarySystemBackground))
            )
    }
    
    var unitPicker: some View {
//        Menu {
//            Text("g")
//            Text("mg")
//        } label: {
            Text("mg")
//        }
    }

    var textFieldLayer: some View {
        
        var background: some View {
            keyboardColor
                .frame(maxWidth: .infinity)
                .frame(height: 65)
//                .fixedSize(horizontal: false, vertical: true)
                .edgesIgnoringSafeArea(.all)
        }
        
        
        return VStack {
            Spacer()
            ZStack {
                background
//                textFieldBackground
                HStack {
                    textField
                    Spacer()
                    unitPicker
                }
                .padding(.horizontal, 25)
            }
        }
    }
    
    var clearButton: some View {
        Button {
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(Color(.quaternaryLabel))
        }
//        .opacity((!searchText.isEmpty && isFocused) ? 1 : 0)
        .opacity(1)
    }

    func resignFocusOfSearchTextField() {
        isFocused = false
        withAnimation {
//            HardcodedBounds = CGRectMake(0, 0, 430, HeightWithoutKeyboard)
            viewModel.showingTextField = false
        }
        
//        guard let imageSize = viewModel.image?.size else { return }
//        let delay: CGFloat
//        if imageSize.isTaller(than: HardcodedBounds.size) {
//            print("⚱️ image is taller delay 0.3")
//            delay = 0.3
//        } else {
//            print("⚱️ image is wider delay 0")
//            delay = 0.0
//        }
//
//        //TODO: Only do this for tall images
//        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//            withAnimation {
//                viewModel.showingTextField = false
//            }
//        }
        NotificationCenter.default.post(
            name: .scannerDidDismissKeyboard,
            object: nil,
            userInfo: userInfoForAllAttributesZoom
        )
    }
    
    var buttonsLayer: some View {
        var bottomPadding: CGFloat { 70 }
        
        return VStack {
            Spacer()
            HStack {
                Button {
                } label: {
                    DismissButtonLabel()
                }
                .transition(.opacity)
                Spacer()
                Button {
                    Haptics.feedback(style: .soft)
                    resignFocusOfSearchTextField()
                } label: {
                    DismissButtonLabel(forKeyboard: true)
                }
                .transition(.opacity)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, bottomPadding)
            .frame(width: UIScreen.main.bounds.width)
        }
    }
    

    var searchLayer: some View {
        ZStack {
            VStack {
                Spacer()
                ZStack {
                    keyboardColor
                        .frame(height: 65)
                        .transition(.opacity)
                    Button {
                    } label: {
                        ZStack {
                            HStack {
                                textFieldBackground
                            }
                            .padding(.leading, 0)
                            HStack {
                                Spacer()
                                HStack(spacing: 5) {
                                    ZStack {
                                        HStack {
//                                            textFieldLabel
                                            textField
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Spacer()
                                            unitPicker
                                            clearButton
                                        }
                                    }
                                }
//                                    accessoryViews
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(.horizontal, 7)
                }
                .background(
                    Group {
                         keyboardColor
                            .edgesIgnoringSafeArea(.bottom)
                    }
                )
            }
            .zIndex(10)
            .transition(.move(edge: .bottom))
            buttonsLayer
        }
//        .onWillResignActive {
//            if isFocused {
//                withAnimation {
//                    isHidingSearchViewsInBackground = true
//                }
//                resignFocusOfSearchTextField()
//            }
//        }
//        .onDidBecomeActive {
//            if isHidingSearchViewsInBackground {
//                focusOnSearchTextField()
//                withAnimation {
//                    isHidingSearchViewsInBackground = false
//                }
//            }
//        }
    }
    
    @FocusState var isFocused: Bool
    
    var title: some View {
        Text("Select nutrients")
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
            .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
//            .shadow(radius: 3, x: 0, y: 3)
            .padding(.top, 62)
    }
    
    var bottomVStack: some View {
        VStack {
//            HStack {
//                valueButton
//            }
//            HStack {
//                altValuesSlider
//            }
            HStack {
//                leftButton
                attributeButton
                valueButton
                rightButton
            }
            Spacer()
        }
        .frame(height: 346)
    }
    
    var userInfoForCurrentAttributeZoom: [String: Any]? {
        guard let imageSize = viewModel.image?.size,
              let attributeText = viewModel.currentAttributeText
        else { return nil }
        
        var boundingBox = attributeText.boundingBox
        if let valueText = viewModel.currentValueText {
            boundingBox = boundingBox.union(valueText.boundingBox)
        }
        
        let zBox = ZBox(boundingBox: boundingBox, imageSize: imageSize)
        return [Notification.ZoomableScrollViewKeys.zoomBox: zBox]
    }

    var userInfoForAllAttributesZoom: [String: Any]? {
        guard let imageSize = viewModel.image?.size,
              let boundingBox = viewModel.scanResult?.columnsWithAttributesBoundingBox
        else { return nil }
        let zBox = ZBox(boundingBox: boundingBox, imageSize: imageSize)
        return [Notification.ZoomableScrollViewKeys.zoomBox: zBox]
    }

    var valueButton: some View {
        var amountColor: Color {
//            Color.white
            Color.primary
        }
        
        var unitColor: Color {
//            Color.white.opacity(0.9)
            Color.secondary
        }
        
        var backgroundStyle: some ShapeStyle {
//            Color.accentColor.gradient
            Color(.secondarySystemFill)
        }
        
        return Button {
            Haptics.feedback(style: .soft)
            isFocused = true
            withAnimation {
//                HardcodedBounds = CGRectMake(0, 0, 430, HeightWithKeyboard)
                viewModel.showingTextField = true
            }
            NotificationCenter.default.post(
                name: .scannerDidPresentKeyboard,
                object: nil,
                userInfo: userInfoForCurrentAttributeZoom
            )
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(viewModel.currentAmountString)
                    .foregroundColor(amountColor)
                Text(viewModel.currentUnitString)
                    .foregroundColor(unitColor)
                    .font(.system(size: 18, weight: .medium, design: .default))
            }
            .font(.system(size: 22, weight: .semibold, design: .default))
            .padding(.horizontal)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundStyle(backgroundStyle)
                    .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
            )
            .contentShape(Rectangle())
        }
    }
    
    let dummyAltValues: [String] = [
        "223 mcg",
        "23 mg",
        "22 g",
        "18.1 g",
        "181 g",
        "1.1 g",
        "18 g",
    ]
    
    var altValuesSlider: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(dummyAltValues, id: \.self) { altValue in
                    Button {
                        Haptics.feedback(style: .soft)
                    } label: {
                        Text(altValue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .foregroundStyle(Color(.secondarySystemFill))
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundStyle(Color(.quaternarySystemFill))
                .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
        )
    }
    
    
    var rightButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            didTapCheckmark()
        } label: {
            Image(systemName: "checkmark")
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .frame(height: 50)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
//                        .foregroundStyle(Color(.tertiarySystemFill))
                        .foregroundStyle(Color.green.gradient)
//                        .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                )
                .contentShape(Rectangle())
        }
    }

    var attributeButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            withAnimation(attributesListAnimation) {
                showingAttributePicker = true
            }
        } label: {
            VStack {
                Text(viewModel.currentAttribute.description)
                    .font(.title3)
                    .minimumScaleFactor(0.2)
                    .lineLimit(2)
                    .matchedGeometryEffect(id: "label", in: namespace)
            }
            .foregroundColor(.primary)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundStyle(Color(.secondarySystemFill))
                    .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                    .matchedGeometryEffect(id: "rect", in: namespace)
            )
            .contentShape(Rectangle())
        }
    }
}


public struct ValuesPickerOverlayPreview: View {
    @State var selectedColumn: Int = 1
    
    @StateObject var viewModel: ScannerViewModel = ScannerViewModel()
    
    public init() { }
    public var body: some View {
        ZStack {
            Color(.systemBackground)
            overlay
        }
    }
    
    var overlay: some View {
        ValuesPickerOverlay(
            viewModel: viewModel,
            isVisibleBinding: .constant(true),
            didTapDismiss: {},
            didTapCheckmark: {},
            didTapAutofill: {}
        )
    }
}

struct ValuesPickerOverlay_Preview: PreviewProvider {
    
    static var previews: some View {
        ValuesPickerOverlayPreview()
    }
}
