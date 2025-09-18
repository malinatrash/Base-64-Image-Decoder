import SwiftUI
import UniformTypeIdentifiers

struct FileDocumentWrapper: FileDocument {
    static var readableContentTypes: [UTType] { [.data] }
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let url = URL(dataRepresentation: data, relativeTo: nil) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.url = url
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try Data(contentsOf: url)
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    // This is just a preview, actual usage requires a valid URL
    EmptyView()
}
