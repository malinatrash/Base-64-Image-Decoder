import SwiftUI

struct RecentFileView: View {
    let file: FileInfo
    let onSelect: () -> Void
    let onExport: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: fileIcon)
                .font(.title)
                .frame(width: 60, height: 60)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundColor(.accentColor)
            
            Text(file.name)
                .font(.caption)
                .lineLimit(1)
                .frame(width: 80)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
        .contextMenu {
            Button(action: onExport) {
                Label("Save to Files", systemImage: "square.and.arrow.down")
            }
            
            Button(role: .destructive, action: {}) {
                Label("Remove", systemImage: "trash")
            }
        }
    }
    
    private var fileIcon: String {
        switch file.type.rawValue.lowercased() {
        case "image": return "photo"
        case "pdf": return "doc.richtext"
        case "text": return "doc.text"
        case "audio": return "waveform"
        case "video": return "film"
        case "archive": return "doc.zipper"
        default: return "doc"
        }
    }
}

#Preview {
    RecentFileView(
        file: FileInfo(
            name: "example.jpg",
            size: 1024 * 1024, // 1MB
            type: .image,
            data: Data(),
            created: Date()
        ),
        onSelect: {},
        onExport: {}
    )
}
