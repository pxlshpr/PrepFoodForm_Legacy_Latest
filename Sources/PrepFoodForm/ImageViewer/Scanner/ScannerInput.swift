import SwiftUI
import SwiftHaptics
import SwiftUISugar
import ActivityIndicatorView
import FoodLabelScanner

public enum ScannerAction {
    case dismiss
    case confirmCurrentAttribute
    case showAttribute(Attribute)
    case toggleAttributeConfirmation(Attribute)
}

public struct ScannerInput: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var keyboardHeight: CGFloat
    var actionHandler: (ScannerAction) -> ()
//    var didTapDismiss: (() -> ())?
//    var didTapCheckmark: () -> ()
//    let didTapAutofill: () -> ()
    
    @Namespace var namespace
    @State var showingAttributePicker = false

    let attributesListAnimation: Animation = Bounce

    @ObservedObject var viewModel: ScannerViewModel
    
    let scannerDidChangeAttribute = NotificationCenter.default.publisher(for: .scannerDidChangeAttribute)
    
    public init(
        viewModel: ScannerViewModel,
        keyboardHeight: Binding<CGFloat>,
        actionHandler: @escaping (ScannerAction) -> ()
    ) {
        self.viewModel = viewModel
        _keyboardHeight = keyboardHeight
        self.actionHandler = actionHandler
    }
    
    func cell(for nutrient: ScannerNutrient) -> some View {
        var isConfirmed: Bool { nutrient.isConfirmed }
        var isCurrentAttribute: Bool { viewModel.currentAttribute == nutrient.attribute }
        var imageName: String {
            isConfirmed
//            ? "circle.inset.filled"
//            : "circle"
            ? "checkmark.square.fill"
            : "square"
        }
        var textColor: Color { isConfirmed ? .secondary : .primary }
        
        var listRowBackground: some View {
            isCurrentAttribute
            ? (colorScheme == .dark
               ? Color(.tertiarySystemFill)
               : Color(.systemFill)
            )
            : .clear
        }
        
        var hstack: some View {
            HStack(spacing: 0) {
                Button {
                    actionHandler(.showAttribute(nutrient.attribute))
                } label: {
                    HStack(spacing: 0) {
                        Text(nutrient.attribute.description)
                        Spacer()
                        Text(nutrient.value?.description ?? "")
                    }
                }
                Button {
                    actionHandler(.toggleAttributeConfirmation(nutrient.attribute))
                } label: {
                    Image(systemName: imageName)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 15)
                        .frame(maxHeight: .infinity)
                }
            }
            .foregroundColor(textColor)
            .foregroundColor(.primary)
        }
        
        return hstack
        .listRowBackground(listRowBackground)
        .listRowInsets(.init(top: 0, leading: 25, bottom: 0, trailing: 0))
    }
    
    public var body: some View {
        ZStack {
            contentsLayer
            if viewModel.state == .showingKeyboard {
                buttonsLayer
            }
        }
    }
    
    var contentsLayer: some View {
        VStack {
            Spacer()
            contents
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showingAttributePicker) { attributePickerSheet }
        .onChange(of: viewModel.state, perform: stateChanged)
    }
    
    @State var hideBackground: Bool = false
    
    var contents: some View {
        var background: some ShapeStyle {
//            .thinMaterial
            .thinMaterial.opacity(viewModel.state == .showingKeyboard ? 0 : 1)
//            Color.green.opacity(hideBackground ? 0 : 1)
        }
        
        return ZStack {
            if let description = viewModel.state.loadingDescription {
                loadingView(description)
            } else {
                pickerView
                    .transition(.move(edge: .top))
                    .zIndex(10)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: keyboardHeight + TopButtonPaddedHeight)
        .background(background)
        .clipped()
    }
    
    var buttonsLayer: some View {
        var bottomPadding: CGFloat { TopButtonPaddedHeight + 8.0 }
        
        var sideButtonsLayer: some View {
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
                    withAnimation {
                        if viewModel.containsUnconfirmedAttributes {
                            viewModel.state = .awaitingUserValidation
                        } else {
                            viewModel.state = .userValidationCompleted
                        }
                        hideBackground = false
                    }
                } label: {
                    DismissButtonLabel(forKeyboard: true)
                }
                .transition(.opacity)
            }
        }
        
        var centerButtonLayer: some View {
            HStack {
                Spacer()
                Text(viewModel.currentAttribute.description)
//                    .matchedGeometryEffect(id: "attributeName", in: namespace)
//                    .textCase(.uppercase)
                    .font(.system(.title3, design: .rounded, weight: .medium))
                    .foregroundColor(Color(.secondaryLabel))
//                    .frame(height: 38)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .foregroundStyle(.ultraThinMaterial)
                            .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                    )
                Spacer()
            }
            .padding(.horizontal, 38)
        }
        
        return VStack {
            Spacer()
            ZStack(alignment: .bottom) {
                centerButtonLayer
                sideButtonsLayer
            }
            .padding(.horizontal, 20)
            .padding(.bottom, bottomPadding)
            .frame(width: UIScreen.main.bounds.width)
        }
    }
    

    var listSection: some View {
        var sideButtons: some View {
            VStack {
                Text("OK")
                Spacer()
            }
            .frame(width: TopButtonWidth)
            .background(.yellow)
        }
        
        var addButton: some View {
            Image(systemName: "plus")
                .imageScale(.medium)
                .fontWeight(.medium)
                .foregroundColor(Color(.secondaryLabel))
                .frame(width: 38, height: 38)
                .background(
                    Circle()
//                        .foregroundStyle(.ultraThinMaterial)
                        .foregroundStyle(.thickMaterial)
                        .shadow(
                            color: colorScheme == .dark ? Color(.black).opacity(0.4) : Color(.black).opacity(0.2),
                            radius: 3, x: 0, y: 3)
                )
                .offset(x: -25, y: -10)
        }
        
        return ZStack(alignment: .bottomTrailing) {
            list
            addButton
        }
    }
    
    var list: some View {
        ScrollViewReader { scrollProxy in
            
            List($viewModel.scannerNutrients, id: \.self.hashValue, editActions: .delete) { $nutrient in
                cell(for: nutrient)
                    .frame(maxWidth: .infinity)
                    .id(nutrient.attribute)
            }
            
//            List {
//                ForEach(viewModel.scannerNutrients, id: \.self.id) { nutrient in
//                    cell(for: nutrient)
//                        .frame(maxWidth: .infinity)
//                        .id(nutrient.attribute)
//                }
//                .onDelete(perform: deleteAttribute)
//            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 54)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .buttonStyle(.borderless)
            .onReceive(scannerDidChangeAttribute) { notification in
                guard let userInfo = notification.userInfo,
                      let attribute = userInfo[Notification.ScannerKeys.nextAttribute] as? Attribute else {
                    return
                }
                withAnimation {
                    scrollProxy.scrollTo(attribute, anchor: .center)
                }
            }
        }
    }
    
    func deleteAttribute(at offsets: IndexSet) {
    }
    
    var pickerView: some View {
        var keyboard: some View {
            ZStack {
                textFieldBackground
                HStack {
                    textField
                    Spacer()
                    unitPicker
                }
                .padding(.horizontal, 25)
            }
        }
        
        var vstack: some View {
            VStack(spacing: TopButtonsVerticalPadding) {
                HStack(spacing: TopButtonsHorizontalPadding) {
                    if viewModel.state == .showingKeyboard {
                        keyboard
                    } else {
                        attributeButton
                        valueButton
                    }
                    rightButton
                }
                .padding(.horizontal, TopButtonsHorizontalPadding)
                if !viewModel.scannerNutrients.isEmpty {
                    listSection
                        .transition(.move(edge: .bottom))
                }
            }
            .padding(.vertical, TopButtonsVerticalPadding)
        }
        
        return ZStack {
            VStack(spacing: 0) {
                keyboardBackground
                Spacer()
            }
            vstack
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
    }
    
    @ViewBuilder
    var keyboardBackground: some View {
        if viewModel.state == .showingKeyboard {
            Group {
                if colorScheme == .dark {
                    Rectangle()
                        .foregroundStyle(.ultraThinMaterial)
                } else {
                    keyboardColor
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: TopButtonPaddedHeight)
            .transition(.opacity)
        }
    }

    func loadingView(_ string: String) -> some View {
        VStack {
            Spacer()
            VStack {
                Text(string)
                    .font(.system(.title3, design: .rounded, weight: .medium))
                    .foregroundColor(Color(.tertiaryLabel))
                ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(.tertiaryLabel))
            }
            Spacer()
        }
    }
    
    //MARK: - Events
    func stateChanged(to newState: ScannerState) {
        print("▫️ Scanner changed state to: \(newState.rawValue)")
    }
    
    //MARK: - Components
    
    var attributesList: some View {
        List {
            ForEach(viewModel.scannerNutrients, id: \.self) {
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
        var height: CGFloat { TopButtonHeight }
        var xOffset: CGFloat { 0 }
        
        var foregroundStyle: some ShapeStyle {
//            Material.thinMaterial
            expandedTextFieldColor
//            Color(.secondarySystemFill)
        }
        var background: some View { Color.clear }
        
        return RoundedRectangle(cornerRadius: TopButtonCornerRadius, style: .circular)
            .foregroundStyle(foregroundStyle)
            .background(background)
            .frame(height: height)
//            .frame(width: width)
            .offset(x: xOffset)
    }

    var textField: some View {
        let binding = Binding<String>(
            get: { viewModel.textFieldAmountString },
            set: { newValue in
                withAnimation {
                    viewModel.textFieldAmountString = newValue
                }
            }
        )

        return TextField("Enter Value", text: binding)
            .focused($isFocused)
            .keyboardType(.decimalPad)
            .font(.system(size: 22, weight: .semibold, design: .default))
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
            .matchedGeometryEffect(id: "textField", in: namespace)
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
        VStack {
            Spacer()
            ZStack {
                keyboardBackground
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

    var searchLayer: some View {
        ZStack {
            VStack {
                Spacer()
                ZStack {
                    keyboardColor
                        .opacity(colorScheme == .dark ? 0 : 1)
                        .frame(height: 100)
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
            .opacity(0)
//            buttonsLayer
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
                showKeyboardForCurrentAttribute()
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
                    .matchedGeometryEffect(id: "textField", in: namespace)
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
    
    func showKeyboardForCurrentAttribute() {
        viewModel.state = .showingKeyboard
        viewModel.textFieldAmountString = viewModel.currentAmountString
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                hideBackground = true
            }
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
        .frame(height: TopButtonHeight)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundStyle(Color(.quaternarySystemFill))
                .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
        )
    }
    
    
    var rightButton: some View {
        var width: CGFloat {
//            viewModel.state == .userValidationCompleted
//            ? UIScreen.main.bounds.width - (TopButtonsHorizontalPadding * 2.0)
//            : TopButtonWidth
            TopButtonWidth
        }
        
        var shouldDisablePrimaryButton: Bool {
            guard let currentNutrient = viewModel.currentNutrient else { return true }
            return currentNutrient.isConfirmed
        }
        
        var foregroundStyle: some ShapeStyle {
            Color.green.gradient
//            currentNutrientIsConfirmed ? Color.gray.gradient : Color.green.gradient
        }
        
        return Button {
            actionHandler(.confirmCurrentAttribute)
        } label: {
            Image(systemName: "checkmark")
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .frame(width: width)
                .frame(height: TopButtonHeight)
                .background(
                    RoundedRectangle(cornerRadius: TopButtonCornerRadius, style: .continuous)
                        .foregroundStyle(foregroundStyle)
                )
                .contentShape(Rectangle())
        }
        .disabled(shouldDisablePrimaryButton)
        .grayscale(shouldDisablePrimaryButton ? 1.0 : 0.0)
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
//                    .matchedGeometryEffect(id: "attributeName", in: namespace)
            }
            .foregroundColor(.primary)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .frame(height: TopButtonHeight)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundStyle(Color(.secondarySystemFill))
                    .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
            )
            .contentShape(Rectangle())
        }
    }
}

import SwiftSugar

public struct ScannerInputPreview: View {
    
    let delay: CGFloat = 0.5
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
        ScannerInput(
            viewModel: viewModel,
            keyboardHeight: .constant(371),
            actionHandler: { _ in }
        )
        .onAppear {
            self.viewModel.state = .showingKeyboard
//            self.viewModel.state = .awaitingUserValidation
            self.viewModel.currentAttribute = .energy
            self.viewModel.scannerNutrients = [
                ScannerNutrient(
                    attribute: .energy,
                    isConfirmed: false,
                    value: .init(amount: 360, unit: .kcal)
                ),
                ScannerNutrient(
                    attribute: .carbohydrate,
                    isConfirmed: false,
                    value: .init(amount: 25, unit: .g)
                ),
                ScannerNutrient(
                    attribute: .protein,
                    isConfirmed: true,
                    value: .init(amount: 30, unit: .g)
                )
            ]
        }
//        .task {
//            Task {
//                try await sleepTask(delay)
//                await MainActor.run { withAnimation { self.viewModel.state = .loadingImage } }
//
//                try await sleepTask(delay)
//                await MainActor.run { withAnimation { self.viewModel.state = .recognizingTexts } }
//
//                try await sleepTask(delay)
//                await MainActor.run { withAnimation { self.viewModel.state = .classifyingTexts } }
//
//                try await sleepTask(delay)
//                await MainActor.run { withAnimation { self.viewModel.state = .awaitingUserValidation } }
//            }
//        }
    }
}

struct ScannerInput_Preview: PreviewProvider {
    
    static var previews: some View {
        ScannerInputPreview()
    }
}

let Bounce: Animation = .interactiveSpring(response: 0.35, dampingFraction: 0.66, blendDuration: 0.35)
let Bounce2: Animation = .easeInOut
let colorHexKeyboardLight = "CDD0D6"
let colorHexKeyboardDark = "303030"
let colorHexSearchTextFieldDark = "535355"
let colorHexSearchTextFieldLight = "FFFFFF"

let TopButtonHeight: CGFloat = 50.0
let TopButtonWidth: CGFloat = 70.0
let TopButtonCornerRadius: CGFloat = 12.0
let TopButtonPaddedHeight = TopButtonHeight + (TopButtonsVerticalPadding * 2.0)

let TopButtonsVerticalPadding: CGFloat = 10.0
let TopButtonsHorizontalPadding: CGFloat = 10.0

enum ScannerState: String {
    case loadingImage
    case recognizingTexts
    case classifyingTexts
    case awaitingColumnSelection
    case awaitingUserValidation
    case userValidationCompleted
    case showingKeyboard
    case dismissing
    
    var isLoading: Bool {
        switch self {
        case .loadingImage, .recognizingTexts, .classifyingTexts:
            return true
        default:
            return false
        }
    }
    
    var loadingDescription: String? {
        switch self {
        case .loadingImage:
            return "Loading Image"
        case .recognizingTexts:
            return "Recognizing Texts"
        case .classifyingTexts:
            return "Classifying Texts"
        default:
            return nil
        }
    }
}

extension Notification.Name {
    public static var scannerDidChangeAttribute: Notification.Name { return .init("scannerDidChangeAttribute" )}
}

extension Notification {
    public struct ScannerKeys {
        public static let nextAttribute = "nextAttribute"
    }
}

