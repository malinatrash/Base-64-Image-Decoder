import SwiftUI
import AVFoundation

enum ContentType: Identifiable, CaseIterable {
    case image
    case text
    case json
    case pdf
    case audio
    
    var id: String { "\(self)" }
    
    var title: String {
        switch self {
        case .image: return "Image"
        case .text: return "Text"
        case .json: return "JSON"
        case .pdf: return "PDF"
        case .audio: return "Audio"
        }
    }
    
    var icon: String {
        switch self {
        case .image: return "photo"
        case .text: return "text.alignleft"
        case .json: return "curlybraces"
        case .pdf: return "doc.text"
        case .audio: return "speaker.wave.2"
        }
    }
}

struct DecodedContent: Identifiable {
    let id = UUID()
    let type: ContentType
    let data: Data
    let preview: AnyView
    
    init?(data: Data) {
        self.data = data
        
        // Try to determine content type
        if let _ = UIImage(data: data) {
            self.type = .image
            self.preview = AnyView(ImagePreview(data: data))
        } else if let _ = try? JSONSerialization.jsonObject(with: data) {
            self.type = .json
            self.preview = AnyView(TextPreview(text: String(data: data, encoding: .utf8) ?? ""))
        } else if let text = String(data: data, encoding: .utf8) {
            self.type = .text
            self.preview = AnyView(TextPreview(text: text))
        } else if DecodedContent.isAudioData(data) {
            self.type = .audio
            self.preview = AnyView(AudioPreview(data: data))
        } else {
            return nil
        }
    }
    
    private static func isAudioData(_ data: Data) -> Bool {
        // Check for common audio file signatures
        let audioSignatures: [[UInt8]] = [
            [0x52, 0x49, 0x46, 0x46], // WAV
            [0x49, 0x44, 0x33],       // MP3 ID3
            [0xFF, 0xFB],             // MP3
            [0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x41], // M4A
            [0x4F, 0x67, 0x67, 0x53], // OGG
            [0x1A, 0x45, 0xDF, 0xA3]  // WebM/Matroska
        ]
        
        // Check if data starts with any known audio signature
        return audioSignatures.contains { signature in
            guard data.count >= signature.count else { return false }
            return [UInt8](data.prefix(signature.count)) == signature
        }
    }
}
