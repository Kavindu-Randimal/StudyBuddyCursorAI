import Foundation

protocol FlashcardServiceProtocol {
    func generateFlashcards(from notes: String) async throws -> [Flashcard]
}

class OpenAIService: FlashcardServiceProtocol {
    private let apiKey: String
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    init() {
        self.apiKey = ConfigurationManager.shared.geminiAPIKey
    }
    
    func generateFlashcards(from notes: String) async throws -> [Flashcard] {
        let prompt = """
        Given the following notes or topics, generate 3 flashcards in JSON array format. Each flashcard should have a 'question' and an 'answer' field.

        Notes: \(notes)

        Example output:
        [
          {"question": "What is ...?", "answer": "..."},
          {"question": "Explain ...", "answer": "..."},
          {"question": "List ...", "answer": "..."}
        ]
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that creates study flashcards."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 500,
            "temperature": 0.7
        ]
        
        guard let url = URL(string: endpoint),
              let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw FlashcardError.invalidRequest
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FlashcardError.networkError
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error Response: \(errorString)")
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw FlashcardError.unauthorized
                case 429:
                    throw FlashcardError.rateLimited
                case 500...599:
                    throw FlashcardError.serverError
                default:
                    throw FlashcardError.networkError
                }
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            guard let content = openAIResponse.choices.first?.message.content else {
                throw FlashcardError.parsingError
            }
            
            print("OpenAI Response Content: \(content)")
            
            // Try to extract JSON from the response
            if let jsonData = content.data(using: .utf8),
               let flashcards = try? JSONDecoder().decode([Flashcard].self, from: jsonData) {
                return flashcards
            } else {
                // If JSON parsing fails, create flashcards from the text response
                return createFlashcardsFromText(content)
            }
            
        } catch {
            print("Network Error: \(error)")
            throw error
        }
    }
    
    private func createFlashcardsFromText(_ text: String) -> [Flashcard] {
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        var flashcards: [Flashcard] = []
        
        for (index, line) in lines.prefix(3).enumerated() {
            let question = "Question \(index + 1): What is the key point about this topic?"
            let answer = line.trimmingCharacters(in: .whitespacesAndNewlines)
            flashcards.append(Flashcard(question: question, answer: answer))
        }
        
        return flashcards.isEmpty ? [
            Flashcard(question: "What did you learn?", answer: text)
        ] : flashcards
    }
} 
