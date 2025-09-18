import SwiftUI

struct EncoderInputView: View {
    @ObservedObject var viewModel: FileConverterViewModel
    @Binding var showDocumentPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("File to Encode")
                    .font(.headline)
                
                Spacer()
                
                if viewModel.isEncoding {
                    VStack(alignment: .trailing, spacing: 4) {
                        if viewModel.totalBytesToProcess > 0 {
                            Text("\(viewModel.bytesProcessed.formatted(.byteCount(style: .file))) / \(viewModel.totalBytesToProcess.formatted(.byteCount(style: .file)))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        ProgressView(value: viewModel.encodingProgress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 100)
                    }
                }
            }
            
            ZStack(alignment: .topLeading) {
                if viewModel.inputText.isEmpty {
                    Text("Select a file to encode to base64...")
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                
                // Always use the displayText which is optimized for performance
                ScrollView {
                    Text(viewModel.displayText)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(8)
                }
                .frame(height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            
            HStack {
                Spacer()
                
                if !viewModel.inputText.isEmpty {
                    HStack {
                        Text("\(viewModel.inputText.count.formatted()) characters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            // Copy in background to avoid UI freeze
                            Task {
                                let text = viewModel.inputText
                                UIPasteboard.general.string = text
                            }
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                                .disabled(viewModel.isEncoding)
                        }
                    }
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
