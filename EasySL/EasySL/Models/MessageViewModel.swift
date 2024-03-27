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
    var prompt: String = ""
    var response: String = ""
    var sendViewState: ViewState?
    
    private var ollama: OllamaKit?
    private var model: String = "llama2-chinese:13b"
    private var url: String = "http://localhost:11434"
    private var generation: AnyCancellable?
        
    @MainActor
    func send(prompt: String) async {
        if ollama == nil {
            let baseURL = URL(string: self.url)!
            self.ollama = OllamaKit(baseURL: baseURL)
        }
        if let ollama = self.ollama {
            self.sendViewState = .loading
            if await ollama.reachable() {
                let data = self.convertToOKGenerateRequestData(prompt: prompt)
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
    
    private func convertToOKGenerateRequestData(prompt: String?) -> OKGenerateRequestData {
        let data = OKGenerateRequestData(model: self.model, prompt: prompt ?? "")
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
