import Foundation
import SwiftUI

@MainActor
class FlashcardViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var flashcards: [Flashcard] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var savedTopics: [SavedTopic] = []
    @Published var numberOfFlashcards: Int = 3
    
    private let textService: TextServiceProtocol
    private var lastRequestTime: Date?
    private let minimumRequestInterval: TimeInterval = 10 // 10 seconds between requests for Gemini
    
    init(textService: TextServiceProtocol = GeminiService()) {
        self.textService = textService
        loadSavedTopics()
    }
    
    var canGenerateFlashcards: Bool {
        guard !isLoading else { return false }
        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        
        // Check if enough time has passed since last request
        if let lastRequest = lastRequestTime {
            let timeSinceLastRequest = Date().timeIntervalSince(lastRequest)
            return timeSinceLastRequest >= minimumRequestInterval
        }
        
        return true
    }
    
    var timeUntilNextRequest: String {
        guard let lastRequest = lastRequestTime else { return "" }
        
        let timeSinceLastRequest = Date().timeIntervalSince(lastRequest)
        let remainingTime = max(0, minimumRequestInterval - timeSinceLastRequest)
        
        if remainingTime > 0 {
            return String(format: "%.0f seconds", remainingTime)
        }
        return ""
    }
    
    func generateFlashcards() async {
        guard canGenerateFlashcards else { return }
        
        isLoading = true
        errorMessage = nil
        flashcards = []
        lastRequestTime = Date()
        
        do {
            let generatedFlashcards = try await textService.generateFlashcards(from: userInput, count: numberOfFlashcards)
            flashcards = generatedFlashcards
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearFlashcards() {
        flashcards = []
        errorMessage = nil
    }
    
    func saveCurrentTopic(title: String) {
        let topic = SavedTopic(title: title, notes: userInput, flashcards: flashcards)
        FlashcardStorage.shared.saveTopic(topic)
        loadSavedTopics()
    }
    
    func loadSavedTopics() {
        savedTopics = FlashcardStorage.shared.fetchTopics()
    }
    
    func deleteTopic(_ topic: SavedTopic) {
        FlashcardStorage.shared.deleteTopic(topic)
        loadSavedTopics()
    }
} 
