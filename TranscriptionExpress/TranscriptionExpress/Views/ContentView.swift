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
    @State private var colunmVisibility = NavigationSplitViewVisibility.doubleColumn
    
    @State var modelStorage: String = "huggingface/models/argmaxinc/whisperkit-coreml"
    
    @State private var modelState: ModelState = .unloaded
    @State private var localModels: [String] = []
    @State private var localModelPath: String = ""
    @State private var availableModels: [String] = []
    @State private var availableLanguages: [String] = []
    @State private var disabledModels: [String] = WhisperKit.recommendedModels().disabled

    
    @AppStorage("selectedModel") private var selectedModel: String = WhisperKit.recommendedModels().default
    @AppStorage("repoName") private var repoName: String = "argmaxinc/whisperkit-coreml"
    
    var body: some View {
        NavigationSplitView(columnVisibility: $colunmVisibility) {
            Spacer()
            Divider()
            ParametersSettingView
                .padding()
        } detail: {
            Text("Hello World")
        }
        .onAppear{
            fetchModels()
        }
    }
    
    
    var ParametersSettingView: some View{
        VStack{
            HStack{
                Picker("Model",selection: $selectedModel){
                    ForEach(availableModels, id: \.self) { model in
                        HStack{
                            let modelIcon = localModels.contains { $0 == model.description } ? "checkmark.circle" : "arrow.down.circle.dotted"
                            Text("\(Image(systemName: modelIcon)) \(model.description)").tag(model.description)
                        }
                    }
                }
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
