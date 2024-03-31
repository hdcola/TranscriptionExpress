//
//  MessageViewModel.swift
//  EasySL
//
//  Created by Danny on 2024-03-27.
//

import Combine
import KeyboardShortcuts
import OllamaKit
import SwiftUI
import ViewState

@Observable
class MessageViewModel {
    var source: String = ""
    var response: String = ""
    var sendViewState: ViewState?
    var targetLanguage: Language = .Chinese
    var sourceLanguage: Language = .English
    
    private var ollama: OllamaKit?
    private var model: String = "llama2-chinese:13b"
    private var url: String = "http://localhost:11434"
    private var generation: AnyCancellable?
    
    func switchContent(){
        let temp = targetLanguage
        targetLanguage = sourceLanguage
        sourceLanguage = temp
        let temp2 = source
        source = response
        response = temp2
    }
    
    @MainActor
    func translate() async {
        response = ""
        let system = targetLanguage.system
        let data = self.convertToOKGenerateRequestData(prompt: source,system: system)
        print(data.prompt)
        await self.send(data: data)
    }
        
    @MainActor
    func send(data: OKGenerateRequestData) async {
        if ollama == nil {
            let baseURL = URL(string: self.url)!
            self.ollama = OllamaKit(baseURL: baseURL)
        }
        if let ollama = self.ollama {
            self.sendViewState = .loading
            if await ollama.reachable() {
                self.generation = ollama.generate(data: data)
                    .sink(receiveCompletion: { [weak self] completion in
                        switch completion {
                        case .finished:
                            self?.handleComplete()
                        case .failure(let error):
                            self?.handleError(error.localizedDescription)
                        }
                    }, receiveValue: { [weak self] response in
                        self?.handleReceive(response)
                    })
            }
        }
    }
    
    private func convertToOKGenerateRequestData(prompt: String?, system: String? = nil) -> OKGenerateRequestData {
        var sendPrompt = prompt ?? ""
        if let system{
            sendPrompt = """
<s>[INST] <<SYS>>
\(system)
<</SYS>>

\(sendPrompt) [/INST]
"""
        }
        var data = OKGenerateRequestData(model: self.model, prompt: sendPrompt)
//        if let system{
//            data.system = system
//        }
//        data.context = self.context
        return data
    }
    
    private func handleReceive(_ response: OKGenerateResponse) {
        self.response += response.response
        self.sendViewState = .loading
    }
    
    private func handleComplete() {
        self.sendViewState = nil
    }
    
    private func handleError(_ errorMessage: String) {
        self.sendViewState = .error(message: errorMessage)
    }
}
