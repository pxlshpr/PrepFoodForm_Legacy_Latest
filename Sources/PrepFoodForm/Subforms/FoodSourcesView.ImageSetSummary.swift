import SwiftUI
import ActivityIndicatorView

struct FoodImageSetSummary: View {
    @Binding var imageSetStatus: ImageSetStatus
    
    var body: some View {
        HStack {
            Group {
                if let counts = imageSetStatus.counts {
                    summary(counts)
                } else {
                    Text(imageSetStatus.description)
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            activityIndicatorView
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .frame(minHeight: 35)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundColor(Color(.secondarySystemFill))
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func summary(_ counts: DataPointsCount) -> some View {
        VStack(alignment: .leading) {
            totalCount(counts.total)
            Group {
                autoFilledCount(counts.autoFilled)
                selectedCount(counts.selected)
                barcodesCount(counts.barcodes)
            }
            .padding(.leading, 10)
        }
    }
    
    func totalCount(_ count: Int) -> some View {
        HStack {
            Text("Found")
            numberView(count)
            Text("data point\(count != 1 ? "s": "")")
        }
    }
    
    @ViewBuilder
    func autoFilledCount(_ count: Int) -> some View {
        HStack {
            Image(systemName: "arrow.turn.down.right")
                .foregroundColor(Color(.tertiaryLabel))
            Image(systemName: "text.viewfinder")
                .frame(width: 15, alignment: .center)
            Text("AutoFilled")
                .frame(width: 70, alignment: .leading)
            numberView(count)
        }
    }
    
    @ViewBuilder
    func selectedCount(_ count: Int) -> some View {
        HStack {
            Image(systemName: "arrow.turn.down.right")
                .foregroundColor(Color(.tertiaryLabel))
            Image(systemName: "hand.tap")
                .frame(width: 15, alignment: .center)
            Text("Selected")
                .frame(width: 70, alignment: .leading)
            numberView(count)
        }
    }
    
    @ViewBuilder
    func barcodesCount(_ count: Int) -> some View {
        HStack {
            Image(systemName: "arrow.turn.down.right")
                .foregroundColor(Color(.tertiaryLabel))
            Image(systemName: "barcode")
                .frame(width: 15, alignment: .center)
            Text("Barcodes")
                .frame(width: 70, alignment: .leading)
            numberView(count)
        }
    }
    
    @ViewBuilder
    var activityIndicatorView: some View {
        if !imageSetStatus.isScanned {
            ActivityIndicatorView(
                isVisible: .constant(true),
                type: .arcs(count: 3, lineWidth: 1)
            )
                .frame(width: 12, height: 12)
                .foregroundColor(.secondary)
        }
    }
    
    func numberView(_ int: Int) -> some View {
        Text("\(int)")
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .foregroundColor(Color(.secondarySystemFill))
            )
    }
}
