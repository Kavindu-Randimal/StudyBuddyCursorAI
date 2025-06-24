import Foundation
import SwiftUI

@MainActor
class GrammarCheckerViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var correctedText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let textService: TextServiceProtocol
    
    init(textService: TextServiceProtocol = GeminiService()) {
        self.textService = textService
    }
    
    func checkGrammar() async {
        guard !userInput.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        correctedText = ""
        
        do {
            let result = try await textService.checkGrammar(for: userInput)
            correctedText = result
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 