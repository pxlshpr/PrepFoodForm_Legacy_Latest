import SwiftUI
import SwiftUISugar

extension FoodForm {
    enum WizardButton {
        case background
        case startWithEmptyFood
        case camera
        case choosePhotos
        case prefill
        case prefillInfo
        case dismiss
    }
    
    struct Wizard: View {
        @Environment(\.colorScheme) var colorScheme
        var tapHandler: ((WizardButton) -> Void)
    }
}

struct DiarySeparatorLineColor {
    static var light = "B3B3B6"
    static var dark = "424242"
}

struct DiaryDividerLineColor {
    static var light = "D6D6D7"
    static var dark = "3a3a3a"  //"333333"
}

extension FoodForm.Wizard {
    
    var body: some View {
        ZStack {
            VStack {
                clearLayer
                newFormLayer
                clearLayer
            }
            VStack {
                Spacer()
                cancelButton
            }
            .edgesIgnoringSafeArea(.all)
        }
        .zIndex(10)
        .transition(.move(edge: .bottom))
        .edgesIgnoringSafeArea(.all)
    }
    
    var cancelButton: some View {
        Button {
            tapHandler(.dismiss)
        } label: {
            Text("Cancel")
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .foregroundStyle(.ultraThinMaterial)
                        .cornerRadius(15)
                        .shadow(color: colorScheme == .dark ? .black : .gray.opacity(0.6),
                                radius: 30, x: 0, y: 0)
                )
                .padding(.horizontal, 38)
                .padding(.bottom, 55)
                .contentShape(Rectangle())
        }
    }
    
    var newFormLayer: some View {
        ZStack {
            FormBackground()
            VStack {
                VStack(spacing: 7) {
                    Text("Scan a Food Label")
                        .foregroundColor(Color(.secondaryLabel))
                        .font(.footnote)
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    HStack {
                        Button {
                            tapHandler(.camera)
                        } label: {
                            VStack(spacing: 5) {
                                Image(systemName: "camera")
                                    .imageScale(.large)
                                    .fontWeight(.medium)
                                Text("Camera")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .foregroundStyle(Color.accentColor.gradient)
//                                    .foregroundColor(Color.accentColor)
                            )
                        }
                        Button {
                            tapHandler(.choosePhotos)
                        } label: {
                            VStack(spacing: 5) {
                                Image(systemName: "photo.on.rectangle")
                                    .imageScale(.large)
                                    .fontWeight(.medium)
                                Text("Choose")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .foregroundStyle(Color.accentColor.gradient)
//                                    .foregroundColor(Color.accentColor)
                            )
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                FormStyledSection(header: Text("Or Manually Enter It")) {
                    Button {
                        tapHandler(.startWithEmptyFood)
                    } label: {
                        Label("Empty Food", systemImage: "square.and.pencil")
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
//                    Button {
//                        tapHandler(.prefill)
//                    } label: {
//                        Label("Prefill from MyFitnessPal", systemImage: "rectangle.and.pencil.and.ellipsis")
//                            .foregroundColor(.primary)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                    }
                }
            }
        }
        .cornerRadius(20)
        .frame(height: 250)
        .frame(maxWidth: 350)
        .padding(.horizontal, 30)
        .shadow(color: colorScheme == .dark ? .black : .gray.opacity(0.6), radius: 30, x: 0, y: 0)
        .offset(y: 40)
    }
    
    var learnMoreFooter: some View {
        Button {
            tapHandler(.prefillInfo)
        } label: {
            Label("Learn more", systemImage: "info.circle")
                .font(.footnote)
        }
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
            cameraButton
            photosPickerButton
        }
    }
    
    var cameraButton: some View {
        Button {
            tapHandler(.camera)
        } label: {
            Label("Take Photos", systemImage: "camera")
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

struct WizardPreview: View {
    var body: some View {
        ZStack {
            Color(.secondarySystemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            FoodForm.Wizard { _ in
                
            }
        }
    }
}

struct Wizard_Previews: PreviewProvider {
    static var previews: some View {
        WizardPreview()
    }
}
