import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer
import VisionSugar

public struct Scanner: View {
    
    @Binding var selectedImage: UIImage?
    @ObservedObject var viewModel: ScannerViewModel

    @FocusState var proxyTextFieldIsFocused: Bool
    @State var keyboardHeight: CGFloat = 0
    @State var capturedKeyboardHeight = false

    let keyboardDidShow = NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)
    let keyboardDidHide = NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)

    public init(
        scanner: ScannerViewModel,
        image: Binding<UIImage?> = .constant(nil)
    ) {
        _selectedImage = image
        self.viewModel = scanner
    }
    
    public var body: some View {
        contents
        .onChange(of: selectedImage) { newValue in
            guard let newValue else { return }
            handleCapturedImage(newValue)
        }
        .onChange(of: viewModel.showingValuePickerUI) { showingValuePickerUI in
            guard showingValuePickerUI, let scanResult = viewModel.scanResult
            else { return }
            configureValuesPickerViewModel(with: scanResult)
        }
//        .onChange(of: viewModel.scanResult) { scanResult in
//            guard let scanResult else { return }
//            configureValuesPickerViewModel(with: scanResult)
//        }
//        .onChange(of: viewModel.animatingCollapse) { newValue in
//            withAnimation {
//                self.animatingCollapse = newValue
//            }
//        }
        .onChange(of: viewModel.clearSelectedImage) { newValue in
            guard newValue else { return }
            withAnimation {
                self.selectedImage = nil
            }
        }
        .onReceive(keyboardDidHide) { _ in
            print("⌨️ keyboardDidHide, setting capturedKeyboardHeight to true")
            print("⌨️ ----")
            if !capturedKeyboardHeight {
                capturedKeyboardHeight = true
            }
        }
        .onReceive(keyboardDidShow) { notification in
            guard !capturedKeyboardHeight else { return }
            print("⌨️ Setting proxyTextFieldIsFocused to false IN NOTIFICATION")
            self.proxyTextFieldIsFocused = false
            guard let frameEnd = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else {
                print("⌨️ Couldn't get bounds")
                return
            }
            print("⌨️ keyboard frame: \(frameEnd)")
            keyboardHeight = frameEnd.height
            print("⌨️ ----")
        }
        .onAppear {
            print("⌨️ Setting proxyTextFieldIsFocused to true")
            proxyTextFieldIsFocused = true
        }
    }
    
    var contents: some View {
        ZStack {
            if viewModel.showingBlackBackground {
                Color(.systemBackground)
//                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
            actualImageViewerLayer
            cameraLayer
            valuesPickerLayer
            columnPickerLayer
//            if !viewModel.animatingCollapse {
//                buttonsLayer
//                    .transition(.scale)
//            }
            keyboardHeightProxyTextFieldLayer
        }
    }
    
    @ViewBuilder
    var actualImageViewerLayer: some View {
        if capturedKeyboardHeight {
            VStack(spacing: 0) {
                ZStack {
                    imageViewerLayer
                }
                .frame(height: imageViewerHeight)
                Spacer()
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    var imageViewerHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        
        /// 🪄 Magic Number, god knows why but this works on iPhone 13 Pro Max, iPhone 14 Pro Max and iPhone X
        let correctivePadding = 8.0
        
        return screenHeight - (keyboardHeight + TopButtonPaddedHeight) + correctivePadding
    }

    var keyboardHeightProxyTextFieldLayer: some View {
        TextField("", text: .constant(""))
            .keyboardType(.decimalPad)
            .focused($proxyTextFieldIsFocused)
    }

    var contents_legacy: some View {
        ZStack {
            if viewModel.showingBlackBackground {
                Color(.systemBackground)
//                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
//            imageLayer
            imageViewerLayer
            cameraLayer
//            columnPickerLayer
            valuesPickerLayer
//            if !viewModel.animatingCollapse {
//                buttonsLayer
//                    .transition(.scale)
//            }
        }
    }
    
    func dismiss() {
        Haptics.feedback(style: .soft)
        viewModel.cancelAllTasks()
        viewModel.dismissHandler?()
    }
    
    var buttonsLayer: some View {
        var dismissButton: some View {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.down")
                    .imageScale(.medium)
                    .fontWeight(.medium)
                    .foregroundColor(Color(.secondaryLabel))
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 19)
                            .foregroundStyle(.ultraThinMaterial)
                            .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                    )
            }
        }
        
        var confirmButton: some View {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.down")
                    .imageScale(.medium)
                    .fontWeight(.medium)
                    .foregroundColor(Color(.secondaryLabel))
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 19)
                            .foregroundStyle(.ultraThinMaterial)
                            .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                    )
            }
        }
        
        return VStack {
            HStack {
                dismissButton
                Spacer()
            }
            .padding(.horizontal, 20)
            Spacer()
        }
    }
    
    var columnPickerLayer: some View {
        ColumnPickerOverlay(
            isVisibleBinding: $viewModel.showingColumnPickerUI,
            leftTitle: viewModel.leftColumnTitle,
            rightTitle: viewModel.rightColumnTitle,
            selectedColumn: viewModel.selectedColumnBinding,
            didTapDismiss: viewModel.dismissHandler,
            didTapAutofill: { viewModel.columnSelectionHandler() }
        )
    }
    
    var valuesPickerLayer: some View {
//        ValuesPickerOverlay(
        ScannerInput(
            viewModel: viewModel,
            keyboardHeight: $keyboardHeight,
            actionHandler: handleScannerAction
        )
        .onChange(of: viewModel.scannerNutrients, perform: scannerNutrientsChanged)
    }
    
    func scannerNutrientsChanged(_ newValue: [ScannerNutrient]) {
        print("🥸 scanner nutrients changed from: \(viewModel.scannerNutrients.count) to \(newValue.count)")
    }
    
    func handleScannerAction(_ scannerAction: ScannerAction) {
        switch scannerAction {
        case .dismiss:
            viewModel.dismissHandler?()
        case .confirmCurrentAttribute:
            didTapCheckmark()
        case .showAttribute(let attribute):
            Haptics.selectionFeedback()
            showAttribute(attribute)
        case .toggleAttributeConfirmation(let attribute):
            toggleAttributeConfirmation(attribute)
        }
    }
}

extension Scanner {
    
    func showFocusedTextBox() {
        viewModel.showTextBoxesFor(
            attributeText: viewModel.currentAttributeText,
            valueText: viewModel.currentValueText
        )
    }
    
    func didTapCheckmark() {
        viewModel.confirmCurrentAttributeAndMoveToNext()
        showFocusedTextBox()
    }
    
    func showAttribute(_ attribute: Attribute) {
        viewModel.moveToAttribute(attribute)
        showTextBoxes(for: attribute)
    }
    
    func showTextBoxes(for attribute: Attribute) {
        guard let nutrient = viewModel.scannerNutrients.first(where: { $0.attribute == attribute} ) else {
            return
        }
        viewModel.showTextBoxesFor(
            attributeText: nutrient.attributeText,
            valueText: nutrient.valueText
        )
    }
    
    func toggleAttributeConfirmation(_ attribute: Attribute) {
        if let attributeMovedTo = viewModel.toggleAttributeConfirmation(attribute) {
            showAttribute(attributeMovedTo)
        }
    }
    
    func configureValuesPickerViewModel(with scanResult: ScanResult) {
        viewModel.resetNutrients()
        guard let firstAttribute = scanResult.nutrientAttributes.first else {
            return
        }
        viewModel.currentAttribute = firstAttribute
        
        let c = viewModel.columns.selectedColumnIndex
        withAnimation {
            viewModel.scannerNutrients = scanResult.nutrients.rows.map({ row in
                ScannerNutrient(
                    attribute: row.attribute,
                    attributeText: row.attributeText.text,
                    isConfirmed: false,
                    value: c == 1 ? row.valueText1?.value : row.valueText2?.value,
                    valueText: c == 1 ? row.valueText1?.text : row.valueText2?.text
                )
            })
        }
        
        print("🪙 Set nutrientsToConfirm")
        showFocusedTextBox()
    }
}
