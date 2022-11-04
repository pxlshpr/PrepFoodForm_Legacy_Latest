import SwiftUI
import SwiftHaptics
import RSBarcodes_Swift
import AVKit
import SwiftUISugar

extension FoodForm {
    struct BarcodesForm: View {
        @Binding var barcodeValues: [FieldValue]
        @Binding var shouldShowFillIcon: Bool
        @Binding var showingAddBarcodeAlert: Bool
        @Binding var showingBarcodeScanner: Bool

        let deleteBarcodes: (IndexSet) -> ()
    }
}

extension FoodForm.BarcodesForm {
    
    var body: some View {
        List {
            ForEach(barcodeValues.indices, id: \.self) {
                barcodeCell(for: barcodeValues[$0])
            }
            .onDelete(perform: deleteBarcodes)
        }
        .toolbar { navigationTrailingContent }
        .toolbar { bottomBar }
    }
    
    @ViewBuilder
    func barcodeCell(for barcode: FieldValue) -> some View {
        if let payloadString = barcode.barcodeValue?.payloadString,
           let image = barcode.barcodeThumbnail(asSquare: false)
        {
            HStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 100)
                    .shadow(radius: 3, x: 0, y: 3)
                    .padding()
//                Spacer()
                Text(payloadString)
                Spacer()
                fillTypeIcon(for: barcode)
            }
        }
    }
    
    @ViewBuilder
    func fillTypeIcon(for fieldValue: FieldValue) -> some View {
        if shouldShowFillIcon {
            Image(systemName: fieldValue.fill.iconSystemImage)
                .foregroundColor(Color(.secondaryLabel))
        }
    }
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            EditButton()
        }
    }
    
    var bottomBar: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            HStack {
                addButton
                Spacer()
            }
        }
    }
    
    var addButton: some View {
        Menu {
            Button {
                showingBarcodeScanner = true
            } label: {
                Label("Scan a Barcode", systemImage: "barcode.viewfinder")
            }
            
            Button {
                showingAddBarcodeAlert = true
            } label: {
                Label("Enter Manually", systemImage: "123.rectangle")
            }
            
        } label: {
            Image(systemName: "plus")
                .padding(.vertical)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded {
            Haptics.feedback(style: .soft)
        })
    }
    
    //MARK: - Actions

    func tappedAdd() {
        showingAddBarcodeAlert = true
    }
    
    //MARK: To remove
//    var barcodeMenu: BottomMenu {
//        BottomMenu(actions: [scanBarcodeAction, enterBarcodeManuallyLink])
//    }
//
//    var scanBarcodeAction: BottomMenuAction {
//        BottomMenuAction(title: "Scan a Barcode", systemImage: "barcode.viewfinder", tapHandler: {
//            viewModel.showingBarcodeScanner = true
//        })
//    }
//    var enterBarcodeManuallyLink: BottomMenuAction {
//       BottomMenuAction(
//           title: "Enter Manually",
//           systemImage: "123.rectangle",
//           textInput: BottomMenuTextInput(
//               placeholder: "012345678912",
//               keyboardType: .decimalPad,
//               submitString: "Add Barcode",
//               autocapitalization: .never,
//               textInputIsValid: isValidBarcode,
//               textInputHandler: {
//                   let barcodeValue = FieldValue.BarcodeValue(
//                       payloadString: $0,
//                       symbology: .ean13,
//                       fill: .userInput)
//                   let fieldViewModel = Field(fieldValue: .barcode(barcodeValue))
//                   let _ = viewModel.add(barcodeViewModel: fieldViewModel)
//                   Haptics.successFeedback()
//               }
//           )
//       )
//    }
//
//    func isValidBarcode(_ string: String) -> Bool {
//        let isValid = RSUnifiedCodeValidator.shared.isValid(
//            string,
//            machineReadableCodeObjectType: AVMetadataObject.ObjectType.ean13.rawValue)
//        let exists = viewModel.contains(barcode: string)
//        return isValid && !exists
//    }
}
