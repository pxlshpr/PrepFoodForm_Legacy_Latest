import SwiftSugar

extension String {
    var isUppercase: Bool {
        !contains(where: { !$0.isUppercase })
    }
    
    var capitalizedIfUppercase: String {
        isUppercase ? capitalized : self
    }
}


extension String {
    
    var htmlTitle: String? {
        let openGraphPattern = #"og:title\"[^\"]*\"([^\"]*)"#
        let htmlTitlePattern = #"<title>(.*)<\/title>"#
        
        return self.secondCapturedGroup(using: htmlTitlePattern) ?? self.secondCapturedGroup(using: openGraphPattern)
    }
}
