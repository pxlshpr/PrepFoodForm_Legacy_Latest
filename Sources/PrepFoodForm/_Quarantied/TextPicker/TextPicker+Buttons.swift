//import SwiftUI
//import SwiftHaptics
//
//extension TextPicker {
//
//    /**
//     Note: This used to be a multi-purpose button for both column and multi-selection modes.
//     We've now repurposed it for column selection only.
//     We would need to bring back `doneButton_legacy` below when multi-selection is needed agian.
//     */
//    var columnSelectionDoneButton: some View {
//        Button {
//            textPickerViewModel.tappedColumnSelectionDone()
//            if textPickerViewModel.shouldDismissAfterTappingDone() {
//                Haptics.feedback(style: .medium)
//                DispatchQueue.main.async {
//                    dismiss()
//                }
//            }
//        } label: {
//            HStack {
//                Image(systemName: "checkmark")
//                Text("AutoFill")
//            }
//                .font(.headline)
//                .foregroundColor(.white)
//                .padding(.horizontal, 12)
//                .frame(height: 31.5)
//                .background(
//                    RoundedRectangle(cornerRadius: 8, style: .continuous)
//                        .foregroundColor(.accentColor)
//                )
//                .padding(.leading, 10)
//                .padding(.trailing, 20)
//                .padding(.vertical, 10)
//                .contentShape(Rectangle())
//        }
//    }
//
//    @ViewBuilder
//    var doneButton_legacy: some View {
//        if textPickerViewModel.shouldShowDoneButton {
//            Button {
//                if textPickerViewModel.shouldDismissAfterTappingDone() {
//                    Haptics.successFeedback()
//                    DispatchQueue.main.async {
//                        dismiss()
//                    }
//                }
//            } label: {
//                Text("Done")
//                    .font(.title3)
//                    .bold()
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 12)
//                    .frame(height: 45)
//                    .background(
//                        RoundedRectangle(cornerRadius: 15)
//                            .foregroundColor(.accentColor.opacity(0.8))
//                            .background(.ultraThinMaterial)
//                    )
//                    .clipShape(
//                        RoundedRectangle(cornerRadius: 15)
//                    )
//                    .shadow(radius: 3, x: 0, y: 3)
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 10)
//                    .contentShape(Rectangle())
//            }
//            .disabled(textPickerViewModel.selectedImageTexts.isEmpty)
//            .transition(.scale)
//            .buttonStyle(.borderless)
//        }
//    }
//    
//    var dismissButton: some View {
//        Button {
//            Haptics.feedback(style: .soft)
//            textPickerViewModel.tappedDismiss()
//            dismiss()
//        } label: {
//            Image(systemName: "xmark")
//                .foregroundColor(.primary)
//                .frame(width: 40, height: 40)
//                .background(
//                    Circle()
//                        .foregroundColor(.clear)
//                        .background(.ultraThinMaterial)
//                        .frame(width: 40, height: 40)
//                )
//                .clipShape(Circle())
//                .shadow(radius: 3, x: 0, y: 3)
//                .padding(.horizontal, 20)
//                .padding(.vertical, 10)
//                .contentShape(Rectangle())
//        }
//    }
//
//    func selectedTextButton(for column: TextColumn) -> some View {
//        Button {
//            withAnimation {
//                textPickerViewModel.pickedColumn(column.column)
//            }
//        } label: {
//            ZStack {
//                Capsule(style: .continuous)
//                    .foregroundColor(Color.accentColor)
//                HStack(spacing: 5) {
//                    Text(column.name)
//                        .font(.title3)
//                        .bold()
//                        .foregroundColor(.white)
//                }
//                .padding(.horizontal, 15)
//                .padding(.vertical, 8)
//            }
//            .fixedSize(horizontal: true, vertical: true)
//            .contentShape(Rectangle())
//            .transition(.move(edge: .leading))
//        }
//        .frame(height: 40)
//    }
//    
//    func selectedTextButton(for imageText: ImageText) -> some View {
//        Button {
//            withAnimation {
//                textPickerViewModel.selectedImageTexts.removeAll(where: { $0 == imageText })
//            }
//        } label: {
//            ZStack {
//                Capsule(style: .continuous)
//                    .foregroundColor(Color.accentColor)
//                HStack(spacing: 5) {
//                    Text(imageText.text.string.capitalizedIfUppercase)
//                        .font(.title3)
//                        .bold()
//                        .foregroundColor(.white)
//                }
//                .padding(.horizontal, 15)
//                .padding(.vertical, 8)
//            }
//            .fixedSize(horizontal: true, vertical: true)
//            .contentShape(Rectangle())
//            .transition(.move(edge: .leading))
//        }
//        .frame(height: 40)
//    }
//    
//    func columnPicker(columns: [TextColumn]) -> some View {
//        Picker("", selection: $textPickerViewModel.selectedColumn) {
//            ForEach(columns.indices, id: \.self) { i in
//                Text(columns[i].name)
//                    .tag(i+1)
//            }
//        }
//        .pickerStyle(.segmented)
//        .padding(.leading, 20)
//        .frame(maxWidth: .infinity)
//        .frame(height: 40)
//        .onChange(of: textPickerViewModel.selectedColumn) { newValue in
//            Haptics.feedback(style: .soft)
//            textPickerViewModel.pickedColumn(newValue)
//        }
//    }
//}
//
//struct TextPickerPreview: View {
//    var body: some View {
//        VStack {
//            Spacer()
//            ZStack {
//                Color.clear
//                VStack(spacing: 0) {
//                    HStack(spacing: 0) {
//                        Picker("", selection: .constant(1)) {
//                            Text("100g").tag(1)
//                            Text("Serving").tag(2)
//                        }
//                        .pickerStyle(.segmented)
//                        .padding(.leading, 20)
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 40)
//                        Button {
//                        } label: {
//                            HStack {
//                                Image(systemName: "checkmark")
//                                Text("AutoFill")
//                            }
//                                .font(.headline)
//                                .foregroundColor(.white)
//                                .padding(.horizontal, 12)
//                                .frame(height: 31.5)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
////                                    Capsule(style: .continuous)
//                                        .foregroundColor(.accentColor)
//                                )
//                                .padding(.leading, 10)
//                                .padding(.trailing, 20)
//                                .padding(.vertical, 10)
//                                .contentShape(Rectangle())
//                        }
//                    }
//                }
//            }
//            .frame(height: 60)
//            .background(.ultraThinMaterial)
//        }
//    }
//}
//
//struct TextPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        TextPickerPreview()
//    }
//}
