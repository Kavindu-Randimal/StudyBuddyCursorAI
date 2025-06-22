import Foundation

struct SavedTopic: Identifiable, Codable {
    let id: UUID
    let title: String
    let notes: String
    let flashcards: [Flashcard]
    let date: Date

    init(title: String, notes: String, flashcards: [Flashcard]) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.flashcards = flashcards
        self.date = Date()
    }
} 