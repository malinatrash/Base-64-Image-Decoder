import SwiftUI

struct EncoderInputView: View {
    @ObservedObject var viewModel: FileConverterViewModel
    @Binding var showDocumentPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Input")
                    .font(.headline)
                
                Spacer()
                
                if viewModel.isEncoding {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            
            ZStack(alignment: .topLeading) {
                if viewModel.inputText.isEmpty {
                    Text("Paste base64 string here or import a file...")
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                
                TextEditor(text: $viewModel.inputText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            
            HStack {
                Spacer()
                
                Button(action: { UIPasteboard.general.string = viewModel.inputText }) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .disabled(viewModel.inputText.isEmpty)
                
                Button(action: { viewModel.inputText = UIPasteboard.general.string ?? "" }) {
                    Label("Paste", systemImage: "doc.on.clipboard")
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    @StateObject var viewModel = FileConverterViewModel()
    @State var showDocumentPicker = false
    return EncoderInputView(viewModel: viewModel, showDocumentPicker: $showDocumentPicker)
}
