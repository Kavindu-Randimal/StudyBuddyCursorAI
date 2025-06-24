import Foundation
import SwiftUI

@MainActor
class SummarizeViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var summary: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var wordCount: Int = 50 // Default word count
    
    private let textService: TextServiceProtocol
    
    init(textService: TextServiceProtocol = GeminiService()) {
        self.textService = textService
    }
    
    func summarizeText() async {
        guard !userInput.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        summary = ""
        
        do {
            let generatedSummary = try await textService.summarizeText(from: userInput, wordCount: self.wordCount)
            summary = generatedSummary
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 