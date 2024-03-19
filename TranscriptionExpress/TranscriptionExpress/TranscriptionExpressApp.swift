//
//  TranscriptionExpressApp.swift
//  TranscriptionExpress
//
//  Created by Danny on 2024-03-18.
//

import SwiftUI

@main
struct TranscriptionExpressApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            #if os(macOS)
                .frame(minWidth: 1000,minHeight: 700)
            #endif
        }
    }
}
