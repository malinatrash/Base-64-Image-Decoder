import SwiftUI

struct ContentPreviewView: View {
    @ObservedObject var viewModel: ContentDecoderViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Preview")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                if let type = viewModel.decodedContent?.type {
                    Spacer()
                    Label(type.title, systemImage: type.icon)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
                
                if let content = viewModel.decodedContent {
                    content.preview
                } else if let error = viewModel.errorMessage {
                    errorStateView(error: error)
                } else {
                    emptyStateView
                }
            }
            .frame(height: 300)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("Decoded content will appear here")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private func errorStateView(error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            Text(error)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

#Preview {
    let viewModel = ContentDecoderViewModel()
    return ContentPreviewView(viewModel: viewModel)
}
