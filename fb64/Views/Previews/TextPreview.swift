import SwiftUI

struct TextPreview: View {
    let text: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                Text(text)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            
            if !isExpanded {
                Button("Show More") {
                    withAnimation {
                        isExpanded = true
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    TextPreview(text: "This is a sample text preview that can be expanded to show more content.")
        .frame(width: 300, height: 200)
}
