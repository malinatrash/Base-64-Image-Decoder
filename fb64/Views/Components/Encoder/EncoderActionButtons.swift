import SwiftUI

struct EncoderActionButtons: View {
    @ObservedObject var viewModel: FileConverterViewModel
    var onImportFile: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onImportFile) {
                Label("Encode File", systemImage: "arrow.up.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isEncoding || viewModel.isDecoding)
            
            Button(action: { Task { await viewModel.decodeFile() } }) {
                if viewModel.isDecoding {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity)
                } else {
                    Label("Decode", systemImage: "arrow.down.doc")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.inputText.isEmpty || viewModel.isDecoding || viewModel.isEncoding)
        }
        .padding(.horizontal)
    }
}

#Preview {
    @StateObject var viewModel = FileConverterViewModel()
    return EncoderActionButtons(viewModel: viewModel, onImportFile: {})
}
