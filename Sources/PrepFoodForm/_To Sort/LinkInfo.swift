import SwiftUI

class LinkInfo: ObservableObject {
    let url: URL
    @Published var title: String?
    @Published var faviconImage: UIImage?
    
    var urlString: String {
        url.absoluteString
    }
    
    var urlDisplayString: String {
        url.host ?? urlString
    }
    
    init?(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return nil
        }
        self.url = url
        self.title = nil
        self.faviconImage = nil
        getTitle()
        getFavicon()
    }
    
    func getTitle() {
        Task {
            let content = try String(contentsOf: url, encoding: .utf8)
            guard let htmlTitle = content.htmlTitle else {
                return
            }
            await MainActor.run {
                withAnimation {
                    self.title = String(htmlEncodedString: htmlTitle)
                }
            }
        }
    }
    
    func getFavicon() {
        let urlString = "https://www.google.com/s2/favicons?sz=32&domain=\(urlString)"
        guard let url = URL(string: urlString) else {
            return
        }
        Task {
            let request = URLRequest.init(url: url)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                return
            }
            guard let image = UIImage(data: data) else {
                return
            }
            await MainActor.run {
                withAnimation {
                    self.faviconImage = image
                }
            }
        }
    }
}

struct FavIcon {
    enum Size: Int, CaseIterable { case s = 16, m = 32, l = 64, xl = 128, xxl = 256, xxxl = 512 }
    private let domain: String
    init(_ domain: String) { self.domain = domain }
    subscript(_ size: Size) -> String {
        "https://www.google.com/s2/favicons?sz=32&domain=\(domain)"
    }
}

extension String {

    init?(htmlEncodedString: String) {

        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }

        self.init(attributedString.string)

    }
}
