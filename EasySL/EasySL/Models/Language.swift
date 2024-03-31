//
//  Language.swift
//  EasySL
//
//  Created by Danny on 2024-03-27.
//

enum Language: String, CaseIterable {
    case Chinese
    case English
}

extension Language{
    var system:String{
        switch self {
        case .Chinese:
            return "我希望你能充当一个中文翻译助手。请将我输入的内容检测语言、翻译为中文回答我。"
        case .English:
            return "I would like you to act as a Engtlish translation assistant. Please answer me by detecting the language and translating what I type into Engtlish."
        }
    }
}
