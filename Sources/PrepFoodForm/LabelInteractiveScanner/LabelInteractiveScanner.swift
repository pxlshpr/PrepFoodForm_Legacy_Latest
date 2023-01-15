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

    @ObservedObject var viewModel: LabelInteractiveScannerViewModel

    public init(
        scanner: LabelInteractiveScannerViewModel,
        image: Binding<UIImage?> = .constant(nil)
    ) {
        _selectedImage = image
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
            isVisibleBinding: $viewModel.showingValuePickerUI,
            didTapDismiss: viewModel.dismissHandler,
            didTapCheckmark: { viewModel.didTapCheckmark() },
            didTapAutofill: { viewModel.columnSelectionHandler() }
        )
    }
    
    @ViewBuilder
    var imageLayer: some View {
        if let selectedImage {
            ZStack {
                ZStack {
                    Color.black

                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
//                    Color.black
//                        .opacity(shimmeringImage ? 0.6 : 0)
                }
                .scaleEffect(viewModel.animatingCollapse ? 0 : 1)
                .padding(.top, viewModel.animatingCollapse ? 400 : 0)
                .padding(.trailing, viewModel.animatingCollapse ? 300 : 0)
                textBoxesLayer
                croppedImagesCutoutLayer
                    .scaleEffect(viewModel.animatingCollapseOfCutouts ? 0 : 1)
                    .opacity(viewModel.animatingCollapseOfCutouts ? 0 : 1)
                    .padding(.top, viewModel.animatingCollapseOfCutouts ? 400 : 0)
                    .padding(.trailing, viewModel.animatingCollapseOfCutouts ? 300 : 0)
                croppedImagesLayer
                    .scaleEffect(viewModel.animatingCollapseOfCroppedImages ? 0 : 1)
                    .padding(.top, viewModel.animatingCollapseOfCroppedImages ? 0 : 0)
                    .padding(.trailing, viewModel.animatingCollapseOfCroppedImages ? 300 : 0)
            }
            .edgesIgnoringSafeArea(.all)
//            .transition(.move(edge: .bottom))
            .transition(.opacity)
        }
    }
}
