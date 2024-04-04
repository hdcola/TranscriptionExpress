//
//  KeyboardShortcutsModifier.swift
//  EasySL
//
//  Created by Danny on 2024-04-04.
//

import KeyboardShortcuts
import SwiftUI

struct KeyboardShortcutsModifier: ViewModifier {
    let name: KeyboardShortcuts.Name
    let action: (String) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear {
                KeyboardShortcuts.onKeyUp(for: name) { [self] in
                    if let clipboardText = getTextFromClipboard() {
                        NSApp.activate(ignoringOtherApps: true)
                        action(clipboardText)
                    }
                }
            }
    }
    
    private func getTextFromClipboard() -> String? {
        let pasteboard = NSPasteboard.general
        let pasteboardItems = pasteboard.pasteboardItems
        if let string = pasteboardItems!.last!.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) {
            return string
        }
        return nil
    }
}

extension View {
    func keyboardShortcuts(name: KeyboardShortcuts.Name, action: @escaping (String) -> Void) -> some View {
        self.modifier(KeyboardShortcutsModifier(name: name, action: action))
    }
}

extension KeyboardShortcuts.Name {
    static let toggleCopy = Self("toggleCopy", default: .init(.e, modifiers: .command))
}
