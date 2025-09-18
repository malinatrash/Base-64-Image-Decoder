import SwiftUI
import UniformTypeIdentifiers

enum FileType: String, CaseIterable, Identifiable {
    case image = "Image"
    case audio = "Audio"
    case video = "Video"
    case document = "Document"
    case archive = "Archive"
    case other = "Other"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .image: return "photo"
        case .audio: return "speaker.wave.2"
        case .video: return "film"
        case .document: return "doc.text"
        case .archive: return "archivebox"
        case .other: return "doc"
        }
    }
    
    var fileExtensions: [String] {
        switch self {
        case .image: return ["jpg", "jpeg", "png", "gif", "heic", "webp"]
        case .audio: return ["mp3", "wav", "m4a", "aac", "flac", "ogg"]
        case .video: return ["mp4", "mov", "avi", "mkv", "webm"]
        case .document: return ["pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt"]
        case .archive: return ["zip", "rar", "7z", "tar", "gz"]
        case .other: return []
        }
    }
    
    static func from(fileExtension: String) -> FileType {
        let ext = fileExtension.lowercased()
        for type in FileType.allCases {
            if type.fileExtensions.contains(ext) {
                return type
            }
        }
        return .other
    }
}

struct FileInfo: Identifiable {
    let id = UUID()
    let name: String
    let size: Int64
    let type: FileType
    let data: Data
    let created: Date
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: created)
    }
}
