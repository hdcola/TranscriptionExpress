//
//  ContentView.swift
//  TranscriptionExpress
//
//  Created by Danny on 2024-03-18.
//

import SwiftUI
import WhisperKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import AVFoundation

struct ContentView: View {
    @State var whisperKit: WhisperKit? = nil
    
    @State private var colunmVisibility = NavigationSplitViewVisibility.doubleColumn
    
    @State var modelStorage: String = "huggingface/models/argmaxinc/whisperkit-coreml"
    
    @State private var modelState: ModelState = .unloaded
    @State private var localModels: [String] = []
    @State private var localModelPath: String = ""
    @State private var availableModels: [String] = []
    @State private var availableLanguages: [String] = []
    @State private var disabledModels: [String] = WhisperKit.recommendedModels().disabled
    
    @State private var loadingProgressValue: Float = 0.0
    @State private var specializationProgressRatio: Float = 0.7
    
    
    @AppStorage("selectedModel") private var selectedModel: String = WhisperKit.recommendedModels().default
    @AppStorage("repoName") private var repoName: String = "argmaxinc/whisperkit-coreml"
    
    var body: some View {
        NavigationSplitView(columnVisibility: $colunmVisibility) {
            List{
                
            }
            .disabled(modelState != .loaded)
            Divider()
            ParametersSettingView
                .padding()
                .foregroundColor(modelState != .loaded ? .secondary : .primary)
                .navigationTitle("Transcription Express")
                .navigationSplitViewColumnWidth(min: 200, ideal: 200)
        } detail: {
            Text("\(availableModels)")
        }
        .onAppear{
            fetchModels()
        }
    }
    
    
    var ParametersSettingView: some View{
        VStack{
            Picker("Input Language",selection: $availableLanguages){
                ForEach(availableModels,id:\.self){ language in
                    Text(language.description).tag(language.description)
                }
            }
            Picker("Model",selection: $selectedModel){
                ForEach(localModels, id: \.self) { model in
                    HStack{
                        Text("\(model.description)").tag(model.description)
                    }
                }
            }
            Button{
                
            }label: {
                Label("Manage Model", image: "gear")
            }
        }
    }
    
    func loadModel(_ model: String, redownload: Bool = false) {
        print("Selected Model: \(UserDefaults.standard.string(forKey: "selectedModel") ?? "nil")")
        
        whisperKit = nil
        Task {
            whisperKit = try await WhisperKit(
                verbose: true,
                logLevel: .debug,
                prewarm: false,
                load: false,
                download: false
            )
            guard let whisperKit = whisperKit else {
                return
            }
            
            var folder: URL?
            
            // Check if the model is available locally
            if localModels.contains(model) && !redownload {
                // Get local model folder URL from localModels
                // TODO: Make this configurable in the UI
                folder = URL(fileURLWithPath: localModelPath).appendingPathComponent("openai_whisper-\(model)")
            } else {
                // Download the model
                folder = try await WhisperKit.download(variant: model, from: repoName, progressCallback: { progress in
                    DispatchQueue.main.async {
                        loadingProgressValue = Float(progress.fractionCompleted) * specializationProgressRatio
                        modelState = .downloading
                    }
                })
            }
            
            await MainActor.run {
                loadingProgressValue = specializationProgressRatio
                modelState = .downloaded
            }
            
            
            if let modelFolder = folder {
                whisperKit.modelFolder = modelFolder
                
                await MainActor.run {
                    // Set the loading progress to 90% of the way after prewarm
                    loadingProgressValue = specializationProgressRatio
                    modelState = .prewarming
                }
                
                let progressBarTask = Task {
                    await updateProgressBar(targetProgress: 0.9, maxTime: 240)
                }
                
                // Prewarm models
                do {
                    try await whisperKit.prewarmModels()
                    progressBarTask.cancel()
                } catch {
                    print("Error prewarming models, retrying: \(error.localizedDescription)")
                    progressBarTask.cancel()
                    if !redownload {
                        loadModel(model, redownload: true)
                        return
                    } else {
                        // Redownloading failed, error out
                        modelState = .unloaded
                        return
                    }
                }
                
                await MainActor.run {
                    // Set the loading progress to 90% of the way after prewarm
                    loadingProgressValue = specializationProgressRatio + 0.9 * (1 - specializationProgressRatio)
                    modelState = .loading
                }
                
                try await whisperKit.loadModels()
                
                await MainActor.run {
                    if !localModels.contains(model) {
                        localModels.append(model)
                    }
                    
                    availableLanguages = whisperKit.tokenizer?.languages.map { $0.key }.sorted() ?? ["english"]
                    loadingProgressValue = 1.0
                    modelState = whisperKit.modelState
                }
            }
        }
    }
    
    func updateProgressBar(targetProgress: Float, maxTime: TimeInterval) async {
        let initialProgress = loadingProgressValue
        let decayConstant = -log(1 - targetProgress) / Float(maxTime)
        
        let startTime = Date()
        
        while true {
            let elapsedTime = Date().timeIntervalSince(startTime)
            
            // Break down the calculation
            let decayFactor = exp(-decayConstant * Float(elapsedTime))
            let progressIncrement = (1 - initialProgress) * (1 - decayFactor)
            let currentProgress = initialProgress + progressIncrement
            
            await MainActor.run {
                loadingProgressValue = currentProgress
            }
            
            if currentProgress >= targetProgress {
                break
            }
            
            do {
                try await Task.sleep(nanoseconds: 100_000_000)
            } catch {
                break
            }
        }
    }
    
    func fetchModels() {
        availableModels = [selectedModel]
        
        // First check what's already downloaded
        if let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let modelPath = documents.appendingPathComponent(modelStorage).path
            
            // Check if the directory exists
            if FileManager.default.fileExists(atPath: modelPath) {
                localModelPath = modelPath
                do {
                    let downloadedModels = try FileManager.default.contentsOfDirectory(atPath: modelPath)
                    for model in downloadedModels where !localModels.contains(model) && model.starts(with: "openai") {
                        localModels.append(model)
                    }
                } catch {
                    print("Error enumerating files at \(modelPath): \(error.localizedDescription)")
                }
            }
        }
        
        localModels = WhisperKit.formatModelFiles(localModels)
        for model in localModels {
            if !availableModels.contains(model),
               !disabledModels.contains(model)
            {
                availableModels.append(model)
            }
        }
        
        print("Found locally: \(localModels)")
        print("Previously selected model: \(selectedModel)")
        
        Task {
            let remoteModels = try await WhisperKit.fetchAvailableModels(from: repoName)
            for model in remoteModels {
                if !availableModels.contains(model),
                   !disabledModels.contains(model)
                {
                    availableModels.append(model)
                }
            }
        }
    }
}

#Preview {
    ContentView()
#if os(macOS)
        .frame(width: 600, height: 500)
#endif
}
