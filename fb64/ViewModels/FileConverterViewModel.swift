import SwiftUI
import Combine
import UniformTypeIdentifiers

@MainActor
class FileConverterViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var selectedFile: FileInfo?
    @Published var isEncoding: Bool = false
    @Published var isDecoding: Bool = false
    @Published var errorMessage: String?
    @Published var showFilePicker: Bool = false
    @Published var showShareSheet: Bool = false
    @Published var showSuccess: Bool = false
    @Published var showError: Bool = false
    @Published var recentFiles: [FileInfo] = []
    
    private let fileService = FileService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        fileService.$recentFiles
            .receive(on: RunLoop.main)
            .assign(to: \.recentFiles, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func encodeFile(_ url: URL) async {
        isEncoding = true
        errorMessage = nil
        
        do {
            let base64String = try await fileService.encodeFile(url)
            inputText = base64String
            showSuccess = true
        } catch {
            handleError(error)
        }
        
        isEncoding = false
    }
    
    func decodeFile() async {
        guard !inputText.isEmpty else { return }
        isDecoding = true
        errorMessage = nil
        
        do {
            // Try to get file extension from input (if it's a data URL)
            let fileExtension = try extractFileExtension(from: inputText) ?? "bin"
            let fileName = "decoded_\(Int(Date().timeIntervalSince1970))"
            
            let fileInfo = try fileService.decodeFile(
                base64String: inputText,
                fileName: fileName,
                fileExtension: fileExtension
            )
            
            selectedFile = fileInfo
            showShareSheet = true
        } catch {
            handleError(error)
        }
        
        isDecoding = false
    }
    
    func clear() {
        inputText = ""
        selectedFile = nil
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func extractFileExtension(from base64String: String) -> String? {
        // Check if it's a data URL (data:image/png;base64,...)
        if base64String.hasPrefix("data:") {
            // Extract MIME type from data URL
            let pattern = "^data:([^;]+)"
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: base64String, 
                                         range: NSRange(base64String.startIndex..., in: base64String)),
               let range = Range(match.range(at: 1), in: base64String) {
                
                let mimeType = String(base64String[range])
                
                // Try to get file extension from MIME type
                if let uttype = UTType(mimeType: mimeType),
                   let fileExtension = uttype.preferredFilenameExtension {
                    return fileExtension
                }
                
                // Fallback to common MIME type mappings
                let mimeToExt: [String: String] = [
                    "image/jpeg": "jpg",
                    "image/png": "png",
                    "image/gif": "gif",
                    "application/pdf": "pdf",
                    "text/plain": "txt",
                    "application/json": "json",
                    "audio/mpeg": "mp3",
                    "audio/wav": "wav",
                    "audio/x-wav": "wav",
                    "audio/mp4": "m4a",
                    "video/mp4": "mp4",
                    "application/zip": "zip"
                ]
                
                if let ext = mimeToExt[mimeType.lowercased()] {
                    return ext
                }
                
                // Try to extract extension from MIME type (e.g., image/png -> png)
                if let ext = mimeType.components(separatedBy: "/").last,
                   !ext.contains(";") { // Make sure it's not a complex MIME type
                    return ext
                }
            }
        }
        
        // Try to determine from magic numbers if we have enough data
        let cleanBase64 = base64String.components(separatedBy: ",").last ?? base64String
        guard let data = Data(base64Encoded: cleanBase64), data.count > 4 else { 
            return "bin" // Default to .bin if we can't determine
        }
        
        // Check for common file signatures
        if data.starts(with: [0x89, 0x50, 0x4E, 0x47]) { return "png" }
        if data.starts(with: [0xFF, 0xD8, 0xFF]) { return "jpg" }
        if data.starts(with: [0x47, 0x49, 0x46]) { return "gif" } // GIF87a/GIF89a
        if data.starts(with: [0x25, 0x50, 0x44, 0x46]) { return "pdf" } // %PDF
        if data.starts(with: [0x50, 0x4B, 0x03, 0x04]) { return "zip" } // ZIP archive
        if data.starts(with: [0x52, 0x61, 0x72, 0x21]) { return "rar" } // RAR archive
        if data.starts(with: [0x37, 0x7A, 0xBC, 0xAF]) { return "7z" }  // 7z archive
        
        // Audio formats
        if data.starts(with: [0x52, 0x49, 0x46, 0x46]) { // RIFF
            return data.count > 8 && data[8...11] == [0x57, 0x41, 0x56, 0x45] ? "wav" : "webp"
        }
        if data.starts(with: [0x49, 0x44, 0x33]) { return "mp3" } // ID3
        if data.starts(with: [0x66, 0x4C, 0x61, 0x43]) { return "flac" } // flac
        
        // Default to binary if we can't determine the type
        return "bin"
    }
    
    private func handleError(_ error: Error) {
        if let fileError = error as? FileServiceError {
            errorMessage = fileError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
    }
}

// MARK: - Extensions

private extension Data {
    func starts(with bytes: [UInt8]) -> Bool {
        guard count >= bytes.count else { return false }
        return prefix(bytes.count).elementsEqual(bytes)
    }
    
    subscript(bounds: ClosedRange<Int>) -> [UInt8] {
        return Array(self[bounds])
    }
}

private extension UTType {
    init?(mimeType: String) {
        // Remove 'data:' prefix if present
        let mimeType = mimeType.replacingOccurrences(of: "data:", with: "")
        
        // Try to create from MIME type
        if let uttype = UTType(mimeType: mimeType) {
            self = uttype
            return
        }
        
        // Try to extract file extension and create from that
        if let fileExtension = mimeType.components(separatedBy: "/").last,
           let uttype = UTType(filenameExtension: fileExtension) {
            self = uttype
            return
        }
        
        // Try with common MIME type mappings
        let mimeMappings: [String: UTType] = [
            "image/jpeg": .jpeg,
            "image/png": .png,
            "image/gif": .gif,
            "application/pdf": .pdf,
            "text/plain": .plainText,
            "application/json": .json,
            "audio/mpeg": .mp3,
            "audio/wav": .wav,
            "audio/x-wav": .wav,
            "audio/mp4": .mpeg4Audio,
            "video/mp4": .mpeg4Movie,
            "application/zip": .zip
        ]
        
        if let uttype = mimeMappings[mimeType.lowercased()] {
            self = uttype
            return
        }
        
        return nil
    }
}
