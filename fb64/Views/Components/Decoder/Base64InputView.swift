import SwiftUI

struct Base64InputView: View {
    @ObservedObject var viewModel: ContentDecoderViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView
            inputField
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Base64 Input")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if !viewModel.base64String.isEmpty {
                copyButton
                clearButton
            }
        }
    }
    
    private var inputField: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $viewModel.base64String)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 120, maxHeight: 200)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            if viewModel.base64String.isEmpty {
                Text("Paste your base64 string here...")
                    .foregroundColor(Color(.placeholderText))
                    .padding(20)
                    .allowsHitTesting(false)
            }
        }
    }
    
    private var copyButton: some View {
        Button(action: viewModel.copyToClipboard) {
            HStack(spacing: 4) {
                Image(systemName: viewModel.showCopiedMessage ? "checkmark" : "doc.on.doc")
                Text(viewModel.showCopiedMessage ? "Copied!" : "Copy")
                    .font(.caption)
            }
            .foregroundColor(viewModel.showCopiedMessage ? .green : .accentColor)
            .animation(.easeInOut, value: viewModel.showCopiedMessage)
        }
        .buttonStyle(.plain)
    }
    
    private var clearButton: some View {
        Button(role: .destructive) {
            withAnimation {
                viewModel.clear()
            }
        } label: {
            Image(systemName: "xmark.circle")
                .foregroundColor(.red)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let viewModel = ContentDecoderViewModel()
    return Base64InputView(viewModel: viewModel)
}
