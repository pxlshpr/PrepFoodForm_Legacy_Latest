import SwiftUI
import SwiftHaptics
import SwiftUISugar
import ActivityIndicatorView
import FoodLabelScanner
import PrepDataTypes
import PrepViews

public enum ScannerAction {
    case dismiss
    case confirmCurrentAttribute
    case deleteCurrentAttribute
    case moveToAttribute(Attribute)
    case moveToAttributeAndShowKeyboard(Attribute)
    case toggleAttributeConfirmation(Attribute)
}

//TODO: Have a helper that chooses this based on device
let KeyboardHeight: CGFloat = UIScreen.main.bounds.height < 850 ? 291 : 301
let KeyboardHeightSmall: CGFloat = 301
let SuggestionsBarHeight: CGFloat = 40

let TextFieldHorizontalPadding: CGFloat = 25

let NutrientsPickerTransitionAnimation: Animation = .interactiveSpring()

public struct ScannerInput: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var actionHandler: (ScannerAction) -> ()
    
    @Namespace var namespace
    @State var showingAttributePicker = false
    @State var hideBackground: Bool = false
    @State var showingNutrientsPicker = false
    
    @FocusState var isFocused: Bool
    @FocusState var nutrientSearchIsFocused: Bool
    @State var nutrientSearchString: String = ""

    let attributesListAnimation: Animation = Bounce

    @ObservedObject var viewModel: ScannerViewModel
    
    let scannerDidChangeAttribute = NotificationCenter.default.publisher(for: .scannerDidChangeAttribute)
    
    public init(
        viewModel: ScannerViewModel,
        actionHandler: @escaping (ScannerAction) -> ()
    ) {
        self.viewModel = viewModel
        self.actionHandler = actionHandler
    }
    
    public var body: some View {
        ZStack {
            topButtonsLayer
//            confirmButtonLayer
            supplementaryContentLayer
            primaryContentLayer
            buttonsLayer
        }
    }
    
    var primaryContentLayer: some View {
        VStack {
            Spacer()
            primaryContent
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showingAttributePicker) { attributePickerSheet }
        .onChange(of: viewModel.state, perform: stateChanged)
    }
    
    var primaryContent: some View {
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
        .frame(height: KeyboardHeight + TopButtonPaddedHeight + SuggestionsBarHeight)
        .background(background)
        .clipped()
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

        var listRowBackground: some View {
            isCurrentAttribute
            ? (colorScheme == .dark
               ? Color(.tertiarySystemFill)
               : Color(.systemFill)
            )
            : .clear
        }
        
        var hstack: some View {
            var valueDescription: String {
                nutrient.value?.description ?? "Enter a value"
            }
            
            var textColor: Color {
                isConfirmed ? .secondary : .primary
            }
            
            var valueTextColor: Color {
                guard nutrient.value != nil else {
                    return Color(.tertiaryLabel)
                }
                return textColor
            }
            
            return HStack(spacing: 0) {
                Button {
                    actionHandler(.moveToAttribute(nutrient.attribute))
                } label: {
                    HStack(spacing: 0) {
                        Text(nutrient.attribute.description)
                            .foregroundColor(textColor)
                        Spacer()
                    }
                }
                Button {
                    tappedCellValue(for: nutrient.attribute)
                } label: {
                    Text(valueDescription)
                        .foregroundColor(valueTextColor)
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
    
    func tappedValueButton() {
        Haptics.feedback(style: .soft)
        isFocused = true
        withAnimation {
            showKeyboardForCurrentAttribute()
        }
        viewModel.showTappableTextBoxesForCurrentAttribute()
    }

    var isDeleteButton: Bool {
        viewModel.currentNutrient?.isConfirmed == true && viewModel.state != .showingKeyboard
    }
    
    func tappedPrimaryButton_actual() {
        resignFocusOfSearchTextField()
        if isDeleteButton {
            actionHandler(.deleteCurrentAttribute)
        } else {
            actionHandler(.confirmCurrentAttribute)
        }
    }

    func tappedPrimaryButton() {
//        isFocused = true
//        viewModel.state = .showingKeyboard
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tappedPrimaryButton_actual()
//        }
    }
    
    func tappedCellValue(for attribute: Attribute) {
        actionHandler(.moveToAttribute(attribute))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            tappedValueButton()
        }
//        isFocused = true
//        actionHandler(.moveToAttributeAndShowKeyboard(attribute))
    }
    
    func showKeyboardForCurrentAttribute() {
        viewModel.state = .showingKeyboard
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                hideBackground = true
            }
        }
    }
    

    var nutrientsPicker: some View {
        let shouldShowEnergy = !viewModel.scannerNutrients.contains(where: { $0.attribute == .energy })
        
        func hasUnusedMicros(in group: NutrientTypeGroup, matching searchString: String = "") -> Bool {
            group.nutrients.contains(where: {
                if searchString.isEmpty {
                    return !hasMicronutrient(for: $0)
                } else {
                    return !hasMicronutrient(for: $0) && $0.matchesSearchString(searchString)
                }
            })
        }
        
        func hasMicronutrient(for nutrientType: NutrientType) -> Bool {
            viewModel.scannerNutrients.contains(where: { $0.attribute.nutrientType == nutrientType })
        }

        func shouldShowMacro(_ macro: Macro) -> Bool {
            !viewModel.scannerNutrients.contains(where: { $0.attribute.macro == macro })
        }
        
        func didAddNutrients(energy: Bool, macros: [Macro], micros: [NutrientType]) {
            withAnimation {
                if energy {
                    viewModel.scannerNutrients.insert(.init(attribute: .energy), at: 0)
                }
                for macro in macros {
                    viewModel.scannerNutrients.append(.init(attribute: macro.attribute))
                }
                for nutrientType in micros {
                    guard let attribute = nutrientType.attribute else { continue }
                    viewModel.scannerNutrients.append(.init(attribute: attribute))
                }
            }
        }

        return NutrientsPicker(
            supportsEnergyAndMacros: true,
            shouldShowEnergy: shouldShowEnergy,
            shouldShowMacro: shouldShowMacro,
            hasUnusedMicros: hasUnusedMicros,
            hasMicronutrient: hasMicronutrient,
            didAddNutrients: didAddNutrients
        )
    }
    
    var buttonsLayer: some View {
        
        var bottomPadding: CGFloat {
            return 34
        }
        
        var addButton: some View {
            Button {
                Haptics.feedback(style: .soft)
                showingNutrientsPicker = true
//                withAnimation(NutrientsPickerTransitionAnimation) {
//                    viewModel.state = .showingNutrientsPicker
//                }
            } label: {
                Image(systemName: "plus")
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
            .sheet(isPresented: $showingNutrientsPicker) { nutrientsPicker }
        }
        
        var addButtonRow: some View {
            var shouldShow: Bool {
                !viewModel.state.isLoading
                && !viewModel.state.isShowingNutrientsPicker
            }
            
            return HStack {
                Spacer()
                if shouldShow {
                    addButton
                        .transition(.move(edge: .trailing))
                }
            }
        }
        
        var doneButton: some View {
            var textColor: Color {
                viewModel.state == .allConfirmed
                ? Color.white
                : Color(.secondaryLabel)
            }
            
            @ViewBuilder
            var backgroundView: some View {
                ZStack {
                    RoundedRectangle(cornerRadius: 19, style: .continuous)
                        .foregroundStyle(.ultraThinMaterial)
                        .opacity(viewModel.state == .allConfirmed ? 0 : 1)
                    RoundedRectangle(cornerRadius: 19, style: .continuous)
                        .foregroundStyle(Color.accentColor)
                        .opacity(viewModel.state == .allConfirmed ? 1 : 0)
                }
                .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
            }
            
            var shouldShow: Bool {
                !viewModel.state.isLoading
            }
            
            return Group {
                if shouldShow {
                    Button {
                        
                    } label: {
                        Text("Done")
                            .imageScale(.medium)
                            .fontWeight(.medium)
                            .foregroundColor(textColor)
                            .frame(height: 38)
                            .padding(.horizontal, 15)
                            .background(backgroundView)
                    }
                    .transition(.move(edge: .trailing))
                }
            }
        }
        
        var topButtons: some View {
            HStack {
                dismissButton
                Spacer()
                doneButton
            }
        }
        
        return VStack {
            topButtons
                .padding(.horizontal, 20)
            Spacer()
            addButtonRow
            .padding(.horizontal, 20)
            .padding(.bottom, bottomPadding)
        }
        .frame(width: UIScreen.main.bounds.width)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    var topButtonsLayer: some View {
        var bottomPadding: CGFloat {
            TopButtonPaddedHeight + SuggestionsBarHeight + 8.0
        }
        
        var keyboardButton: some View {
            Button {
                Haptics.feedback(style: .soft)
                resignFocusOfSearchTextField()
                withAnimation {
                    if viewModel.containsUnconfirmedAttributes {
                        viewModel.state = .awaitingConfirmation
                    } else {
                        viewModel.state = .allConfirmed
                    }
                    hideBackground = false
                }
            } label: {
                DismissButtonLabel(forKeyboard: true)
            }
        }
        
        var sideButtonsLayer: some View {
            HStack {
//                dismissButton
                Spacer()
                keyboardButton
            }
            .transition(.opacity)
        }
        
        @ViewBuilder
        var centerButtonLayer: some View {
            if let currentAttribute = viewModel.currentAttribute {
                HStack {
                    Spacer()
                    Text(currentAttribute.description)
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
        }
        
        var shouldShow: Bool {
            viewModel.state == .showingKeyboard
        }
        
        return Group {
            if shouldShow {
                VStack {
                    Spacer()
                    ZStack(alignment: .bottom) {
//                        centerButtonLayer
                        sideButtonsLayer
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, bottomPadding)
                    .frame(width: UIScreen.main.bounds.width)
                }
            }
        }
    }

    var confirmButtonLayer: some View {
        var bottomPadding: CGFloat {
            KeyboardHeight + TopButtonPaddedHeight
        }
        
        var buttonLayer: some View {
            HStack {
                Spacer()
                Text("All nutrients confirmed")
                    .font(.system(.title3, design: .rounded, weight: .medium))
                    .foregroundColor(
                        Color(.secondaryLabel)
//                        .white
                    )
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
//                            .foregroundStyle(Color.green.gradient)
                            .foregroundStyle(.ultraThinMaterial)
                            .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                    )
                Spacer()
            }
            .padding(.horizontal, 38)
            .padding(.bottom, 8)
        }
        
        var shouldShow: Bool {
            viewModel.state == .allConfirmed
        }
        
        var zstack: some View {
            ZStack {
                if shouldShow {
                    VStack {
                        Spacer()
                        ZStack(alignment: .bottom) {
                            buttonLayer
                        }
                        .padding(.horizontal, 20)
                        .frame(width: UIScreen.main.bounds.width)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .clipped()
        }
        
        return zstack
        .padding(.bottom, bottomPadding)
        .edgesIgnoringSafeArea(.bottom)
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
                Color.clear.frame(height: 60)
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
        var valueTextFieldContents: some View {
            ZStack {
                textFieldBackground
                HStack {
                    textField
                    Spacer()
                    unitPicker
                }
                .padding(.horizontal, TextFieldHorizontalPadding)
            }
        }
        
        var statusMessage: some View {
            var string: String {
                viewModel.state == .allConfirmed
                ? "All nutrients confirmed"
                : "Confirm or correct nutrients"
            }
            return Text(string)
            .font(.system(size: 18, weight: .medium, design: .default))
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .frame(height: TopButtonHeight)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundStyle(Color(.tertiarySystemFill))
            )
            .contentShape(Rectangle())
        }
        
        var topButtonsRow: some View {
            Group {
                if viewModel.currentAttribute == nil {
                    statusMessage
                        .transition(.move(edge: .trailing))
                } else {
                    HStack(spacing: TopButtonsHorizontalPadding) {
                        if viewModel.state == .showingKeyboard {
                            valueTextFieldContents
                        } else {
                            attributeButton
                            valueButton
                        }
                        rightButton
                    }
                    .transition(.move(edge: .leading))
                }
            }
        }
        
        var nutrients: some View {
            VStack(spacing: TopButtonsVerticalPadding) {
                topButtonsRow
                .padding(.horizontal, TopButtonsHorizontalPadding)
                if !viewModel.scannerNutrients.isEmpty {
                    list
                        .transition(.move(edge: .bottom))
                        .opacity(viewModel.state == .showingKeyboard ? 0 : 1)
                }
            }
            .padding(.vertical, TopButtonsVerticalPadding)
        }
        
        var nutrientsPickerTopBar: some View {
            var backButton: some View {
                return Button {
                    withAnimation(NutrientsPickerTransitionAnimation) {
                        viewModel.state = .awaitingConfirmation
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
//                        .padding(.horizontal)
                        .frame(width: TopButtonHeight, height: TopButtonHeight)
//                        .background(
//                            RoundedRectangle(cornerRadius: 12, style: .continuous)
//                                .foregroundStyle(Color(.secondarySystemFill))
//                                .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
//                        )
                        .contentShape(Rectangle())
                }
            }
            
            var title: some View {
                HStack {
                    Text("Add Nutrients")
                        .font(.headline)
                    Spacer()
                }
            }
            
            var filterButton: some View {
                var width: CGFloat {
                    let font = UIFont.systemFont(ofSize: 15)
                    let fontAttributes = [NSAttributedString.Key.font: font]
                    let size = (filterString as NSString).size(withAttributes: fontAttributes)
                    let textSize = size.width
                    
                    let width = textSize + 38 + (horizontalPadding * 3)
                    let maxWidth: CGFloat = 200
                    return min(maxWidth, width)
                }
                
                var horizontalPadding: CGFloat {
                    (38 - 25) / 2.0
                }
                
                var filterString: String {
                    "Search"
//                    "Polyunsaturated Fat here we go here's a long one now"
                }
                
                return ZStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 19, style: .continuous)
                        .foregroundColor(Color(.secondarySystemFill))
                        .frame(height: 38)
                    HStack(spacing: 0) {
                        TextField("Search", text: $nutrientSearchString)
//                            Text(filterString)
                            .focused($nutrientSearchIsFocused)
                            .foregroundColor(Color(.tertiaryLabel))
                            .autocorrectionDisabled(true)
                            .keyboardType(.asciiCapable)
//                                .foregroundColor(Color(.secondaryLabel))
                            .padding(.horizontal, horizontalPadding)
                            .padding(.leading, horizontalPadding)
                            .lineLimit(1)
//                                .disabled(viewModel.state == .showingNutrientsPicker)
                        Image(systemName: "magnifyingglass.circle")
                            .font(.system(size: 25))
                            .frame(width: 25, height: 25)
                            .padding(.trailing, horizontalPadding)
                    }
                    Button {
                        withAnimation {
                            viewModel.state = .showingNutrientsPickerSearch
                        }
                        nutrientSearchIsFocused = true
                    } label: {
                        Color.clear
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                    }
                }
                .frame(width: width)
                .fontWeight(.regular)
                .foregroundColor(.accentColor)
//                    .frame(width: width)
                .frame(height: TopButtonHeight)
            }
            
            return Group {
                ZStack {
                    HStack(spacing: TopButtonsHorizontalPadding) {
                        valueTextFieldContents
                    }
                    if viewModel.state != .showingKeyboard {
                        HStack(spacing: TopButtonsHorizontalPadding) {
                            backButton
                            title
                            filterButton
                        }
                    }
                }
                .transition(.move(edge: .leading))
                .padding(.horizontal, TopButtonsHorizontalPadding)
                .padding(.vertical, TopButtonsVerticalPadding)
                .background(keyboardColor)
            }
        }
        
        @ViewBuilder
        var nutrientPicker: some View {
            if viewModel.state.isShowingNutrientsPicker {
                ZStack {
                    Color(.secondarySystemBackground)
//                    Color.clear
//                        .background(
//                            .ultraThinMaterial
//                        )
                    VStack(spacing: 0) {
                        nutrientsPickerTopBar
                        Spacer()
//                        Color.yellow
                    }
                }
                .transition(.move(edge: .leading))
            }
        }
        
        return ZStack {
            nutrients
            nutrientPicker
                .zIndex(20)
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
    }
    
    var supplementaryContentLayer: some View {
        @ViewBuilder
        var attributeLayer: some View {
            if let currentAttribute = viewModel.currentAttribute {
                VStack {
                    HStack {
                        Text(currentAttribute.description)
                            .matchedGeometryEffect(id: "attributeName", in: namespace)
//                            .textCase(.uppercase)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .offset(y: -3)
                            .foregroundColor(Color(.secondaryLabel))
                            .padding(.horizontal, 15)
                            .background(
                                Capsule(style: .continuous)
                                    .foregroundColor(keyboardColor)
//                                    .foregroundColor(.blue)
                                    .frame(height: 35)
                                    .transition(.scale)
                            )
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 20)
                    .offset(y: -10)
                    Spacer()
                }
            }
        }
        
        return VStack(spacing: 0) {
            Spacer()
            if viewModel.state == .showingKeyboard {
                ZStack(alignment: .bottom) {
                    keyboardColor
                    attributeLayer
                    suggestionsLayer
                }
                .frame(maxWidth: .infinity)
                .frame(height: KeyboardHeight + TopButtonPaddedHeight + SuggestionsBarHeight)
                .transition(.opacity)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    var suggestionsLayer: some View {
        
        var valueSuggestions: [FoodLabelValue] {
//            [.init(amount: 320, unit: .kcal), .init(amount: 320, unit: .kj), .init(amount: 320), .init(amount: 3200, unit: .kcal), .init(amount: 3200, unit: .kj)]
            guard let text = viewModel.currentValueText, let attribute = viewModel.currentAttribute else {
                return []
            }
            return text.allDetectedFoodLabelValues(for: attribute)
        }
        
        var backgroundColor: Color {
//                Color(.tertiarySystemFill)
            colorScheme == .dark ? Color(hex: "737373") : Color(hex: "EBEDF0")
        }
        
        var textColor: Color {
//                .primary
            .secondary
        }
        
        var scrollView: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(valueSuggestions, id: \.self) { value in
                        Text(value.description)
    //                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(textColor)
                            .padding(.horizontal, 15)
                            .frame(height: SuggestionsBarHeight)
                            .background(
    //                                Capsule(style: .continuous)
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .foregroundColor(backgroundColor)
                            )
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        
        var noTextBoxPrompt: String {
            "Select a text from the image to autofill its value."
//            viewModel.textFieldAmountString.isEmpty
//            ? "or select a detected text from the image."
//            : "Select a detected text from the image."
        }
        
        return Group {
            if valueSuggestions.isEmpty {
                Text(noTextBoxPrompt)
                    .foregroundColor(Color(.tertiaryLabel))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            } else {
                scrollView
            }
        }
        .frame(height: SuggestionsBarHeight)
//        .background(.green)
        .padding(.bottom, KeyboardHeight + 2)
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

    var dismissButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            withAnimation(attributesListAnimation) {
                showingAttributePicker = false
            }
        } label: {
            Image(systemName: "multiply")
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

    var attributeLayer: some View {
        
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
//        var xOffset: CGFloat { 0 }
        
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
//            .offset(x: xOffset)
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

        return TextField("Enter a value", text: binding)
            .focused($isFocused)
            .keyboardType(.decimalPad)
            .font(.system(size: 22, weight: .semibold, design: .default))
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
            viewModel.hideTappableTextBoxesForCurrentAttribute()
        }
//        viewModel.hideTappableTextBoxesForCurrentAttribute()
    }

    //TODO: Remove this
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
        
        guard boundingBox != .zero else { return nil }
        
        let zBox = ZBox(boundingBox: boundingBox, imageSize: imageSize)
        return [Notification.ZoomableScrollViewKeys.zoomBox: zBox]
    }

    var userInfoForAllAttributesZoom: [String: Any]? {
        guard let imageSize = viewModel.image?.size,
              let boundingBox = viewModel.scanResult?.nutrientsBoundingBox(includeAttributes: true)
        else { return nil }
        let zBox = ZBox(boundingBox: boundingBox, imageSize: imageSize)
        return [Notification.ZoomableScrollViewKeys.zoomBox: zBox]
    }


    var valueButton: some View {
        var amountColor: Color {
            Color.primary
        }
        
        var unitColor: Color {
            Color.secondary
        }
        
        var backgroundStyle: some ShapeStyle {
            Color(.secondarySystemFill)
        }
        
        return Button {
            tappedValueButton()
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                if viewModel.currentAmountString.isEmpty {
                    Image(systemName: "keyboard")
                } else {
                    Text(viewModel.currentAmountString)
                        .foregroundColor(amountColor)
                        .matchedGeometryEffect(id: "textField", in: namespace)
                    Text(viewModel.currentUnitString)
                        .foregroundColor(unitColor)
                        .font(.system(size: 18, weight: .medium, design: .default))
                }
            }
            .font(.system(size: 22, weight: .semibold, design: .default))
            .padding(.horizontal)
            .frame(height: TopButtonHeight)
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
            if let textFieldDouble = viewModel.internalTextfieldDouble {
                if textFieldDouble != currentNutrient.value?.amount {
                    return false
                }
                if viewModel.pickedAttributeUnit != currentNutrient.value?.unit {
                    return false
                }
            }
            return currentNutrient.isConfirmed
        }
        
        var imageName: String {
            isDeleteButton ? "trash" : "checkmark"
        }

        var foregroundStyle: some ShapeStyle {
            isDeleteButton ? Color.red.gradient : Color.green.gradient
        }
        
        return Button {
            tappedPrimaryButton()
        } label: {
            Image(systemName: imageName)
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
//        .disabled(shouldDisablePrimaryButton)
//        .grayscale(shouldDisablePrimaryButton ? 1.0 : 0.0)
        .animation(.interactiveSpring(), value: shouldDisablePrimaryButton)
    }

    var attributeButton: some View {
        Button {
            tappedValueButton()
//            Haptics.feedback(style: .soft)
//            withAnimation(attributesListAnimation) {
//                showingAttributePicker = true
//            }
        } label: {
            Text(viewModel.currentAttribute?.description ?? "")
                .matchedGeometryEffect(id: "attributeName", in: namespace)
//                .font(.title3)
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.2)
                .lineLimit(2)
                .foregroundColor(.primary)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .frame(height: TopButtonHeight)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .foregroundStyle(Color(.quaternarySystemFill))
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
            actionHandler: { _ in }
        )
        .onAppear {
//            self.viewModel.state = .showingNutrientsPickerSearch
            self.viewModel.state = .awaitingConfirmation
//            self.viewModel.state = .allConfirmed
            self.viewModel.currentAttribute = .polyunsaturatedFat
            self.viewModel.scannerNutrients = [
                ScannerNutrient(
                    attribute: .energy,
                    isConfirmed: false,
                    value: .init(amount: 360, unit: .kcal)
                ),
                ScannerNutrient(
                    attribute: .polyunsaturatedFat,
                    isConfirmed: false,
                    value: nil
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
        .task {
            Task {
//                try await sleepTask(delay)
//                await MainActor.run { withAnimation { self.viewModel.state = .loadingImage } }
//
//                try await sleepTask(delay)
//                await MainActor.run { withAnimation { self.viewModel.state = .recognizingTexts } }
//
//                try await sleepTask(delay)
//                await MainActor.run { withAnimation { self.viewModel.state = .classifyingTexts } }
//
                try await sleepTask(delay)
                try await sleepTask(delay)
                try await sleepTask(delay)
                await MainActor.run {
                    withAnimation {
//                        self.viewModel.state = .showingNutrientsPickerSearch
//                        self.viewModel.state = .allConfirmed
//                        self.viewModel.currentAttribute = nil
                    }
                }
                
//                try await sleepTask(delay * 3.0)
//                await MainActor.run {
//                    withAnimation {
//                        self.viewModel.currentAttribute = .energy
//                    }
//                }

            }
        }
    }
}

struct ScannerInput_Preview: PreviewProvider {
    static var previews: some View {
        ScannerInputPreview()
    }
}

let Bounce: Animation = .interactiveSpring(response: 0.35, dampingFraction: 0.66, blendDuration: 0.35)
let Bounce2: Animation = .easeInOut
let colorHexKeyboardLight_legacy = "CDD0D6"
let colorHexKeyboardDark_legacy = "303030"
let colorHexKeyboardLight = "CFD3D9"
let colorHexKeyboardDark = "383838"
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
    case awaitingConfirmation
    case showingNutrientsPicker
    case showingNutrientsPickerSearch
    case allConfirmed
    case showingKeyboard
    case dismissing
    
    var isShowingNutrientsPicker: Bool {
        switch self {
        case .showingNutrientsPicker, .showingNutrientsPickerSearch:
            return true
        default:
            return false
        }
    }
    
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

import VisionSugar

extension RecognizedText {
    func allDetectedFoodLabelValues(for attribute: Attribute) -> [FoodLabelValue] {
        var allValues: [FoodLabelValue] = []
        
        func addValueIfNotExisting(_ value: FoodLabelValue) {
            guard !allValues.contains(value) else { return }
            allValues.append(value)
        }
        
        for candidate in candidates {
            let detectedValues = candidate.detectedValues
            for value in detectedValues {
                
                /// If the value has no unit, assign the attribute's default unit
//                let valueWithUnit: FoodLabelValue
//                if value.unit == nil {
//                    valueWithUnit = FoodLabelValue(amount: value.amount, unit: attribute.defaultUnit)
//                } else {
//                    valueWithUnit = value
//                }
//
//                addValueIfNotExisting(valueWithUnit)
//
//                if attribute == .energy {
//                    let oppositeUnit: FoodLabelUnit = valueWithUnit.unit == .kcal ? .kj : .kcal
//                    addValueIfNotExisting(FoodLabelValue(amount: valueWithUnit.amount, unit: oppositeUnit))
//                }
                let valueWithoutUnit = FoodLabelValue(amount: value.amount)
                addValueIfNotExisting(valueWithoutUnit)
            }
        }
        return allValues
    }
}
