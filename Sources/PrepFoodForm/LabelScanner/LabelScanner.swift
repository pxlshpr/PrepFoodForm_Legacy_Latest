import SwiftUI
import FoodLabelCamera
import FoodLabelScanner
import SwiftHaptics

public struct LabelScanner: View {
    
    enum Route: Hashable {
        case foodForm
    }
    
    let mock: (ScanResult, UIImage)?
    
    @State var startTransition: Bool = false
    @State var endTransition: Bool = false
    @State var path: [Route] = []
    
    @State var scanResult: ScanResult? = nil
    @State var image: UIImage? = nil
    
    @State var showingImageViewer = false
    
    @Binding var animatingCollapse: Bool
    
    let animateCollapse: (() -> ())?
    
    public init(
        mock: (ScanResult, UIImage)? = nil,
        animatingCollapse: Binding<Bool>? = nil,
        animateCollapse: (() -> ())? = nil
    ) {
        self.mock = mock
        self.animateCollapse = animateCollapse
        _animatingCollapse = animatingCollapse ?? .constant(false)
    }
    
    public var body: some View {
        ZStack {
//            NavigationStack(path: $path) {
                content
//                    .toolbar(.hidden, for: .navigationBar)
//                    .navigationDestination(for: Route.self, destination: destination)
//            }
        }
    }
    
    @ViewBuilder
    var content: some View {
        if showingImageViewer {
            imageViewer
        } else {
            foodLabelCamera
        }
    }
    
    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .foodForm:
            Color.blue
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    @ViewBuilder
    var imageViewer: some View {
        if let image {
            ImageViewer(image: image, contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .background(.black)
//                .scaleEffect(animatingCollapse ? 0 : 1)
//                .padding(.top, animatingCollapse ? 400 : 0)
        }
    }
    
    var foodLabelCamera: some View {
        FoodLabelCamera(mockData: mock) { scanResult, image in
            self.image = image
            self.scanResult = scanResult
            
            Haptics.successFeedback()
            
            withAnimation {
                showingImageViewer = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.animateCollapse?()
            }
            
//            path.append(.foodForm)
        }
    }
}
