////TODO: 🗑
//
//import SwiftUI
//import SwiftHaptics
//
//struct TextBoxView: View {
//    
//    @Binding var textBox: TextBox
//    let size: CGSize
//    @Binding var shimmering: Bool
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                if let tapHandler = textBox.tapHandler {
//                    button(tapHandler)
//                } else {
//                    box
//                }
//                Spacer()
//            }
//            Spacer()
//        }
//        .offset(x: rect.minX, y: rect.minY)
//    }
//    
//    var rect: CGRect {
//        textBox.boundingBox.rectForSize(size)
//    }
//    
//    func button(_ didTap: @escaping () -> ()) -> some View {
//        Button {
////            Haptics.successFeedback()
//            didTap()
//        } label: {
//            box
//        }
//    }
//    
//    @ViewBuilder
//    var box: some View {
//        if shimmering {
//            box_legacy
//        } else if textBox.tapHandler != nil {
//            FocusRectangle(color: textBox.color)
//                .frame(width: rect.width, height: rect.height)
//        } else {
////            box_legacy
//
////            FocusRectangle(color: textBox.color)
////                .frame(width: rect.width, height: rect.height)
//
//            RoundedRectangle(cornerRadius: 2.0, style: .continuous)
//                .foregroundColor(textBox.color.opacity(0.4))
//                .frame(width: rect.width, height: rect.height)
//        }
//    }
//    
//    var box_legacy: some View {
//        RoundedRectangle(cornerRadius: 3)
//            .foregroundColor(textBox.color)
//            .opacity(textBox.opacity)
//            .frame(width: rect.width,
//                   height: rect.height)
//        
//            .overlay(
//                RoundedRectangle(cornerRadius: 3)
//                    .stroke(textBox.color, lineWidth: 1)
//                    .opacity(0.8)
//            )
//            .shadow(radius: 3, x: 0, y: 2)
//        //            .opacity(isPaging ? 0 : 1)
//        //            .animation(.default, value: isPaging)
//    }
//}
//
//struct FocusRectangle: View {
//    
//    var color: Color
//    
//    var body: some View {
//        GeometryReader { proxy in
//            ZStack {
//                overlay(proxy)
//                if proxy.size.width < proxy.size.height {
//                    tall(proxy)
//                } else if proxy.size.width > proxy.size.height {
//                    wide(proxy)
//                } else {
//                    square(proxy)
//                }
//            }
//        }
//    }
//    
//    func overlay(_ proxy: GeometryProxy) -> some View {
//        RoundedRectangle(cornerRadius: cornerRadius(proxy), style: .continuous)
//            .foregroundColor(color.opacity(0.2))
////            .opacity(0)
//    }
//    
//    func tall(_ proxy: GeometryProxy) -> some View {
//        ZStack {
//            VStack(spacing: 0) {
//                ZStack {
//                    ForEach([0.5, 0.75], id: \.self) {
//                        RoundedRectangle(cornerRadius: cornerRadius(proxy), style: .continuous)
//                            .trim(from: $0 + 0.0625, to: $0 + 0.25 - 0.0625)
//                            .stroke(color, lineWidth: lineWidth(proxy))
//                    }
//                    .frame(width: proxy.size.width, height: proxy.size.width)
//                }
//                Color.clear
//                    .frame(height: proxy.size.height - proxy.size.width)
//            }
//            .frame(height: proxy.size.height)
//            VStack(spacing: 0) {
//                Color.clear
//                    .frame(height: proxy.size.height - proxy.size.width)
//                ZStack {
//                    ForEach([0, 0.25], id: \.self) {
//                        RoundedRectangle(cornerRadius: cornerRadius(proxy), style: .continuous)
//                            .trim(from: $0 + 0.0625, to: $0 + 0.25 - 0.0625)
//                            .stroke(color, lineWidth: lineWidth(proxy))
//                    }
//                    .frame(width: proxy.size.width, height: proxy.size.width)
//                }
//            }
//            .frame(height: proxy.size.height)
//        }
//    }
//    
//    func wide(_ proxy: GeometryProxy) -> some View {
//        ZStack {
//            HStack {
//                ZStack {
//                    ForEach([0.25, 0.5], id: \.self) {
//                        RoundedRectangle(cornerRadius: cornerRadius(proxy), style: .continuous)
//                            .trim(from: $0 + 0.0625, to: $0 + 0.25 - 0.0625)
//                            .stroke(color, lineWidth: lineWidth(proxy))
//                    }
//                    .frame(width: proxy.size.height, height: proxy.size.height)
//                }
//                Spacer()
//            }
//            HStack {
//                Spacer()
//                ZStack {
//                    ForEach([0, 0.75], id: \.self) {
//                        RoundedRectangle(cornerRadius: cornerRadius(proxy), style: .continuous)
//                            .trim(from: $0 + 0.0625, to: $0 + 0.25 - 0.0625)
//                            .stroke(color, lineWidth: lineWidth(proxy))
//                    }
//                    .frame(width: proxy.size.height, height: proxy.size.height)
//                }
//            }
//        }
//    }
//    
//    func square(_ proxy: GeometryProxy) -> some View {
//        ForEach([0, 0.25, 0.5, 0.75], id: \.self) {
//            RoundedRectangle(cornerRadius: cornerRadius(proxy), style: .continuous)
//                .trim(from: $0 + 0.0625, to: $0 + 0.25 - 0.0625)
//                .stroke(color, lineWidth: lineWidth(proxy))
//        }
//    }
//    
//    func cornerRadius(_ proxy: GeometryProxy) -> CGFloat {
//        2.0
////        max(min(proxy.size.width, proxy.size.height) / 10.0, 2)
//    }
//
//    func lineWidth(_ proxy: GeometryProxy) -> CGFloat {
//        0.75
////        max(min(min(proxy.size.width, proxy.size.height) / 11.0, 5.0), 1)
//    }
//}
