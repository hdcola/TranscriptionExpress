//
//  AppState.swift
//  EasySL
//
//  Created by Danny on 2024-03-27.
//

import SwiftUI
import KeyboardShortcuts

@Observable class AppState{
    var clipboardText: String?
    
    init(){
        KeyboardShortcuts.onKeyUp(for: .toggleCopy) { [self] in
            if let text = getTextFromClipboard(){
                clipboardText = text
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    private func getTextFromClipboard() -> String? {
        let pasteboard = NSPasteboard.general
        let pasteboardItems = pasteboard.pasteboardItems
        if let string =  pasteboardItems!.last!.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) {
            return string
        }
        return nil
    }
}



extension KeyboardShortcuts.Name{
    static let toggleCopy = Self("toggleCopy", default: .init(.e,modifiers: .command))
}
