//
//  TranscriptionExpressApp.swift
//  TranscriptionExpress
//
//  Created by Danny on 2024-03-18.
//

import SwiftUI
import KeyboardShortcuts

@main
struct TranscriptionExpressApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            #if os(macOS)
                .frame(minWidth: 1000, minHeight: 700)
            #endif
        }
    }
}

@MainActor
final class AppState:ObservableObject{
    init(){
        KeyboardShortcuts.onKeyUp(for: .toggleCopy) { [self] in
            NSApp.activate(ignoringOtherApps: true)
            print("Toggle Copy")
        }
    }
}
