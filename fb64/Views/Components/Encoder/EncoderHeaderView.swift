import SwiftUI

struct EncoderHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("File Encoder")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            Text("Convert files to base64 and back")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .compositingGroup()
        .shadow(radius: 2)
    }
}

#Preview {
    EncoderHeaderView()
}
