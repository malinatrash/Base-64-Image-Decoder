import SwiftUI

struct ImagePreview: View {
    let data: Data
    @State private var image: Image?
    
    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                ProgressView()
                    .onAppear {
                        loadImage()
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadImage() {
        #if canImport(UIKit)
        if let uiImage = UIImage(data: data) {
            self.image = Image(uiImage: uiImage)
        }
        #elseif canImport(AppKit)
        if let nsImage = NSImage(data: data) {
            self.image = Image(nsImage: nsImage)
        }
        #endif
    }
}

#Preview {
    if let sampleImage = UIImage(systemName: "photo"),
       let data = sampleImage.pngData() {
        ImagePreview(data: data)
            .frame(width: 200, height: 200)
    } else {
        Text("Preview not available")
    }
}
