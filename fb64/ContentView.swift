//
//  ContentView.swift
//  fb64
//
//  Created by Pavel Naumov on 18.09.2025.
//

import SwiftUI

@main
struct Base64DecoderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentDecoderView()
                .tabItem {
                    Label("Decode", systemImage: "arrow.down.doc")
                }
                .tag(0)
            
            FileConverterView()
                .tabItem {
                    Label("Encode", systemImage: "arrow.up.doc")
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
}
