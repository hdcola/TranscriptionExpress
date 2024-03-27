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
    @Bindable var messageViewModel = MessageViewModel()
    
    var body: some View {
        VStack {
            // input prompt
            TextEditor(text: $messageViewModel.prompt)
            
            TextEditor(text: $messageViewModel.response)
            
            Button("Send"){
                Task {
                    await messageViewModel.send(prompt: messageViewModel.prompt)
                }
            }

            KeyboardShortcuts.Recorder("Toggle Copy", name: .toggleCopy)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .frame(minWidth: 400, minHeight: 500)
        .environment(AppState())
}
