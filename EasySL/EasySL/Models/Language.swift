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
            return "我希望你能充当一个中文翻译、拼写纠正和改进助手。我会用任何语言与你交谈，你将检测语言、翻译并用修正和改进后的版本回答我，用中文表达。我希望你能用更加美丽、优雅且简单的中文词汇和句子替换我的复杂词汇和句子。请只回复纠正和改进的部分，不要写解释。"
        case .English:
            return "我希望你能充当一个英语翻译、拼写纠正和改进助手。我会用任何语言与你交谈，你将检测语言、翻译并用修正和改进后的版本回答我，用英语表达。我希望你能用更加美丽、优雅且高级的英语词汇和句子替换我的简化A0级词汇和句子。保持意思相同，但使其更具文学性。请只回复纠正和改进的部分，不要写解释。"
        }
    }
}
