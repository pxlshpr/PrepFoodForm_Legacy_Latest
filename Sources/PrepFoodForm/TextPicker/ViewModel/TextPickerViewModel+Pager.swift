import SwiftUI

extension TextPickerViewModel {
    func pageWillChange(to index: Int) {
        withAnimation {
            currentIndex = index
        }
    }
    
    func pageDidChange(to index: Int) {
        /// Now reset the focus box for all the other images
        for i in imageViewModels.indices {
            guard i != index else { continue }
            setDefaultZoomBox(forImageAt: i)
        }
    }
    
    func page(toImageAt index: Int) {
        /// **We can't do this here, because it doesn't exist yet**
//        setDefaultZoomBox(forImageAt: index)

        let increment = index - currentIndex
        withAnimation {
            /// **This causes the `ZoomableScrollView` at `index` to be recreated if its outside the 3-item window kept in memory**
            page.update(.move(increment: increment))
            currentIndex = index
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            self.setDefaultZoomBox(forImageAt: index)
        }
        
        /// Call this manually as it won't be called on our end
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            /// **Doing this here is too late**
//            self.setDefaultZoomBox(forImageAt: index)
            self.pageDidChange(to: index)
        }
    }
    
}
