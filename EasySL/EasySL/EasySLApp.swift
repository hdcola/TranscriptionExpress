//
//  EasySLApp.swift
//  EasySL
//
//  Created by Danny on 2024-03-27.
//

import SwiftUI

@main
struct EasySLApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 500)
                .environment(appState)
        }
    }
}
