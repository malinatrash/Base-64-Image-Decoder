import SwiftUI

struct EncoderActionButtons: View {
    @ObservedObject var viewModel: FileConverterViewModel
    var onImportFile: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onImportFile) {
                Label(viewModel.inputText.isEmpty ? "Select File" : "Change File", systemImage: "doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isEncoding)
            
            Button(action: { 
                Task { await viewModel.encodeFile() }
            }) {
                if viewModel.isEncoding {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity)
                } else {
                    Label("Encode to Base64", systemImage: "arrow.right.doc.on.clipboard")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.inputText.isEmpty || viewModel.isEncoding)
        }
        .padding(.horizontal)
    }
}

#Preview {
    @StateObject var viewModel = FileConverterViewModel()
    return EncoderActionButtons(viewModel: viewModel, onImportFile: {})
}
