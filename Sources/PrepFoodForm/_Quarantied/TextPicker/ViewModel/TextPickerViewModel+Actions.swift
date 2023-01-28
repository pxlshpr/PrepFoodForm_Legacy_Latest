//import SwiftUI
//import SwiftHaptics
//import VisionSugar
//
//extension TextPickerViewModel {
//    
//    func tappedConfirmAutoFill() {
//        guard let currentScanResult, let columnSelectionHandler else {
//            return
//        }
//        columnSelectionHandler(selectedColumn, currentScanResult)
////        //TODO: Handle this outside the TextPicker, in a closure
////        FoodFormViewModel.shared.processScanResults(
////            column: selectedColumn,
////            from: [currentScanResult],
////            isUserInitiated: true
////        )
//        shouldDismiss = true
//    }
//    
//    func tappedAutoFill() {
//        guard let scanResult = imageViewModels[currentIndex].scanResult,
//              let columnSelectionHandler = mode.columnSelectionHandler
//        else {
//            return
//        }
//        
//        if scanResult.columnCount == 1 {
//            
//            columnSelectionHandler(1, scanResult)
////            //TODO: Handle this outside the TextPicker, in a closure
////            FoodFormViewModel.shared.processScanResults(
////                column: 1,
////                from: [scanResult],
////                isUserInitiated: true
////            )
//            
//            shouldDismiss = true
//
//        } else if scanResult.columnCount == 2 {
//            let column1 = TextColumn(
//                column: 1,
//                name: scanResult.headerTitle1,
//                imageTexts: scanResult.imageTextsForColumnSelection(at: 1)
//            )
//            let column2 = TextColumn(
//                column: 2,
//                name: scanResult.headerTitle2,
//                imageTexts: scanResult.imageTextsForColumnSelection(at: 2)
//            )
//            withAnimation {
//                let bestColumn = scanResult.bestColumn
//                self.selectedColumn = bestColumn
//                mode = .columnSelection(
//                    column1: column1,
//                    column2: column2,
//                    selectedColumn: bestColumn,
//                    requireConfirmation: true,
//                    dismissHandler: {
//                        self.shouldDismiss = true
//                    },
//                    columnSelectionHandler: columnSelectionHandler
////                    selectionHandler: { selectedColumn in
////                        self.showingAutoFillConfirmation = true
////                        return false
////                    }
//                )
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
//                guard let self else { return }
//                withAnimation {
//                    self.showingBoxes = true
//                    self.selectedImageTexts = self.mode.selectedImageTexts
//                }
//            }
//        } else {
//            shouldDismiss = true
//        }
//    }
//    
//    func tappedColumnSelectionDone() {
//        guard let columnSelectionHandler else {
//            return
//        }
//        if requiresConfirmation {
//            showingAutoFillConfirmation = true
//        } else {
//            columnSelectionHandler(selectedColumn, nil)
//        }
//    }
//    
//    func pickedColumn(_ index: Int) {
//        mode.selectedColumnIndex = index
//        withAnimation {
//            selectedImageTexts = mode.selectedImageTexts
//        }
//    }
//    
//    func selectedBoundingBox(forImageAt index: Int) -> CGRect? {
//        guard let singleSelectedImageText, singleSelectedImageText.imageId == imageViewModels[index].id else {
//            return nil
//        }
//        
//        let texts = textsForCurrentImage
//        
//        /// Only show the union of the attribute and selected texts if the union of them both does not entirely cover any other texts we will be displaying.
//        if !texts.contains(where: { singleSelectedImageText.boundingBoxWithAttribute.contains($0.boundingBox)}) {
//            return singleSelectedImageText.boundingBoxWithAttribute
//        } else {
//            return singleSelectedImageText.boundingBox
//        }
//    }
//
//    func tapHandler(for barcode: RecognizedBarcode) -> (() -> ())? {
//        nil
//    }
//
//    func tapHandlerForColumnSelection(for text: RecognizedText) -> (() -> ())? {
//        guard !mode.selectedColumnContains(text),
//              let selectedColumnIndex = mode.selectedColumnIndex
//        else {
//            return nil
//        }
//        return {
////            Haptics.feedback(style: .heavy)
//            withAnimation {
//                self.selectedColumn = selectedColumnIndex == 1 ? 2 : 1
//            }
//        }
//    }
//
//    func tapHandlerForTextSelection(for text: RecognizedText) -> (() -> ())? {
//        guard let currentImageId else {
//            return nil
//        }
//        
//        let imageText = ImageText(text: text, imageId: currentImageId)
//
//        if mode.isMultiSelection {
//            return {
//                self.toggleSelection(of: imageText)
//            }
//        } else {
//            guard let singleSelectionHandler = mode.singleSelectionHandler else {
//                return nil
//            }
//            return {
//                singleSelectionHandler(imageText)
//                self.shouldDismiss = true
//            }
//        }
//    }
//    
//    func tapHandler(for text: RecognizedText) -> (() -> ())? {
//        if mode.isColumnSelection {
//            return tapHandlerForColumnSelection(for: text)
//        } else if mode.supportsTextSelection {
//            return tapHandlerForTextSelection(for: text)
//        } else {
//            return nil
//        }
//    }
//    
//    func tappedDismiss() {
//        if case .columnSelection(_, _, _, _, let dismissHandler, _) = mode {
//            dismissHandler()
//        }
//    }
// 
//    func didTapThumbnail(at index: Int) {
//        Haptics.feedback(style: .rigid)
//        page(toImageAt: index)
//        
//        /// wait till the page animation completes
////        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
////
////            /// send the focus message to this page if we haven't sent the animated one yet
////            if !self.didSendAnimatedFocusMessage[index] {
////                self.setFocusBoxForImage(at: index, animated: true)
////            }
////
////            /// send a (non-animated) focus message to all *other* pages that have already received an animated focus message
////            for i in 0..<self.imageViewModels.count {
////                guard i != index,
////                      self.didSendAnimatedFocusMessage[index]
////                else {
////                    continue
////                }
////
////                self.setFocusBoxForImage(at: i, animated: false)
////            }
////        }
//    }
//    
//    func deleteCurrentImage() {
//        guard let deleteImageHandler = mode.deleteImageHandler else { return }
//        withAnimation {
//            let _ = imageViewModels.remove(at: currentIndex)
//            deleteImageHandler(currentIndex)
//            if imageViewModels.isEmpty {
//                shouldDismiss = true
//            } else if currentIndex != 0 {
//                currentIndex -= 1
//            }
//        }
//    }
//    
//    func toggleSelection(of imageText: ImageText) {
//        if selectedImageTexts.contains(imageText) {
//            Haptics.feedback(style: .light)
//            withAnimation {
//                selectedImageTexts.removeAll(where: { $0 == imageText })
//            }
//        } else {
//            Haptics.feedback(style: .soft)
//            withAnimation {
//                selectedImageTexts.append(imageText)
//            }
//        }
//    }
//}
