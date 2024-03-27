//
//  ContentView.swift
//  EasySL
//
//  Created by Danny on 2024-03-27.
//

import SwiftUI
import KeyboardShortcuts

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack {
            KeyboardShortcuts.Recorder("Toggle Copy", name: .toggleCopy)
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(appState.clipboardText ?? "")
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .frame(minWidth: 400, minHeight: 500)
        .environment(AppState())
}
