import SwiftUI
import SwiftUISugar

extension TextPicker {
    var topMenuButton: some View {
        Menu {
            Button {
                if textPickerViewModel.columnCountForCurrentImage == 1 {
                    /// Show confirmation dialog if we have only one column
                    showingAutoFillConfirmation = true
                } else {
                    /// Otherwise show the column picker
                    textPickerViewModel.tappedAutoFill()
                }
            } label: {
                Label("AutoFill", systemImage: "text.viewfinder")
            }
            Button {
                withAnimation {
                    textPickerViewModel.showingBoxes.toggle()
                }
            } label: {
                Label(
                    "\(textPickerViewModel.showingBoxes ? "Hide" : "Show") Texts",
                    systemImage: "eye\(textPickerViewModel.showingBoxes ? ".slash" : "")"
                )
            }
            Divider()
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete Photo", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: 40, height: 40)
                .foregroundColor(.primary)
                .background(
                    Circle()
                        .foregroundColor(.clear)
                        .background(.ultraThinMaterial)
                        .frame(width: 40, height: 40)
                )
                .clipShape(Circle())
                .shadow(radius: 3, x: 0, y: 3)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
        }
        .confirmationDialog("AutoFill", isPresented: $showingAutoFillConfirmation) {
            Button("Confirm AutoFill") {
                textPickerViewModel.tappedConfirmAutoFill()
            }
        } message: {
            Text("This will replace any existing data with those detected in this image")
        }
        .confirmationDialog("", isPresented: $showingDeleteConfirmation, titleVisibility: .hidden) {
            Button("Delete Photo", role: .destructive) {
                textPickerViewModel.deleteCurrentImage()
            }
        } message: {
            Text("This photo will be deleted while the data you filled from it will remain")
        }
    }
}

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
