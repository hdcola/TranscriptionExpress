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
            return "Translate the above sentence to Chinese, and only return the content translated. no explanation."
        case .English:
            return "Translate the above sentence to English, and only return the content translated. no explanation."
        }
    }
}
