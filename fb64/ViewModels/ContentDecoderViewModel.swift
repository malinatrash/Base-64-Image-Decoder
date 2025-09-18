import Foundation
import SwiftUI
import Combine

@MainActor
class ContentDecoderViewModel: ObservableObject {
    @Published var base64String: String = ""
    @Published var decodedContent: DecodedContent?
    @Published var errorMessage: String?
    @Published var selectedContentType: ContentType = .image
    @Published var showCopiedMessage = false
    
    private var lastValidBase64: String = ""
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $base64String
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                self?.decodeContent()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func decodeContent() {
        guard !base64String.isEmpty, base64String != lastValidBase64 else { return }
        
        // Clean up the string (remove data:image/...;base64, if present)
        let cleanBase64String: String
        if let range = base64String.range(of: "base64,") {
            cleanBase64String = String(base64String[range.upperBound...])
        } else {
            cleanBase64String = base64String
        }
        
        // Try to decode the base64 string
        if let data = Data(base64Encoded: cleanBase64String) {
            if let content = DecodedContent(data: data) {
                self.decodedContent = content
                self.lastValidBase64 = base64String
                self.errorMessage = nil
            } else {
                self.decodedContent = nil
                self.errorMessage = "Unable to decode content. Unsupported format."
            }
        } else if !cleanBase64String.isEmpty {
            self.decodedContent = nil
            self.errorMessage = "Invalid base64 string"
        } else {
            self.decodedContent = nil
            self.errorMessage = nil
        }
    }
    
    func copyToClipboard() {
        #if os(iOS)
        UIPasteboard.general.string = base64String
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(base64String, forType: .string)
        #endif
        
        showCopiedMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation {
                self?.showCopiedMessage = false
            }
        }
    }
    
    func clear() {
        base64String = ""
        decodedContent = nil
        lastValidBase64 = ""
        errorMessage = nil
    }
}
