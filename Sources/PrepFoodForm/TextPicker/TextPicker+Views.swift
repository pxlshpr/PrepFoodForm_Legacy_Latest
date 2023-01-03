import SwiftUI
import SwiftUIPager
import ZoomableScrollView

extension TextPicker {
    
    //MARK: - Layers
    
    var pagerLayer: some View {
        Pager(
            page: textPickerViewModel.page,
            data: textPickerViewModel.imageViewModels,
            id: \.hashValue,
            content: { imageViewModel in
                zoomableScrollView(for: imageViewModel)
                    .background(.black)
            })
        .sensitivity(.high)
        .pagingPriority(.high)
        .onPageWillChange { index in
            textPickerViewModel.pageWillChange(to: index)
        }
        .onPageChanged { index in
            textPickerViewModel.pageDidChange(to: index)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    
    var buttonsLayer: some View {
        VStack(spacing: 0) {
            topBar
            Spacer()
            if textPickerViewModel.shouldShowBottomBar {
                bottomBar
                //TODO: Bring this back after figuring out what's causing the EXC_BAD_ACCESS (code=1) crash
                //                    .transition(.move(edge: .bottom))
            }
        }
    }
    
    func titleView(for title: String) -> some View {
        Text(title)
            .font(.title3)
            .bold()
        //            .padding(12)
            .padding(.horizontal, 12)
            .frame(height: 45)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.clear)
                    .background(.ultraThinMaterial)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 15)
            )
            .shadow(radius: 3, x: 0, y: 3)
            .padding(.horizontal, 5)
            .padding(.vertical, 10)
    }
    
    func thumbnail(at index: Int) -> some View {
        var isSelected: Bool {
            textPickerViewModel.currentIndex == index
        }
        
        return Group {
            if let image = textPickerViewModel.imageViewModels[index].image {
                Button {
                    textPickerViewModel.didTapThumbnail(at: index)
                } label: {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 55, height: 55)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(.accentColor.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                    //                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3]))
                                        .strokeBorder(style: StrokeStyle(lineWidth: 2))
                                        .foregroundColor(.accentColor)
                                    //                                        .padding(-0.5)
                                )
                                .opacity(isSelected ? 1.0 : 0.0)
                        )
                }
            }
        }
    }
}

extension TextPicker {
    
    func index(of imageViewModel: ImageViewModel) -> Int? {
        guard let index = textPickerViewModel.imageViewModels.firstIndex(of: imageViewModel),
              index < textPickerViewModel.zoomBoxes.count
        else { return nil }
        return index
    }
    
    func id(for imageViewModel: ImageViewModel) -> UUID? {
        guard let index = index(of: imageViewModel) else { return nil }
        return textPickerViewModel.imageViewModels[index].id
    }

    func zoomBoxBinding(for imageViewModel: ImageViewModel) -> Binding<ZoomBox?>? {
        guard let index = index(of: imageViewModel) else { return nil }
        return Binding<ZoomBox?>(
            get: { textPickerViewModel.zoomBoxes[index] },
            set: { _ in }
        )
    }
    
    var showingBoxesBinding: Binding<Bool> {
        Binding<Bool>(
            get: { textPickerViewModel.showingBoxes },
            set: { _ in }
        )
    }

    var textPickerHasAppearedBinding: Binding<Bool> {
        Binding<Bool>(
            get: { textPickerViewModel.hasAppeared },
            set: { _ in }
        )
    }

    @ViewBuilder
    func zoomableScrollView(for imageViewModel: ImageViewModel) -> some View {
        if let id = id(for: imageViewModel),
           let zoomBoxBinding = zoomBoxBinding(for: imageViewModel),
           let image = imageViewModel.image
        {
            ImageViewer(
                id: id,
                image: image,
                textBoxes: .constant(textPickerViewModel.textBoxes(for: imageViewModel)),
                zoomBox: zoomBoxBinding,
                showingBoxes: showingBoxesBinding,
                textPickerHasAppeared: textPickerHasAppearedBinding
            )
        }
    }
}

//MARK: - Legacy

extension TextPicker {
    
    @ViewBuilder
    func zoomableScrollView_legacy(for imageViewModel: ImageViewModel) -> some View {
        if let index = textPickerViewModel.imageViewModels.firstIndex(of: imageViewModel),
           index < textPickerViewModel.zoomBoxes.count,
           let image = imageViewModel.image
        {
            ZoomableScrollView(
                id: textPickerViewModel.imageViewModels[index].id,
                zoomBox: $textPickerViewModel.zoomBoxes[index],
                backgroundColor: .black
            ) {
                imageView(image)
                    .overlay(textBoxesLayer(for: imageViewModel))
            }
        }
    }
    
    @ViewBuilder
    func textBoxesLayer(for imageViewModel: ImageViewModel) -> some View {
//        if config.showingBoxes {
            TextBoxesLayer(textBoxes: textPickerViewModel.textBoxes(for: imageViewModel))
                .opacity((textPickerViewModel.hasAppeared && textPickerViewModel.showingBoxes) ? 1 : 0)
                .animation(.default, value: textPickerViewModel.hasAppeared)
                .animation(.default, value: textPickerViewModel.showingBoxes)
//        }
    }

    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .background(.black)
            .opacity(textPickerViewModel.showingBoxes ? 0.7 : 1)
            .animation(.default, value: textPickerViewModel.showingBoxes)
    }
}
