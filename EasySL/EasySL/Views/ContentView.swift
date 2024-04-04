//
//  ContentView.swift
//  EasySL
//
//  Created by Danny on 2024-03-27.
//

import KeyboardShortcuts
import SwiftUI

struct ContentView: View {
    @Bindable var messageViewModel = MessageViewModel()

    var body: some View {
        VStack {
            // input prompt
            TextEditor(text: $messageViewModel.source)
            HStack {
                Picker("", selection: $messageViewModel.sourceLanguage) {
                    ForEach(Language.allCases, id: \.self) { language in
                        Text(language.rawValue).tag(language)
                    }
                }
                Button {
                    Task {
                        await messageViewModel.translate()
                    }
                } label: {
                    HStack {
                        Image(systemName: messageViewModel.sendViewState == .loading ? "slowmo" : "bubble.left.and.text.bubble.right")
                            .symbolEffect(.variableColor, isActive: messageViewModel.sendViewState == .loading)
                        Text("Translate")
                    }
                }
                Button {
                    messageViewModel.switchContent()
                } label: {
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

            HStack {
                KeyboardShortcuts.Recorder("Toggle Copy", name: .toggleCopy)
            }
        }
        .padding()
        .keyboardShortcuts(name: .toggleCopy) { text in
            Task {
                messageViewModel.source = text
                await messageViewModel.translate()
            }
        }
    }
}

#Preview {
    ContentView()
        .frame(minWidth: 400, minHeight: 500)
}
