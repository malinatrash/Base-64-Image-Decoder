import SwiftUI

struct ContentDecoderView: View {
    @StateObject private var viewModel = ContentDecoderViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    DecoderHeaderView()
                    
                    // Content preview
                    ContentPreviewView(viewModel: viewModel)
                    
                    // Input section
                    Base64InputView(viewModel: viewModel)
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("")
                }
            }
        }
    }
}

#Preview {
    ContentDecoderView()
}
