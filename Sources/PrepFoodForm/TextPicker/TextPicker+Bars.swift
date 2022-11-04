import SwiftUI
import SwiftHaptics

extension TextPicker {
    
    var topBar: some View {
        ZStack {
            HStack {
                dismissButton
                Spacer()
            }
            HStack {
                Spacer()
                if let title {
                    titleView(for: title)
                        .transition(.scale)
                }
                Spacer()
            }
            HStack {
                Spacer()
                if textPickerViewModel.shouldShowMenuInTopBar {
                    topMenuButton
//                        .transition(.move(edge: .trailing))
                }
//                else {
//                    doneButton
//                }
            }
        }
        .frame(height: 64)
    }
    
    var bottomBar: some View {
        ZStack {
            Color.clear
            VStack(spacing: 0) {
                if textPickerViewModel.shouldShowSelectedTextsBar {
                    selectedTextsBar
                }
                if textPickerViewModel.shouldShowColumnPickerBar {
                    columnPickerBar
                }
                if textPickerViewModel.showShowImageSelector {
                    actionBar
                }
            }
        }
        .frame(height: bottomBarHeight)
        .background(.ultraThinMaterial)
    }
 
    var actionBar: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(textPickerViewModel.imageViewModels.indices, id: \.self) { index in
                    thumbnail(at: index)
                }
            }
            .padding(.leading, 20)
            .padding(.top, 15)
            Spacer()
//            if config.shouldShowMenu {
//                menuButton
//                    .padding(.top, 15)
//            }
        }
        .frame(height: 70)
    }
    
    var selectedTextsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(textPickerViewModel.selectedImageTexts, id: \.self) { imageText in
                    selectedTextButton(for: imageText)
                }
            }
            .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        //        .background(.green)
    }

    @ViewBuilder
    var columnPickerBar: some View {
        if let columns = textPickerViewModel.columns {
            HStack {
                columnPicker(columns: columns)
                columnSelectionDoneButton
            }
        }
    }
}
