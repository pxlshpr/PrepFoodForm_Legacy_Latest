import SwiftUI
import SwiftHaptics

struct SourceImagesCarousel: View {
    
    @Binding var imageViewModels: [ImageViewModel]
    
    var didTapViewOnImage: ((Int) -> ())? = nil
    var didTapDeleteOnImage: ((Int) -> ())? = nil
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(imageViewModels.indices, id: \.self) { index in
                    sourceImage(at: index)
                        .padding(.leading, index == 0 ? 10 : 0)
                        .padding(.trailing, index ==  imageViewModels.count - 1 ? 10 : 0)
                }
            }
        }
        .listRowInsets(.init(top: 2, leading: 0, bottom: 2, trailing: 0))
    }
    
    func sourceImage(at index: Int) -> some View {
        Menu {
            Button("View") {
                Haptics.feedback(style: .soft)
                didTapViewOnImage?(index)
            }
            Button(role: .destructive) {
                Haptics.warningFeedback()
                didTapDeleteOnImage?(index)
            } label: {
                Text("Delete")
            }
        } label: {
            SourceImage(imageViewModel: imageViewModels[index])
        } primaryAction: {
            Haptics.feedback(style: .soft)
            didTapViewOnImage?(index)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
    }
}
