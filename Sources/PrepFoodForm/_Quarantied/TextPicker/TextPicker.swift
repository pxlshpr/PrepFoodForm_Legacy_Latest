//import SwiftUI
//import SwiftHaptics
//
//struct TextPicker: View {
//    @Environment(\.dismiss) var dismiss
//    @StateObject var textPickerViewModel: TextPickerViewModel
//    @State var pickedColumn: Int = 1
//    
//    @State var showingAutoFillConfirmation = false
//    @State var showingDeleteConfirmation = false
//
//    init(imageViewModels: [ImageViewModel], mode: TextPickerMode) {
//        let viewModel = TextPickerViewModel(
//            imageViewModels: imageViewModels,
//            mode: mode
//        )
//        _textPickerViewModel = StateObject(wrappedValue: viewModel)
//    }
//    
//    var body: some View {
//        ZStack {
//            pagerLayer
//            buttonsLayer
//                .confirmationDialog("AutoFill", isPresented: $showingAutoFillConfirmation) {
//                    Button("Confirm AutoFill") {
//                        Haptics.successFeedback()
//                        textPickerViewModel.tappedConfirmAutoFill()
//                    }
//                } message: {
//                    Text("This will replace any existing data with those detected in this image")
//                }
//        }
//        .onAppear(perform: appeared)
//        .onChange(of: textPickerViewModel.shouldDismiss) { newValue in
//            if newValue {
//                dismiss()
//            }
//        }
//        .onChange(of: textPickerViewModel.showingAutoFillConfirmation, perform: { newValue in
//            showingAutoFillConfirmation = newValue
//        })
//    }
//    
//    func appeared() {
////        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            textPickerViewModel.setInitialState()
////        }
//    }
//}
