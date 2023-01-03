import Foundation

struct DataPointsCount {
    let total: Int
    let autoFilled: Int
    let selected: Int
    let barcodes: Int
}

extension DataPointsCount {
    init(imageViewModels: [ImageViewModel]) {
        self.total = imageViewModels.reduce(0) { $0 + $1.dataPointsCount }
        self.autoFilled = 0
        self.selected = 0
        self.barcodes = 0
    }
}
