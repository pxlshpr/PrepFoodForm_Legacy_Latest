import SwiftUI
import SwiftUISugar
import FoodLabelScanner
import PhotosUI
import MFPScraper
import PrepDataTypes
import SwiftHaptics
import FoodLabelExtractor

public struct FoodForm: View {
    
    @Environment(\.dismiss) var dismiss
    
    let didSave: (FoodFormOutput) -> ()
    
    @State var showingCancelConfirmation = false

    /// ViewModels
    @ObservedObject var fields: Fields
    @ObservedObject var sources: Sources
    @ObservedObject var extractor: Extractor

    //MARK: ☣️
//    @ObservedObject var scanner: LabelScannerViewModel
//    @ObservedObject var interactiveScanner: ScannerViewModel

    /// Sheets
    @State var showingEmojiPicker = false
    @State var showingFoodLabelCamera = false
    @State var showingPhotosPicker = false
    @State var showingPrefill = false
    @State var showingPrefillInfo = false
    @State var showingTextPicker = false
    @State var showingBarcodeScanner = false

    @State var showingAddLinkAlert = false
    @State var shouldShowBottomButtons = false

    @State var showingExtractorView: Bool = false
    
    @State var showingLabelScanner: Bool
    @State var animateLabelScannerUp: Bool

    @State var selectedPhoto: UIImage? = nil

    /// Menus
    @State var showingFoodLabel = false

    /// Wizard
    @State var shouldShowWizard: Bool
    @State var showingWizard = true
    @State var showingWizardOverlay = true
    @State var formDisabled = false

    /// Barcode
    @State var showingAddBarcodeAlert = false
    @State var barcodePayload: String = ""
    
    let didScanFoodLabel = NotificationCenter.default.publisher(for: .didScanFoodLabel)
    
    @State var initialScanResult: ScanResult?
    @State var initialScanImage: UIImage?

    @State var mockScanResult: ScanResult?
    @State var mockScanImage: UIImage?

    public init(
        mockScanResult: ScanResult,
        mockScanImage: UIImage,
        fields: FoodForm.Fields,
        sources: FoodForm.Sources,
        extractor: Extractor,
        //MARK: ☣️
//        scanner: LabelScannerViewModel,
//        interactiveScanner: ScannerViewModel,
        didSave: @escaping (FoodFormOutput) -> ()
    ) {
        Fields.shared = fields
        Sources.shared = sources
        self.fields = fields
        self.sources = sources
        self.extractor = extractor
        //MARK: ☣️
//        self.scanner = scanner
//        self.interactiveScanner = interactiveScanner
        self.didSave = didSave
        _initialScanResult = State(initialValue: nil)
        _initialScanImage = State(initialValue: nil)
        _mockScanResult = State(initialValue: mockScanResult)
        _mockScanImage = State(initialValue: mockScanImage)
        _showingLabelScanner = State(initialValue: false)
        _animateLabelScannerUp = State(initialValue: false)
        _shouldShowWizard = State(initialValue: true)
    }

    public init(
        fields: FoodForm.Fields,
        sources: FoodForm.Sources,
        extractor: Extractor,
        //MARK: ☣️
//        scanner: LabelScannerViewModel,
//        interactiveScanner: ScannerViewModel,
        startWithLabelScanner: Bool = false,
        didSave: @escaping (FoodFormOutput) -> ()
    ) {
        Fields.shared = fields
        Sources.shared = sources
        self.fields = fields
        self.sources = sources
        self.extractor = extractor
        //MARK: ☣️
//        self.scanner = scanner
//        self.interactiveScanner = interactiveScanner
        self.didSave = didSave
        _initialScanResult = State(initialValue: nil)
        _initialScanImage = State(initialValue: nil)
        _mockScanResult = State(initialValue: nil)
        _mockScanImage = State(initialValue: nil)
        _showingLabelScanner = State(initialValue: startWithLabelScanner)
        _animateLabelScannerUp = State(initialValue: startWithLabelScanner)
        _shouldShowWizard = State(initialValue: !startWithLabelScanner)
    }
    
    public init(
        fields: FoodForm.Fields,
        sources: FoodForm.Sources,
        extractor: Extractor,
        scanResult: ScanResult,
        //MARK: ☣️
//        scanner: LabelScannerViewModel,
//        interactiveScanner: ScannerViewModel,
        image: UIImage,
        didSave: @escaping (FoodFormOutput) -> ()
    ) {
        Fields.shared = fields
        Sources.shared = sources
        self.fields = fields
        self.sources = sources
        self.extractor = extractor
        //MARK: ☣️
//        self.scanner = scanner
//        self.interactiveScanner = interactiveScanner
        self.didSave = didSave
        _shouldShowWizard = State(initialValue: false)
        _initialScanResult = State(initialValue: scanResult)
        _initialScanImage = State(initialValue: image)
        _mockScanResult = State(initialValue: nil)
        _mockScanImage = State(initialValue: nil)
        _showingLabelScanner = State(initialValue: false)
        _animateLabelScannerUp = State(initialValue: false)
        _shouldShowWizard = State(initialValue: true)
    }
    
    public var body: some View {
//        let _ = Self._printChanges()
        return content
    }

    var content: some View {
        ZStack {
            navigationView
            extractorViewLayer
                .zIndex(2)
        }
    }
    
    let keyboardDidShow = NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)
    let keyboardDidHide = NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)
    func keyboardDidShow(_ notification: Notification) {
        withAnimation {
            shouldShowBottomButtons = false
        }
    }
    func keyboardDidHide(_ notification: Notification) {
        withAnimation {
            shouldShowBottomButtons = true
        }
    }

    var navigationView: some View {
        NavigationView {
            formContent
                .navigationTitle("New Food")
                .toolbar { navigationLeadingContent }
                .toolbar { navigationTrailingContent }
                .onAppear(perform: appeared)
                .onChange(of: sources.selectedPhotos, perform: selectedPhotosChanged)
//                .onChange(of: sources.selectedPhotos, perform: sources.selectedPhotosChanged)
                .onChange(of: showingWizard, perform: showingWizardChanged)
//                .onChange(of: showingAddLinkAlert, perform: showingAddLinkAlertChanged)
//                .onChange(of: showingAddBarcodeAlert, perform: showingAddBarcodeAlertChanged)
                .onReceive(keyboardDidShow, perform: keyboardDidShow)
                .onReceive(keyboardDidHide, perform: keyboardDidHide)
                .onReceive(didScanFoodLabel, perform: didScanFoodLabel)
            
                .sheet(isPresented: $showingEmojiPicker) { emojiPicker }
                .sheet(isPresented: $showingPrefill) { mfpSearch }
                .fullScreenCover(isPresented: $showingBarcodeScanner) { barcodeScanner }
//                .sheet(isPresented: $showingBarcodeScanner) { barcodeScanner }
                .sheet(isPresented: $showingPrefillInfo) { prefillInfo }
                .alert(addBarcodeTitle,
                       isPresented: $showingAddBarcodeAlert,
                       actions: { addBarcodeActions },
                       message: { addBarcodeMessage })
            //MARK: ☣️
//                .fullScreenCover(isPresented: $showingTextPicker) { textPicker }
                .photosPicker(
                    isPresented: $showingPhotosPicker,
                    selection: $sources.selectedPhotos,
//                    maxSelectionCount: sources.availableImagesCount,
                    maxSelectionCount: 1,
                    matching: .images
                )
            //MARK: ☣️
//                .onChange(of: sources.columnSelectionInfo) { columnSelectionInfo in
//                    if columnSelectionInfo != nil {
//                        self.showingTextPicker = true
//                    }
//                }
        }
    }
    
    func showingWizardChanged(_ showingWizard: Bool) {
        withAnimation {
            shouldShowBottomButtons = !showingWizard
        }
    }
    
    func showingAddLinkAlertChanged(_ showingAddLinkAlert: Bool) {
        withAnimation {
            shouldShowBottomButtons = !showingAddLinkAlert
        }
    }
    
    func showingAddBarcodeAlertChanged(_ showingAddBarcodeAlert: Bool) {
        withAnimation {
            shouldShowBottomButtons = !showingAddBarcodeAlert
        }
    }
 
    @ViewBuilder
    var extractorViewLayer: some View {
        if showingExtractorView {
            ExtractorView(extractor: extractor)
        }
    }

    func selectedPhotosChanged(to items: [PhotosPickerItem]) {
//        guard let item = items.first else { return }
//        presentLabelScanner(forCamera: false)
//        let _ = ImageViewModel(photosPickerItem: item) { image in
//                self.selectedPhoto = image
//        }
//        sources.selectedPhotos = []

        guard let item = items.first else { return }
        showExtractor(with: item)
        sources.selectedPhotos = []
    }
    
    var formContent: some View {
        ZStack {
            formLayer
            wizardLayer
//            if shouldShowBottomButtons {
//                buttonsLayer
//                    .transition(.move(edge: .bottom))
//            }
        }
    }
    
    func dismissHandler() {
        withAnimation {
            animateLabelScannerUp = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingLabelScanner = false
        }
    }
    
    func imageHandler(_ image: UIImage, scanResult: ScanResult) {
        sources.add(image, with: scanResult)
    }
    
    func scanResultHandler(_ scanResult: ScanResult, column: Int? = nil) {
        Haptics.successFeedback()
        if let column = column {
            extract(column: column, from: [scanResult], shouldOverwrite: true)
        } else {
            extractFieldsOrShowColumnSelectionInfo()
        }
    }

    //MARK: - Layers
    
    @State var showingSaveButtons = false
    @Environment(\.colorScheme) var colorScheme
    
    @ViewBuilder
    var formLayer: some View {
        FormStyledScrollView(showsIndicators: false) {
            detailsSection
            servingSection
            foodLabelSection
            sourcesSection
            barcodesSection
            prefillSection
//            Spacer().frame(height: 38)
        }
//        .safeAreaInset(edge: .bottom) { safeAreaInset }
        .overlay(overlay)
        .blur(radius: showingWizardOverlay ? 5 : 0)
        .disabled(formDisabled)
    }
    
    var backgroundColor: Color {
//        Color(.systemGroupedBackground)
        colorScheme == .dark ? Color(hex: "1C1C1E") : Color(hex: "F2F1F6")
    }
    
    @ViewBuilder
    var safeAreaInset: some View {
//        if fields.canBeSaved {
            //TODO: Programmatically get this inset (67516AA6)
            Spacer()
//                .frame(height: 137)
                .frame(height: 157)
//        }
    }
    
    @ViewBuilder
    var overlay: some View {
        if showingWizardOverlay {
            Color(.quaternarySystemFill)
                .opacity(showingWizardOverlay ? 0.3 : 0)
        }
    }
    
    @ViewBuilder
    var wizardLayer: some View {
        if showingWizard {
            Wizard(tapHandler: tappedWizardButton)
        }
    }
    
    var dismissButtonRow: some View {
        var button: some View {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.down.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        Color(.tertiaryLabel),
                        Color(.quaternaryLabel)
                            .opacity(0.5)
                    )
                    .font(.system(size: 30))
            }
            .shadow(color: Color(.label).opacity(0.25), radius: 2, x: 0, y: 2)
        }
        
        return HStack {
            button
            Spacer()
        }
        .padding(.bottom, 30)
        .padding(.horizontal, 20)
    }
    
    var buttonsLayer: some View {
        
        let saveIsDisabled = Binding<Bool>(
            get: { !fields.canBeSaved },
            set: { _ in }
        )
        let saveSecondaryIsDisabled = Binding<Bool>(
            get: { !sources.canBePublished },
            set: { _ in }
        )
        let info = Binding<FormSaveInfo?>(
            get: { formSaveInfo },
            set: { _ in }
        )

        var saveTitle: String {
            /// [ ] Do this
//            if isEditingPublicFood {
//                return "Resubmit to Public Foods"
//            } else {
                return "Submit to Public Foods"
//            }
        }
        
        var saveSecondaryTitle: String {
            /// [ ] Do this
//            if isEditingPublicFood {
//                return "Save and Make Private"
//            } else if isEditingPrivateFood {
//                return "Save Private Food"
//            } else {
                return "Add as Private Food"
//            }
        }
        
        /// [ ] Check if form is dirty (if editing), or if new, if there's been substantial data entered
        let cancelAction = FormConfirmableAction(
            shouldConfirm: fields.isDirty,
            message: nil,
            buttonTitle: nil) {
                Haptics.feedback(style: .soft)
                dismiss()
            }
        
        let saveAction = FormConfirmableAction {
            guard let data = foodFormOutput(shouldPublish: true) else {
                return
            }
            didSave(data)
            dismiss()
        }

        let saveSecondaryAction = FormConfirmableAction {
            guard let data = foodFormOutput(shouldPublish: false) else {
                return
            }
            didSave(data)
            dismiss()
        }

        return FormDualSaveLayer(
            saveIsDisabled: saveIsDisabled,
            saveSecondaryIsDisabled: saveSecondaryIsDisabled,
            saveTitle: saveTitle,
            saveSecondaryTitle: saveSecondaryTitle,
            info: info,
            preconfirmationAction: nil,
            cancelAction: cancelAction,
            saveAction: saveAction,
            saveSecondaryAction: saveSecondaryAction,
            deleteAction: nil
        )
//        .edgesIgnoringSafeArea(.bottom)
    }

    var buttonsLayer_legacy: some View {
        VStack {
            Spacer()
            if !showingWizard {
                dismissButtonRow
                    .transition(.move(edge: .bottom))
            }
            if fields.canBeSaved {
                saveButtons
                    .transition(.move(edge: .bottom))
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    var saveButtons: some View {
        var publicButton: some View {
            FormPrimaryButton(title: "Submit to Prep Database") {
                guard let data = foodFormOutput(shouldPublish: true) else {
                    return
                }
                didSave(data)
                dismiss()
            }
        }
        
        var privateButton: some View {
            FormSecondaryButton(title: "Add to Private Database") {
                guard let data = foodFormOutput(shouldPublish: false) else {
                    return
                }
                didSave(data)
                dismiss()
            }
        }
        
        return VStack(spacing: 0) {
            Divider()
            VStack {
                if sources.canBePublished {
                    publicButton
                        .padding(.top)
                    privateButton
                } else {
                    privateButton
                        .padding(.vertical)
                }
            }
            /// ** REMOVE THIS HARDCODED VALUE for the safe area bottom inset **
            .padding(.bottom, 30)
        }
        .background(.thinMaterial)
    }
    
    //MARK: - Toolbars
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            dismissButton
        }
    }
    
    var dismissButton: some View {
        var confirmationActions: some View {
            Button("Close without saving", role: .destructive) {
                dismiss()
            }
        }

        var confirmationMessage: some View {
            Text("Are you sure?")
        }
        
        return Button {
            if fields.isDirty {
                Haptics.warningFeedback()
                showingCancelConfirmation = true
            } else {
                dismiss()
            }
        } label: {
            CloseButtonLabel(forNavigationBar: true)
        }
        .confirmationDialog(
            "",
            isPresented: $showingCancelConfirmation,
            actions: { confirmationActions },
            message: { confirmationMessage }
        )
    }

    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
        }
    }
}

extension FoodForm {
    var statusMessage: String? {
        guard !(showingWizard || fields.isInEmptyState) else {
            return nil
        }
        if let missingField = fields.missingRequiredField {
            return "Missing \(missingField)"
        } else {
            if sources.canBePublished {
                return nil
            } else {
                return "Missing source"
            }
        }
    }
    
    func tappedNoSource() {
        
    }

    func tappedMissingRequiredFields() {
        
    }

    var formSaveInfo: FormSaveInfo? {
        guard !(showingWizard || fields.isInEmptyState) else {
            return nil
        }
        
        if fields.missingRequiredFields.count > 1 {
            return FormSaveInfo(
                title: "Missing Fields",
                badge: fields.missingRequiredFields.count,
                tapHandler: tappedMissingRequiredFields)
        } else if fields.missingRequiredFields.count == 1 {
            return FormSaveInfo(
                title: "Missing \(fields.missingRequiredFields.first!)",
                systemImage: "questionmark.circle.fill",
                tapHandler: tappedMissingRequiredFields)
        } else {
            if sources.canBePublished {
                return nil
            } else {
                return FormSaveInfo(
                    title: "No Source",
                    systemImage: "info.circle.fill",
                    tapHandler: tappedNoSource)
            }
        }
    }

    
//    var statusMessageColor: Color {
//        if fields.canBeSaved {
//            if sources.canBePublished {
//                return .green.opacity(0.4)
//            } else {
//                return .yellow.opacity(0.5)
//            }
//        } else {
//            return Color(.tertiaryLabel).opacity(0.8)
//        }
//    }
}

extension FoodForm.Fields {
    var missingRequiredField: String? {
        if name.isEmpty { return "Name" }
        if amount.value.isEmpty { return "Amount" }
        if energy.value.isEmpty { return "Energy" }
        if carb.value.isEmpty { return "Carbohydrate"}
        if fat.value.isEmpty { return "Total Fats" }
        if protein.value.isEmpty { return "Protein"}
        return nil
    }
    
    var missingRequiredFields: [String] {
        var fields: [String] = []
        if name.isEmpty { fields.append("Name") }
        if amount.value.isEmpty { fields.append("Amount") }
        if energy.value.isEmpty { fields.append("Energy") }
        if carb.value.isEmpty { fields.append("Carbohydrate")}
        if fat.value.isEmpty { fields.append("Total Fats") }
        if protein.value.isEmpty { fields.append("Protein")}
        return fields
    }

    
    var isInEmptyState: Bool {
        name.isEmpty && detail.isEmpty && brand.isEmpty
        && serving.value.isEmpty
        && energy.value.isEmpty
        && carb.value.isEmpty
        && fat.value.isEmpty
        && protein.value.isEmpty
        && allSizes.isEmpty
        && allMicronutrientFields.isEmpty
        && prefilledFood == nil
    }
}
