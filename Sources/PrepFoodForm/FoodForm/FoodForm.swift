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
    @State var showingDetailsForm = false
    
    @State var showingFoodLabelCamera = false
    @State var showingPhotosPicker = false
    @State var showingPrefill = false
    @State var showingPrefillInfo = false
    @State var showingTextPicker = false
    @State var showingBarcodeScanner = false
    
    @State var showingAddLinkAlert = false
    @State var showingSaveSheet = false
    @State var showingBottomButtonsSaved = false /// Used when presenting keyboard and alerts
    
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
            saveSheet
                .zIndex(3)
        }
    }
    
    let keyboardDidShow = NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)
    let keyboardDidHide = NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)
    func keyboardDidShow(_ notification: Notification) {
//        showingBottomButtonsSaved = showingBottomButtons
//        withAnimation {
//            showingBottomButtons = false
//        }
    }
    func keyboardDidHide(_ notification: Notification) {
//        withAnimation {
//            showingBottomButtons = showingBottomButtonsSaved
//        }
    }
    
    var navigationView: some View {
        NavigationView {
            formContent
            //                .edgesIgnoringSafeArea(.bottom)
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
                .sheet(isPresented: $showingDetailsForm) { detailsForm }
                .sheet(isPresented: $showingPrefill) { mfpSearch }
//                .sheet(isPresented: $showingSaveSheet) { saveSheet }
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
        //        withAnimation {
        //            showingBottomButtons = !showingWizard
        //        }
    }
    
    var saveSheet: some View {
        SaveSheet(
            isPresented: $showingSaveSheet,
            validationMessage: Binding<ValidationMessage?>(
            get: { validationMessage },
//            get: { .missingFields(["Protein"]) },
            set: { _ in }
        ), didTapSavePublic: {
            tappedSavePublic()
        }, didTapSavePrivate: {
            tappedSavePrivate()
        })
        .environmentObject(fields)
        .environmentObject(sources)
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
            toggleButtonLayer
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
        }
        .overlay(overlay)
        .blur(radius: showingWizardOverlay ? 5 : 0)
        .disabled(formDisabled)
        .safeAreaInset(edge: .bottom) { safeAreaInset }
    }
    
    var backgroundColor: Color {
        //        Color(.systemGroupedBackground)
        colorScheme == .dark ? Color(hex: "1C1C1E") : Color(hex: "F2F1F6")
    }
    
    var safeAreaInset: some View {
        Spacer()
            .frame(height: 60)
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
            //            return "Add as Private Food"
            return "Save as Private Food"
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
            tappedSavePublic()
        }
        
        let saveSecondaryAction = FormConfirmableAction {
            tappedSavePrivate()
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
    
    func tappedSavePublic() {
        guard let data = foodFormOutput(shouldPublish: true) else {
            return
        }
        didSave(data)
        dismiss()
    }
    
    func tappedSavePrivate() {
        guard let data = foodFormOutput(shouldPublish: false) else {
            return
        }
        didSave(data)
        dismiss()
    }
    
    var toggleButtonLayer: some View {
        var fontSize: CGFloat {
            25
//            22
        }
        var size: CGFloat {
            48
//            38
        }
        
        var saveButton: some View {
            var imageName: String {
                "checkmark"
            }
            
            var shouldShowAccentColor: Bool {
                fields.hasMinimumRequiredFields
            }
            
            var foregroundColor: Color {
                shouldShowAccentColor
                ? .white
                : Color(.secondaryLabel)
            }
            
            return Button {
                withAnimation {
                    showingSaveSheet.toggle()
                }
                if showingSaveSheet, !fields.hasMinimumRequiredFields {
                    Haptics.warningFeedback()
                } else {
                    Haptics.feedback(style: .soft)
                }
            } label: {
                Image(systemName: imageName)
//                    .foregroundColor(Color.gray)
                    .font(.system(size: fontSize))
                    .fontWeight(.medium)
                    .foregroundColor(foregroundColor)
                    .frame(width: size, height: size)
                    .background(
                        ZStack {
                            Circle()
                                .foregroundStyle(.ultraThinMaterial)
                            Circle()
                                .foregroundStyle(Color.accentColor.gradient)
                                .opacity(shouldShowAccentColor ? 1 : 0)
                        }
                        .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                    )

            }
        }
        
        var dismissButton: some View {
            var confirmationActions: some View {
                Button("Close without saving", role: .destructive) {
                    dismiss()
                }
            }
            
            var confirmationMessage: some View {
                Text("You have unsaved data. Are you sure?")
            }
            
            return Button {
                if fields.isDirty {
                    Haptics.warningFeedback()
                    showingCancelConfirmation = true
                } else {
                    Haptics.feedback(style: .soft)
                    dismiss()
                }
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: fontSize))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(width: size, height: size)
                    .background(
                        Circle()
                            .foregroundStyle(.ultraThinMaterial)
                        .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                    )

            }
            .confirmationDialog(
                "",
                isPresented: $showingCancelConfirmation,
                actions: { confirmationActions },
                message: { confirmationMessage }
            )
        }
        
        var layer: some View {
            VStack {
                Spacer()
                HStack {
                    dismissButton
                    Spacer()
                    saveButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 0)
            }
            .opacity(showingWizard ? 0 : 1)
        }
        
        return layer
    }
    
    var saveSheetLayer: some View {
//        ZStack {
//            if showingSaveSheet {
//                Color.black.opacity(colorScheme == .light ? 0.2 : 0.5)
//                    .transition(.opacity)
//                    .edgesIgnoringSafeArea(.all)
//            }
//            if showingSaveSheet {
//                VStack {
//                    Spacer()
//                    saveSheet
//                }
//                .edgesIgnoringSafeArea(.all)
//                .transition(.move(edge: .bottom))
//            }
//        }
        saveSheet
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
//            dismissButton
        }
    }
    
    var dismissButton: some View {
        var confirmationActions: some View {
            Button("Close without saving", role: .destructive) {
                dismiss()
            }
        }
        
        var confirmationMessage: some View {
            Text("You have unsaved data. Are you sure?")
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
    
    var validationMessage: ValidationMessage? {
//        guard !(showingWizard || fields.isInEmptyState) else {
//            return nil
//        }
//
        if !fields.missingRequiredFields.isEmpty {
            return .missingFields(fields.missingRequiredFields)
        } else if !sources.canBePublished {
            return .needsSource
        }
        return nil
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

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    func readSafeAreaInsets(onChange: @escaping (EdgeInsets) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: InsetsPreferenceKey.self, value: geometryProxy.safeAreaInsets)
            }
        )
        .onPreferenceChange(InsetsPreferenceKey.self, perform: onChange)
    }
}

private struct InsetsPreferenceKey: PreferenceKey {
    static var defaultValue: EdgeInsets = .init()
    static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {}
}
