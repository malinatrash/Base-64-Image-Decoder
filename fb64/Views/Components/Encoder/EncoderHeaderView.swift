import SwiftUI

struct EncoderHeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
                .padding(.bottom, 4)
            
            Text("Base64 Encoder")
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
            
            Text("Convert files to base64 and back")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}

#Preview {
    EncoderHeaderView()
}
