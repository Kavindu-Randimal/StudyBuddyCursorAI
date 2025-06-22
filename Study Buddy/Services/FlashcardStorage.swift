import Foundation

class FlashcardStorage {
    static let shared = FlashcardStorage()
    private let key = "savedTopics"

    func saveTopic(_ topic: SavedTopic) {
        var topics = fetchTopics()
        topics.append(topic)
        if let data = try? JSONEncoder().encode(topics) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func fetchTopics() -> [SavedTopic] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let topics = try? JSONDecoder().decode([SavedTopic].self, from: data) else {
            return []
        }
        return topics
    }

    func deleteTopic(_ topic: SavedTopic) {
        var topics = fetchTopics()
        topics.removeAll { $0.id == topic.id }
        if let data = try? JSONEncoder().encode(topics) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
} 