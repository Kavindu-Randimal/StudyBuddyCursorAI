import Foundation

protocol TextServiceProtocol {
    func generateFlashcards(from notes: String, count: Int) async throws -> [Flashcard]
    func summarizeText(from text: String, wordCount: Int) async throws -> String
    func humanizeText(from text: String) async throws -> String
    func translateText(from text: String, to language: String) async throws -> String
} 