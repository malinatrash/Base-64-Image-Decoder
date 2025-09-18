import Foundation
import UniformTypeIdentifiers

enum FileServiceError: Error, LocalizedError {
    case fileNotFound
    case invalidData
    case encodingFailed
    case decodingFailed
    case unsupportedFileType
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound: return "File not found"
        case .invalidData: return "Invalid file data"
        case .encodingFailed: return "Failed to encode file"
        case .decodingFailed: return "Failed to decode file"
        case .unsupportedFileType: return "Unsupported file type"
        }
    }
}

@MainActor
class FileService: ObservableObject {
    static let shared = FileService()
    
    @Published var recentFiles: [FileInfo] = []
    private let maxRecentFiles = 10
    
    private init() {
        loadRecentFiles()
    }
    
    // MARK: - Public Methods
    
    /// Encodes a file to base64 string with progress tracking
    /// - Parameters:
    ///   - fileURL: URL of the file to encode
    ///   - chunkSize: Size of each chunk in bytes (default: 1MB)
    ///   - progress: Optional progress callback that reports bytes processed and total bytes
    /// - Returns: Base64 encoded string
    func encodeFile(_ fileURL: URL, chunkSize: Int = 1_048_576, progress: ((Int64, Int64) -> Void)? = nil) async throws -> String {
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        let fileSize = (attributes[.size] as? Int64) ?? 0
        
        // For small files, use the simpler method
        if fileSize < Int64(chunkSize) {
            let data = try Data(contentsOf: fileURL)
            let base64String = data.base64EncodedString()
            
            if base64String.isEmpty {
                throw FileServiceError.encodingFailed
            }
            
            let fileInfo = createFileInfo(from: fileURL, data: data)
            addToRecentFiles(fileInfo)
            
            return base64String
        }
        
        // For large files, use chunked encoding
        guard let inputStream = InputStream(url: fileURL) else {
            throw FileServiceError.fileNotFound
        }
        
        inputStream.open()
        defer { inputStream.close() }
        
        var buffer = [UInt8](repeating: 0, count: chunkSize)
        var result = ""
        var totalBytesRead: Int64 = 0
        
        while inputStream.hasBytesAvailable {
            let bytesRead = inputStream.read(&buffer, maxLength: chunkSize)
            
            if bytesRead < 0 {
                // Stream error occurred
                throw inputStream.streamError ?? FileServiceError.encodingFailed
            } else if bytesRead == 0 {
                // End of stream
                break
            }
            
            // Process the chunk
            let chunkData = Data(bytes: buffer, count: bytesRead)
            let chunkString = chunkData.base64EncodedString()
            result += chunkString
            
            // Update progress
            totalBytesRead += Int64(bytesRead)
            progress?(totalBytesRead, fileSize)
            
            // Allow the system to process other tasks
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
        
        // Create file info with the actual size
        let fileExtension = fileURL.pathExtension.lowercased()
        let fileType = FileType.from(fileExtension: fileExtension)
        let fileInfo = FileInfo(
            name: fileURL.lastPathComponent,
            size: fileSize,
            type: fileType,
            data: Data(),
            created: Date()
        )
        addToRecentFiles(fileInfo)
        
        return result
    }
    
    func decodeFile(base64String: String, fileName: String, fileExtension: String) throws -> FileInfo {
        guard let data = Data(base64Encoded: base64String) else {
            throw FileServiceError.decodingFailed
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileNameWithExtension = "\(fileName).\(fileExtension)"
        let fileURL = tempDir.appendingPathComponent(fileNameWithExtension)
        
        try data.write(to: fileURL)
        
        let fileInfo = createFileInfo(from: fileURL, data: data)
        addToRecentFiles(fileInfo)
        
        return fileInfo
    }
    
    func saveToDocuments(_ fileInfo: FileInfo) throws -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileInfo.name)
        try fileInfo.data.write(to: fileURL)
        return fileURL
    }
    
    // MARK: - Private Methods
    
    private func createFileInfo(from url: URL, data: Data) -> FileInfo {
        let fileExtension = url.pathExtension
        let fileType = FileType.from(fileExtension: fileExtension)
        
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = attributes?[.size] as? Int64 ?? 0
        let creationDate = attributes?[.creationDate] as? Date ?? Date()
        
        return FileInfo(
            name: url.lastPathComponent,
            size: fileSize,
            type: fileType,
            data: data,
            created: creationDate
        )
    }
    
    private func addToRecentFiles(_ fileInfo: FileInfo) {
        recentFiles.removeAll { $0.id == fileInfo.id }
        recentFiles.insert(fileInfo, at: 0)
        
        if recentFiles.count > maxRecentFiles {
            recentFiles = Array(recentFiles.prefix(maxRecentFiles))
        }
        
        saveRecentFiles()
    }
    
    private func saveRecentFiles() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(recentFiles) {
            UserDefaults.standard.set(encoded, forKey: "recentFiles")
        }
    }
    
    private func loadRecentFiles() {
        guard let data = UserDefaults.standard.data(forKey: "recentFiles") else { return }
        
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([FileInfo].self, from: data) {
            recentFiles = decoded
        }
    }
}

// MARK: - Preview Extensions

extension FileInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case name, size, type, data, created
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        size = try container.decode(Int64.self, forKey: .size)
        type = try container.decode(FileType.self, forKey: .type)
        data = try container.decode(Data.self, forKey: .data)
        created = try container.decode(Date.self, forKey: .created)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(size, forKey: .size)
        try container.encode(type, forKey: .type)
        try container.encode(data, forKey: .data)
        try container.encode(created, forKey: .created)
    }
}

extension FileType: Codable {}

// MARK: - Preview Data

#if DEBUG
extension FileInfo {
    static var preview: FileInfo {
        FileInfo(
            name: "sample.jpg",
            size: 1024 * 1024, // 1MB
            type: .image,
            data: Data(),
            created: Date()
        )
    }
}
#endif
