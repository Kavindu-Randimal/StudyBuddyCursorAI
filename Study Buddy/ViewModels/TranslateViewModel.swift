import Foundation
import SwiftUI

@MainActor
class TranslateViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var translatedText: String = ""
    @Published var targetLanguage: String = "English" // Default language
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Comprehensive list of languages including your requests
    let availableLanguages: [String] = [
        "English", "Sinhala", "Swedish", "Spanish", "French", "German", "Japanese", "Chinese (Simplified)", "Russian", "Arabic", "Hindi", "Portuguese", "Bengali", "Urdu", "Indonesian", "Dutch", "Italian", "Korean", "Turkish", "Vietnamese", "Polish", "Thai", "Farsi (Persian)", "Greek", "Hebrew", "Romanian", "Hungarian", "Czech", "Danish", "Finnish", "Norwegian", "Ukrainian", "Malay", "Swahili"
    ].sorted() // Sorted alphabetically for easier searching
    
    private let textService: TextServiceProtocol
    
    init(textService: TextServiceProtocol = GeminiService()) {
        self.textService = textService
    }
    
    func translateText() async {
        guard !userInput.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        translatedText = ""
        
        do {
            let result = try await textService.translateText(from: userInput, to: targetLanguage)
            translatedText = result
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 