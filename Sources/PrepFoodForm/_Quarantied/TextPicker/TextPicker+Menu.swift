//import SwiftUI
//import SwiftHaptics
//
//extension TextPicker {
//    var topMenuButton: some View {
//        Menu {
//            Button {
//                if textPickerViewModel.columnCountForCurrentImage == 1 {
//                    /// Show confirmation dialog if we have only one column
//                    Haptics.warningFeedback()
//                    showingAutoFillConfirmation = true
//                } else {
//                    Haptics.feedback(style: .soft)
//                    /// Otherwise show the column picker
//                    textPickerViewModel.tappedAutoFill()
//                }
//            } label: {
//                Label("AutoFill", systemImage: "text.viewfinder")
//            }
//            Button {
//                Haptics.feedback(style: .soft)
//                withAnimation {
//                    textPickerViewModel.showingBoxes.toggle()
//                }
//            } label: {
//                Label(
//                    "\(textPickerViewModel.showingBoxes ? "Hide" : "Show") Texts",
//                    systemImage: "eye\(textPickerViewModel.showingBoxes ? ".slash" : "")"
//                )
//            }
//            Divider()
//            Button(role: .destructive) {
//                Haptics.warningFeedback()
//                showingDeleteConfirmation = true
//            } label: {
//                Label("Delete Photo", systemImage: "trash")
//            }
//        } label: {
//            Image(systemName: "ellipsis")
//                .frame(width: 40, height: 40)
//                .foregroundColor(.primary)
//                .background(
//                    Circle()
//                        .foregroundColor(.clear)
//                        .background(.ultraThinMaterial)
//                        .frame(width: 40, height: 40)
//                )
//                .clipShape(Circle())
//                .shadow(radius: 3, x: 0, y: 3)
//                .padding(.horizontal, 20)
//                .padding(.vertical, 10)
//                .contentShape(Rectangle())
//        }
//        .contentShape(Rectangle())
//        .simultaneousGesture(TapGesture().onEnded {
//            Haptics.feedback(style: .soft)
//        })
////        .confirmationDialog("AutoFill", isPresented: $showingAutoFillConfirmation) {
////            Button("Confirm AutoFill") {
////                Haptics.successFeedback()
////                textPickerViewModel.tappedConfirmAutoFill()
////            }
////        } message: {
////            Text("This will replace any existing data with those detected in this image")
////        }
//        .confirmationDialog("", isPresented: $showingDeleteConfirmation, titleVisibility: .hidden) {
//            Button("Delete Photo", role: .destructive) {
//                Haptics.errorFeedback()
//                textPickerViewModel.deleteCurrentImage()
//            }
//        } message: {
//            Text("This photo will be deleted while the data you filled from it will remain")
//        }
//    }
//}
