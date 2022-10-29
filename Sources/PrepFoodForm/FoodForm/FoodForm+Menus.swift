import SwiftUI
import SwiftUISugar
import SwiftHaptics

extension FoodForm {
    
    
    //MARK: - Sources
    var sourcesMenu: BottomMenu {
        let addLinkGroup = BottomMenuActionGroup(action: addLinkMenuAction)
        return BottomMenu(groups: [photosMenuGroup, addLinkGroup])
    }
    
    //MARK: - Barcodes
    var addBarcodeMenu: BottomMenu {
        let scanAction = BottomMenuAction(title: "Scan a Barcode", systemImage: "barcode.viewfinder", tapHandler: {
            showingBarcodeScanner = true
        })
        let group = BottomMenuActionGroup(actions: [scanAction, enterBarcodeManuallyLink])
        return BottomMenu(group: group)
    }

    var enterBarcodeManuallyLink: BottomMenuAction {
       BottomMenuAction(
           title: "Enter Manually",
           systemImage: "123.rectangle",
           textInput: BottomMenuTextInput(
               placeholder: "012345678912",
               keyboardType: .decimalPad,
               submitString: "Add Barcode",
               autocapitalization: .never,
               textInputIsValid: isValidBarcode,
               textInputHandler: handleTypedOutBarcode
           )
       )
    }
    
    //MARK: - Photos

    var photosMenu: BottomMenu {
        BottomMenu(groups: [photosMenuGroup])
    }
    
    var photosMenuGroup: BottomMenuActionGroup {
        BottomMenuActionGroup(actions: [
            BottomMenuAction(title: "Scan a Food Label",
                             systemImage: "text.viewfinder",
                             tapHandler: { showingFoodLabelCamera = true }),
            BottomMenuAction(title: "Take Photo\(sources.pluralS)",
                             systemImage: "camera",
                             tapHandler: { showingCamera = true }),
            BottomMenuAction(title: "Choose Photo\(sources.pluralS)",
                             systemImage: "photo.on.rectangle",
                             tapHandler: { showingPhotosPicker = true }),
        ])
    }
    
    //MARK: - Link
    var addLinkMenu: BottomMenu {
        BottomMenu(action: addLinkMenuAction)
    }

    var confirmRemoveLinkMenu: BottomMenu {
        BottomMenu(action: BottomMenuAction(
            title: "Remove Link",
            role: .destructive,
            tapHandler: {
                withAnimation {
                    sources.removeLink()
                }
            }
        ))
    }

    var addLinkMenuAction: BottomMenuAction {
        BottomMenuAction(
            title: "Add a Link",
            systemImage: "link",
            textInput: BottomMenuTextInput(
                placeholder: "https://fastfood.com/nutrition-facts.pdf",
                keyboardType: .URL,
                submitString: "Add Link",
                autocapitalization: .never,
                textInputIsValid: textInputIsValidHandler,
                textInputHandler:
                    { string in
                        guard let linkInfo = LinkInfo(string) else {
                            return
                        }
                        sources.addLink(linkInfo)
                    }
            )
        )
    }
    
    //MARK: - Helpers
    
    func textInputIsValidHandler(_ string: String) -> Bool {
        string.isValidUrl
    }
}
