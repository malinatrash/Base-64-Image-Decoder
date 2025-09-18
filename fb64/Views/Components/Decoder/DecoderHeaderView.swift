import SwiftUI

struct DecoderHeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
                .padding(.bottom, 4)
            
            Text("Base64 Decoder")
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
            
            Text("Decode base64 encoded content")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}

#Preview {
    DecoderHeaderView()
}
