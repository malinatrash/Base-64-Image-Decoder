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
    
    func encodeFile(_ fileURL: URL) async throws -> String {
        let data = try Data(contentsOf: fileURL)
        let base64String = data.base64EncodedString()
        
        if base64String.isEmpty {
            throw FileServiceError.encodingFailed
        }
        
        let fileInfo = createFileInfo(from: fileURL, data: data)
        addToRecentFiles(fileInfo)
        
        return base64String
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
