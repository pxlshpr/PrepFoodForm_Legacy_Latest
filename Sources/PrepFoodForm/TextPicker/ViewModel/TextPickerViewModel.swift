import SwiftUI
import ZoomableScrollView
import SwiftUIPager

class TextPickerViewModel: ObservableObject {
    
    @Published var showingMenu = false
    @Published var showingAutoFillConfirmation = false
    @Published var imageViewModels: [ImageViewModel]
    @Published var showingBoxes: Bool
    @Published var selectedImageTexts: [ImageText]
    @Published var zoomBoxes: [ZoomBox?]
    @Published var page: Page
    
    @Published var currentIndex: Int = 0
    @Published var hasAppeared: Bool = false
    @Published var shouldDismiss: Bool = false
    
    let initialImageIndex: Int
    @Published var mode: TextPickerMode
    @Published var selectedColumn: Int
    
    init(imageViewModels: [ImageViewModel], mode: TextPickerMode){
        self.imageViewModels = imageViewModels
        self.mode = mode
        self.selectedImageTexts = mode.selectedImageTexts
        showingBoxes = true /// !mode.isImageViewer
        zoomBoxes = Array(repeating: nil, count: imageViewModels.count)
        
        initialImageIndex = mode.initialImageIndex(from: imageViewModels)
        page = .withIndex(initialImageIndex)
        currentIndex = initialImageIndex
        selectedColumn = mode.selectedColumnIndex ?? 1
    }
}
