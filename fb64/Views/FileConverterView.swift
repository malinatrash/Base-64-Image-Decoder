import SwiftUI
import UniformTypeIdentifiers

// MARK: - Main View

struct FileConverterView: View {
    @StateObject private var viewModel = FileConverterViewModel()
    @State private var showDocumentPicker = false
    @State private var showFileExporter = false
    @State private var exportFile: URL?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    EncoderHeaderView()
                    
                    // Main Content
                    VStack(spacing: 20) {
                        // Input Section
                        EncoderInputView(
                            viewModel: viewModel,
                            showDocumentPicker: $showDocumentPicker
                        )
                        
                        // Action Buttons
                        EncoderActionButtons(
                            viewModel: viewModel,
                            onImportFile: { showDocumentPicker = true }
                        )
                    }
                    .padding(.vertical)
                    
                    // Recent Files
                    RecentFilesView(
                        viewModel: viewModel,
                        showFileExporter: $showFileExporter,
                        exportFile: $exportFile
                    )
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showDocumentPicker = true }) {
                            Label("Import File", systemImage: "square.and.arrow.down")
                        }
                        
                        if !viewModel.inputText.isEmpty {
                            Button(action: { viewModel.clear() }) {
                                Label("Clear", systemImage: "xmark.circle")
                            }
                            .tint(.red)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker { urls in
                    if let url = urls.first {
                        Task { await viewModel.encodeFile(url) }
                    }
                }
                .ignoresSafeArea()
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let file = viewModel.selectedFile {
                    ShareSheet(items: [file])
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("File has been successfully processed!")
            }
            .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage) { _ in
                Button("OK", role: .cancel) {}
            } message: { message in
                Text(message)
            }
            .fileExporter(
                isPresented: $showFileExporter,
                document: exportFile.flatMap { url in
                    try? FileDocumentWrapper(url: url)
                },
                contentType: .data,
                defaultFilename: exportFile?.lastPathComponent
            ) { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    viewModel.errorMessage = error.localizedDescription
                    viewModel.showError = true
                }
            }
        }
    }
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    var onPicked: ([URL]) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        picker.allowsMultipleSelection = false
        picker.shouldShowFileExtensions = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onPicked(urls)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    FileConverterView()
}
