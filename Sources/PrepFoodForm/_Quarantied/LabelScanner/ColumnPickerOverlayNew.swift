//import SwiftUI
//import SwiftHaptics
//
//public struct ColumnPickerOverlayNew: View {
//    
//    @Environment(\.colorScheme) var colorScheme
////    let colorScheme: ColorScheme = .dark
//    
//    @Binding var isVisibleBinding: Bool
//    @Binding var selectedColumn: Int
//    var didTapDismiss: (() -> ())?
//    let didTapAutofill: () -> ()
//    
//    let leftTitle: String
//    let rightTitle: String
//    
//    public init(
//        isVisibleBinding: Binding<Bool>,
//        leftTitle: String,
//        rightTitle: String,
//        selectedColumn: Binding<Int>,
//        didTapDismiss: (() -> ())? = nil,
//        didTapAutofill: @escaping () -> ()
//    ) {
//        _isVisibleBinding = isVisibleBinding
//        _selectedColumn = selectedColumn
//        self.leftTitle = leftTitle
//        self.rightTitle = rightTitle
//        self.didTapDismiss = didTapDismiss
//        self.didTapAutofill = didTapAutofill
//    }
//    
//    public var body: some View {
//        VStack {
//            if isVisibleBinding {
//                title
//                    .transition(.move(edge: .top))
//            }
//            Spacer()
//            if isVisibleBinding {
//                bottomVStack
//                    .transition(.move(edge: .bottom))
//                    .padding(.bottom, 50)
//            }
//        }
//        .padding(.horizontal, 20)
//        .edgesIgnoringSafeArea(.all)
//    }
//    
//    var bottomVStack: some View {
//        VStack {
////            dismissButtonRow
//            segmentedPicker
//            HStack {
//                /// Blank space for dismiss button to show up
//                Color.clear
//                    .frame(width: 50, height: 50)
//                autoFillButton
//            }
//        }
//    }
//    
//    @State private var dragTranslationX: CGFloat?
//    
//    var segmentedPicker: some View {
//        ZStack {
//            background
//            button
//            texts
//        }
//        .frame(height: 50)
//        .highPriorityGesture(dragGesture)
////        .gesture(dragGesture)
//    }
//    
//    var r: CGFloat { 3 }
//    
//    var innerTopLeftShadowColor: Color {
//        colorScheme == .light
//        ? Color(red: 197/255, green: 197/255, blue: 197/255)
//        : Color(hex: "232323")
//    }
//
//    var innerBottomRightShadowColor: Color {
//        colorScheme == .light
//        ? Color.white
//        : Color(hex: "3D3E44")
//    }
//
//    var backgroundColor: Color {
//        colorScheme == .light
//        ? Color(red: 236/255, green: 234/255, blue: 235/255)
//        : Color(hex: "303136")
//    }
//    
//    var background: some View {
//        RoundedRectangle(cornerRadius: 15, style: .continuous)
//            .fill(
//                .shadow(.inner(color: innerTopLeftShadowColor,radius: r, x: r, y: r))
//                .shadow(.inner(color: innerBottomRightShadowColor, radius: r, x: -r, y: -r))
//            )
//            .foregroundColor(backgroundColor)
//    }
//    
//    var leftButton: some View {
//        Button {
//            Haptics.feedback(style: .soft)
//            withAnimation(.interactiveSpring()) {
//                selectedColumn = 1
//            }
//        } label: {
//            Text(leftTitle)
//                .font(.system(size: 18, weight: .semibold, design: .default))
//                .foregroundColor(selectedColumn == 1 ? .white : .secondary)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .contentShape(Rectangle())
//        }
//    }
//    
//    var rightButton: some View {
//        Button {
//            Haptics.feedback(style: .soft)
//            withAnimation(.interactiveSpring()) {
//                selectedColumn = 2
//            }
//        } label: {
//            Text(rightTitle)
//                .font(.system(size: 18, weight: .semibold, design: .default))
//                .foregroundColor(selectedColumn == 2 ? .white : .secondary)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .contentShape(Rectangle())
//        }
//    }
//    
//    var autoFillButton: some View {
//        Button {
//            didTapAutofill()
//        } label: {
////            Text("Autofill this column")
//            Text("Use this column")
//                .font(.system(size: 22, weight: .semibold, design: .default))
////                .font(.system(size: 18, weight: .semibold, design: .default))
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .frame(height: 50)
//                .background(
//                    RoundedRectangle(cornerRadius: 12, style: .continuous)
//                        .foregroundStyle(Color.accentColor.gradient)
////                        .shadow(color: .black, radius: 2, x: 0, y: 2)
////                        .shadow(color: innerTopLeftShadowColor, radius: 2, x: 0, y: 2)
//                        .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
//                )
//                .contentShape(Rectangle())
//        }
//    }
//
//    func dragChanged(_ value: DragGesture.Value) {
////        cprint("👉🏽 drag.translation: \(value.translation)")
//        var translation = value.translation.width
//        if selectedColumn == 1 {
//            translation = max(0, translation)
//            translation = min(translation, buttonWidth)
//        } else {
//            translation = max(-buttonWidth, translation)
//            translation = min(0, translation)
//        }
//        self.dragTranslationX = translation
//    }
//    
//    var buttonIsOnRight: Bool {
//        buttonXPosition > buttonWidth
//    }
//    func dragEnded(_ value: DragGesture.Value) {
//        var transitionAnimation: Animation {
//            .interactiveSpring()
////            .default
//        }
//        
//        var cancelAnimation: Animation {
//            .interactiveSpring()
//        }
////        cprint("👉🏽 drag.translation: \(value.translation)")
//        let predictedTranslationX = value.predictedEndTranslation.width
//        let predictedButtonX = (buttonWidth / 2.0) + (selectedColumn == 2 ? buttonWidth : 0) + predictedTranslationX
//        let predictedButtonIsOnRight = predictedButtonX > buttonWidth
//        
//        if predictedButtonIsOnRight {
//            if selectedColumn == 1 {
//                Haptics.feedback(style: .soft)
//                withAnimation(transitionAnimation) {
//                    dragTranslationX = buttonWidth
//                }
//                dragTranslationX = nil
//                selectedColumn = 2
//            } else {
//                withAnimation(cancelAnimation) {
//                    dragTranslationX = nil
//                }
//            }
//        } else {
//            if selectedColumn == 2 {
//                Haptics.feedback(style: .soft)
////                dragTranslationX = nil
//                withAnimation(transitionAnimation) {
//                    dragTranslationX = -buttonWidth
//                }
//                dragTranslationX = nil
//                selectedColumn = 1
//            } else {
//                withAnimation(cancelAnimation) {
//                    dragTranslationX = nil
//                }
//            }
//        }
//    }
//    
//    var dragGesture: some Gesture {
//        DragGesture()
//            .onChanged(dragChanged)
//            .onEnded(dragEnded)
//    }
//
//    var button: some View {
//        RoundedRectangle(cornerRadius: 12, style: .continuous)
//            .foregroundStyle(Color.accentColor.gradient)
//            .shadow(color: innerTopLeftShadowColor, radius: 2, x: 0, y: 2)
//            .padding(3)
//            .frame(width: buttonWidth)
//            .position(x: buttonXPosition, y: 25)
////            .gesture(dragGesture)
//    }
//
//    var texts: some View {
//        HStack(spacing: 0) {
//            VStack {
//                leftButton
//            }
//            .frame(minWidth: 0, maxWidth: .infinity)
//            VStack {
//                rightButton
//            }
//            .frame(minWidth: 0, maxWidth: .infinity)
//
//        }
//        .frame(minWidth: 0, maxWidth: .infinity)
//    }
//    
//    var buttonWidth: CGFloat {
//        (UIScreen.main.bounds.width - 40) / 2.0
//    }
//    
//    var buttonXPosition: CGFloat {
//        var x = (buttonWidth / 2.0) + (selectedColumn == 2 ? buttonWidth : 0)
//        if let dragTranslationX {
//            x += dragTranslationX
//        }
//        return x
//    }
//    
//    var title: some View {
//        Text("Select a column")
//            .font(.title3)
//            .bold()
//            .padding(.horizontal, 22)
////            .padding(.vertical, 20)
//            .frame(height: 55)
//            .foregroundColor(colorScheme == .light ? .primary : .secondary)
//            .background(
//                RoundedRectangle(cornerRadius: 15)
//                    .foregroundColor(.clear)
//                    .background(.ultraThinMaterial)
//            )
//            .clipShape(
//                RoundedRectangle(cornerRadius: 15)
//            )
//            .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
////            .shadow(radius: 3, x: 0, y: 3)
//            .padding(.top, 62)
//    }
//    
//    var dismissButtonRow: some View {
//        HStack {
//            Button {
//                didTapDismiss?()
//            } label: {
//                Image(systemName: "chevron.down")
//                    .imageScale(.medium)
//                    .fontWeight(.medium)
//                    .foregroundColor(colorScheme == .light ? .primary : .secondary)
//                    .frame(width: 38, height: 38)
//                    .background(
//                        Circle()
//                            .foregroundStyle(.ultraThinMaterial)
//                            .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
//                    )
//            }
//            Spacer()
//        }
//    }
//}
//
//
//struct ColumnPickerOverlayNewPreview: View {
//    @State var selectedColumn: Int = 1
//    var body: some View {
//        ZStack {
//            Color.black
//            overlay
//        }
//    }
//    
//    var overlay: some View {
//        ColumnPickerOverlayNew(
//            isVisibleBinding: .constant(true),
//            leftTitle: "Per Serving",
//            rightTitle: "Per 100g",
//            selectedColumn: $selectedColumn,
//            didTapDismiss: {},
//            didTapAutofill: {}
//        )
//    }
//}
//
//struct ColumnPickerOverlayNew_Preview: PreviewProvider {
//    
//    static var previews: some View {
//        ColumnPickerOverlayNewPreview()
//    }
//}
