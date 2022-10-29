import SwiftUI

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
                didTapViewOnImage?(index)
            }
            Button(role: .destructive) {
                didTapDeleteOnImage?(index)
            } label: {
                Text("Delete")
            }
        } label: {
            SourceImage(imageViewModel: imageViewModels[index])
        } primaryAction: {
            didTapViewOnImage?(index)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
    }
}
