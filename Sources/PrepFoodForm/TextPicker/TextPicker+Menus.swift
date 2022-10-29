import SwiftUI
import SwiftUISugar

extension TextPicker {
    
    var confirmAutoFillMenu: BottomMenu {
        let group = BottomMenuActionGroup(actions: [
            BottomMenuAction(
                title: "This will replace any existing data."
            ),
            BottomMenuAction(
                title: "AutoFill",
                tapHandler: {
                    textPickerViewModel.tappedConfirmAutoFill()
                }
            )
        ])
        return BottomMenu(group: group)
    }
    
    var autoFillLinkAction: BottomMenuAction {
        BottomMenuAction(
            title: "AutoFill",
            systemImage: "text.viewfinder",
            linkedMenu: confirmAutoFillMenu
        )
    }
    
    var autoFillButtonAction: BottomMenuAction {
        BottomMenuAction(
            title: "AutoFill",
            systemImage: "text.viewfinder",
            tapHandler: {
                textPickerViewModel.tappedAutoFill()
            }
        )
    }
    
    var autoFillAction: BottomMenuAction? {
        switch textPickerViewModel.columnCountForCurrentImage {
        case 2: return autoFillButtonAction
        case 1: return autoFillLinkAction
        default: return nil
        }
    }
    
    var showHideAction: BottomMenuAction {
        BottomMenuAction(
            title: "\(textPickerViewModel.showingBoxes ? "Hide" : "Show") Texts",
            systemImage: "eye\(textPickerViewModel.showingBoxes ? ".slash" : "")",
            tapHandler: {
                withAnimation {
                    textPickerViewModel.showingBoxes.toggle()
                }
            })
    }
    
    var firstMenuGroup: BottomMenuActionGroup {
        let actions: [BottomMenuAction]
        if let autoFillAction {
            actions = [autoFillAction, showHideAction]
        } else {
            actions = [showHideAction]
        }
        return BottomMenuActionGroup(actions: actions)
    }
    
    var confirmDeleteMenu: BottomMenu {
        let title = BottomMenuAction(
            title: "This photo will be deleted while the data you filled from it will remain."
        )
        let deleteAction = BottomMenuAction(
            title: "Delete Photo",
            role: .destructive,
            tapHandler: {
                textPickerViewModel.deleteCurrentImage()
            })
        return BottomMenu(actions: [title, deleteAction])
    }
    
    var deletePhotoAction: BottomMenuAction {
        BottomMenuAction(
            title: "Delete Photo",
            systemImage: "trash",
            role: .destructive,
            linkedMenu: confirmDeleteMenu
        )
    }
    
    var bottomMenu: BottomMenu {
        BottomMenu(groups: [
            firstMenuGroup,
            BottomMenuActionGroup(action: deletePhotoAction)]
        )
    }
}
