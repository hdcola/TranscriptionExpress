//
//  ContentView.swift
//  EasySL
//
//  Created by Danny on 2024-03-27.
//

import KeyboardShortcuts
import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Bindable var messageViewModel = MessageViewModel()

    var body: some View {
        VStack {
            // input prompt
            TextEditor(text: $messageViewModel.source)
            HStack{
                Picker("", selection: $messageViewModel.sourceLanguage) {
                    ForEach(Language.allCases, id: \.self) { language in
                        Text(language.rawValue).tag(language)
                    }
                }
                Button("Tranlaste") {
                    Task {
                        await messageViewModel.translate()
                    }
                }
                Button{
                    messageViewModel.switchContent()
                }label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                Picker("", selection: $messageViewModel.targetLanguage) {
                    ForEach(Language.allCases, id: \.self) { language in
                        Text(language.rawValue).tag(language)
                    }
                }
            }
            TextEditor(text: $messageViewModel.response)
            // select language
            
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
