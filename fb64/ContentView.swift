//
//  ContentView.swift
//  fb64
//
//  Created by Pavel Naumov on 18.09.2025.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct ContentView: View {
    @State private var base64String: String = ""
    @State private var image: Image?
    @State private var lastValidBase64: String = ""
    @State private var showCopiedMessage = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 40))
                            .foregroundColor(.accentColor)
                            .padding(.bottom, 4)
                        
                        Text("Base64 Image Decoder")
                            .font(.largeTitle.weight(.bold))
                            .multilineTextAlignment(.center)
                        
                        Text("Paste your base64 string to see the image")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
                    // Image display card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preview")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
                            
                            if let image = image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .padding(20)
                                    .frame(maxWidth: .infinity, maxHeight: 300)
                            } else {
                                VStack(spacing: 16) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondary)
                                    Text("No image to display")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, minHeight: 200)
                            }
                        }
                        .frame(height: 300)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Input card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Base64 String")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            if !base64String.isEmpty {
                                Button(action: copyToClipboard) {
                                    HStack(spacing: 4) {
                                        Image(systemName: showCopiedMessage ? "checkmark" : "doc.on.doc")
                                        Text(showCopiedMessage ? "Copied!" : "Copy")
                                            .font(.caption)
                                    }
                                    .foregroundColor(showCopiedMessage ? .green : .accentColor)
                                    .animation(.easeInOut, value: showCopiedMessage)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $base64String)
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
                                .onChange(of: base64String) { oldValue, newValue in
                                    decodeBase64()
                                }
                            
                            if base64String.isEmpty {
                                Text("Paste your base64 string here...")
                                    .foregroundColor(Color(.placeholderText))
                                    .padding(20)
                                    .allowsHitTesting(false)
                            }
                        }
                        
                        if !base64String.isEmpty {
                            HStack {
                                Spacer()
                                Button(role: .destructive) {
                                    base64String = ""
                                    image = nil
                                } label: {
                                    Text("Clear")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
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
    
    private func copyToClipboard() {
        #if os(iOS)
        UIPasteboard.general.string = base64String
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(base64String, forType: .string)
        #endif
        
        showCopiedMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedMessage = false
            }
        }
    }
    
    private func decodeBase64() {
        // Only process if the string has changed and is not empty
        guard !base64String.isEmpty, base64String != lastValidBase64 else { return }
        
        // Clean up the string (remove data:image/...;base64, if present)
        let cleanBase64String: String
        if let range = base64String.range(of: "base64,") {
            cleanBase64String = String(base64String[range.upperBound...])
        } else {
            cleanBase64String = base64String
        }
        
        // Try to decode the base64 string
        if let data = Data(base64Encoded: cleanBase64String),
           let uiImage = UIImage(data: data) {
            self.image = Image(uiImage: uiImage)
            self.lastValidBase64 = base64String
        } else if !cleanBase64String.isEmpty {
            // If we have content but it's not a valid image, clear the image
            self.image = nil
        } else {
            // If the string is empty, clear the image
            self.image = nil
        }
    }
}

#Preview {
    ContentView()
}

#if canImport(UIKit)
extension Image {
    init(uiImage: UIImage) {
        if let cgImage = uiImage.cgImage {
            self.init(cgImage, scale: 1.0, orientation: .up, label: Text(""))
        } else {
            // Fallback to the standard initializer if CGImage conversion fails
            self.init(uiImage: uiImage)
        }
    }
}
#elseif canImport(AppKit)
extension Image {
    init(nsImage: NSImage) {
        if let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            self.init(cgImage, scale: 1.0, label: Text(""))
        } else {
            // Fallback to the standard initializer if CGImage conversion fails
            self.init(nsImage: nsImage)
        }
    }
}
#endif
