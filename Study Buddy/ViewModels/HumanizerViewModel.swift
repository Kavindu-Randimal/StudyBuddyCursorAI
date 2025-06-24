import Foundation
import SwiftUI

@MainActor
class HumanizerViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var humanizedText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let textService: TextServiceProtocol
    
    init(textService: TextServiceProtocol = GeminiService()) {
        self.textService = textService
    }
    
    func humanizeText() async {
        guard !userInput.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        humanizedText = ""
        
        do {
            let result = try await textService.humanizeText(from: userInput)
            humanizedText = result
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 