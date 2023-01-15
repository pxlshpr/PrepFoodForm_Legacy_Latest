import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics
import ZoomableScrollView
import SwiftSugar
import Shimmer
import VisionSugar

public struct LabelInteractiveScanner: View {
    
    @Binding var selectedImage: UIImage?

    @ObservedObject var valuesPickerViewModel: ValuesPickerViewModel
    @ObservedObject var viewModel: LabelInteractiveScannerViewModel

    public init(
        valuesPickerViewModel: ValuesPickerViewModel,
        scanner: LabelInteractiveScannerViewModel,
        image: Binding<UIImage?> = .constant(nil)
    ) {
        _selectedImage = image
        self.valuesPickerViewModel = valuesPickerViewModel
        self.viewModel = scanner
    }
    
    public var body: some View {
        ZStack {
            if viewModel.showingBlackBackground {
                Color(.systemBackground)
//                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
//            imageLayer
            imageViewerLayer
            cameraLayer
            columnPickerLayer
            valuesPickerLayer
//            if !viewModel.animatingCollapse {
//                buttonsLayer
//                    .transition(.scale)
//            }
        }
        .onChange(of: selectedImage) { newValue in
            guard let newValue else { return }
            handleCapturedImage(newValue)
        }
        .onChange(of: viewModel.showingValuePickerUI) { showingValuePickerUI in
            guard showingValuePickerUI, let scanResult = viewModel.scanResult
            else { return }
            
            configureValuesPickerViewModel(with: scanResult)
        }
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
        ValuesPickerOverlay(
            viewModel: valuesPickerViewModel,
            isVisibleBinding: $viewModel.showingValuePickerUI,
            didTapDismiss: viewModel.dismissHandler,
            didTapCheckmark: { didTapCheckmark() },
            didTapAutofill: { viewModel.columnSelectionHandler() }
        )
    }
}

extension LabelInteractiveScanner {
    
    func showFocusedTextBox() {
        viewModel.showTextBoxesFor(
            attributeText: valuesPickerViewModel.currentAttributeText,
            valueText: valuesPickerViewModel.currentValueText)
    }
    
    func didTapCheckmark() {
        valuesPickerViewModel.moveToNextAttribute()
        showFocusedTextBox()
    }
    
    func configureValuesPickerViewModel(with scanResult: ScanResult) {
        valuesPickerViewModel.reset()
        guard let firstAttribute = scanResult.nutrientAttributes.first else {
            return
        }
        valuesPickerViewModel.currentAttribute = firstAttribute
        
        let c = viewModel.columns.selectedColumnIndex
        valuesPickerViewModel.nutrients = scanResult.nutrients.rows.map({ row in
            ValuesPickerViewModel.Nutrient(
                attribute: row.attribute,
                attributeText: row.attributeText.text,
                isConfirmed: false,
                value: c == 1 ? row.valueText1?.value : row.valueText2?.value,
                valueText: c == 1 ? row.valueText1?.text : row.valueText2?.text
            )
        })
        
        showFocusedTextBox()
    }
}
