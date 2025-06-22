import Foundation

class GeminiService: FlashcardServiceProtocol {
    private let apiKey: String
    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    init() {
        self.apiKey = ConfigurationManager.shared.geminiAPIKey
    }
    
    func generateFlashcards(from notes: String) async throws -> [Flashcard] {
        let prompt = """
        Given the following notes or topics, generate 3 flashcards in JSON array format. Each flashcard should have a 'question' and an 'answer' field.

        Notes: \(notes)

        Return only the JSON array in this exact format:
        [
          {"question": "What is ...?", "answer": "..."},
          {"question": "Explain ...", "answer": "..."},
          {"question": "List ...", "answer": "..."}
        ]
        """
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 500
            ]
        ]
        
        guard let url = URL(string: "\(endpoint)?key=\(apiKey)"),
              let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw FlashcardError.invalidRequest
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
                case 400:
                    throw FlashcardError.invalidRequest
                case 404:
                    throw FlashcardError.modelNotFound
                case 429:
                    throw FlashcardError.rateLimited
                case 500...599:
                    throw FlashcardError.serverError
                default:
                    throw FlashcardError.networkError
                }
            }
            
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            
            guard let content = geminiResponse.candidates?.first?.content?.parts?.first?.text else {
                throw FlashcardError.parsingError
            }
            
            print("Gemini Response Content: \(content)")
            
            // Try to extract JSON from the response
            // ... inside your GeminiService, after getting 'content' from the response:
            var cleanedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)

            // Remove markdown code block markers if present
            if cleanedContent.hasPrefix("```json") {
                cleanedContent = cleanedContent.replacingOccurrences(of: "```json", with: "")
            }
            if cleanedContent.hasPrefix("```") {
                cleanedContent = cleanedContent.replacingOccurrences(of: "```", with: "")
            }
            if cleanedContent.hasSuffix("```") {
                cleanedContent = String(cleanedContent.dropLast(3))
            }
            cleanedContent = cleanedContent.trimmingCharacters(in: .whitespacesAndNewlines)

            if let jsonData = cleanedContent.data(using: .utf8),
               let flashcards = try? JSONDecoder().decode([Flashcard].self, from: jsonData) {
                return flashcards
            } else {
                // fallback
                return createFlashcardsFromText(cleanedContent)
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

// MARK: - Gemini API Response Models

struct GeminiResponse: Codable {
    let candidates: [Candidate]?
    
    struct Candidate: Codable {
        let content: Content?
        
        struct Content: Codable {
            let parts: [Part]?
            
            struct Part: Codable {
                let text: String?
            }
        }
    }
} 
