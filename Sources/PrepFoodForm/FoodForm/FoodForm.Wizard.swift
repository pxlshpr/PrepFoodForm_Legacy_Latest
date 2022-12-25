import SwiftUI
import SwiftUISugar

extension FoodForm {
    enum WizardButton {
        case background
        case startWithEmptyFood
        case takePhotos
        case scanAFoodLabel
        case choosePhotos
        case prefill
        case prefillInfo
    }
    
    struct Wizard: View {
        @Environment(\.colorScheme) var colorScheme
        var tapHandler: ((WizardButton) -> Void)
    }
}

extension FoodForm.Wizard {
    
    var body: some View {
        VStack {
            clearLayer
            formLayer
            clearLayer
        }
        .zIndex(1)
        .transition(.move(edge: .bottom))
    }
    
    var formLayer: some View {
        Form {
            manualEntrySection
            imageSection
            thirdPartyFoodSection
        }
        .cornerRadius(20)
        .frame(height: 420)
        .frame(maxWidth: 350)
        .padding(.horizontal, 30)
        .shadow(color: colorScheme == .dark ? .black : .gray, radius: 30, x: 0, y: 0)
//        .opacity(viewModel.showingWizard ? 1 : 0)
    }
    
    var clearLayer: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                tapHandler(.background)
            }
    }
    
    //MARK: - Components
    
    var manualEntrySection: some View {
        Section("Start with an empty food") {
            Button {
                tapHandler(.startWithEmptyFood)
            } label: {
                Label("Empty Food", systemImage: "square.and.pencil")
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
        }
    }
    
    var imageSection: some View {
        var header: some View {
            Text("Scan food labels")
        }
        var footer: some View {
            Text("Provide images of nutrition fact labels or screenshots of other apps. These will be processed to extract any data from them. They will also be used to verify this food.")
        }
        
        return Section(header: header) {
            foodLabelCameraButton
            cameraButton
            photosPickerButton
        }
    }
    
    var cameraButton: some View {
        Button {
            tapHandler(.takePhotos)
        } label: {
            Label("Take Photos", systemImage: "camera")
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.borderless)
    }

    var foodLabelCameraButton: some View {
        Button {
            tapHandler(.scanAFoodLabel)
        } label: {
            Label("Scan a Food Label", systemImage: "text.viewfinder")
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.borderless)
    }

    var photosPickerButton: some View {
        Button {
            tapHandler(.choosePhotos)
        } label: {
            Label("Choose Photos", systemImage: "photo.on.rectangle")
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var thirdPartyFoodSection: some View {
        var header: some View {
            Text("Prefill a MyFitnessPal Food")
        }
        var footer: some View {
            Button {
                tapHandler(.prefillInfo)
            } label: {
                Label("Learn more", systemImage: "info.circle")
                    .font(.footnote)
            }
//            .sheet(isPresented: $showingThirdPartyInfo) {
//                MFPInfoSheet()
//                    .presentationDetents([.medium, .large])
//                    .presentationDragIndicator(.hidden)
//            }
        }
        
        return Section(header: header, footer: footer) {
            Button {
                tapHandler(.prefill)
            } label: {
                Label("Search", systemImage: "magnifyingglass")
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
        }
    }
}
