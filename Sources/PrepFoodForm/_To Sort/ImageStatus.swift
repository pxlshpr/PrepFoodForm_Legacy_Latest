import Foundation

enum ImageStatus {
    case loading
    case notScanned
    case scanning
    case scanned
}

enum UploadStatus {
    case notUploaded
    case uploading
    case uploaded
    case uploadFailed
}
