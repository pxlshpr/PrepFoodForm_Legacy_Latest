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
    
    public init(mock: (ScanResult, UIImage)? = nil) {
        self.mock = mock
    }
    
    public var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                content
                    .edgesIgnoringSafeArea(.all)
                    .toolbar(.hidden, for: .navigationBar)
                    .navigationDestination(for: Route.self, destination: destination)
            }
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
            ImageViewer(image: image)
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
            
//            path.append(.foodForm)
        }
    }
}
