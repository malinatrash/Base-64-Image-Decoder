import SwiftUI

struct RecentFilesView: View {
    @ObservedObject var viewModel: FileConverterViewModel
    @Binding var showFileExporter: Bool
    @Binding var exportFile: URL?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !viewModel.recentFiles.isEmpty {
                Text("Recent Files")
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.recentFiles) { file in
                            RecentFileView(
                                file: file,
                                onSelect: {
                                    viewModel.inputText = file.data.base64EncodedString()
                                },
                                onExport: {
                                    do {
                                        let url = try FileService.shared.saveToDocuments(file)
                                        exportFile = url
                                        showFileExporter = true
                                    } catch {
                                        viewModel.errorMessage = error.localizedDescription
                                        viewModel.showError = true
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    @StateObject var viewModel = FileConverterViewModel()
    @State var showFileExporter = false
    @State var exportFile: URL? = nil
    return RecentFilesView(
        viewModel: viewModel,
        showFileExporter: $showFileExporter,
        exportFile: $exportFile
    )
}
