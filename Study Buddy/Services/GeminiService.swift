import Foundation

class GeminiService: TextServiceProtocol {
    private let apiKey: String
    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    init() {
        self.apiKey = ConfigurationManager.shared.geminiAPIKey
    }
    
    func generateFlashcards(from notes: String, count: Int) async throws -> [Flashcard] {
        let prompt = """
        Given the following notes or topics, generate \(count) flashcards in JSON array format. Each flashcard should have a 'question' and an 'answer' field.

        Notes: \(notes)

        Return ONLY the JSON array, with no explanation, no markdown, and no code block. Example:
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
            
            var cleanedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanedContent.hasPrefix("```json") { cleanedContent = String(cleanedContent.dropFirst(7)) }
            if cleanedContent.hasSuffix("```") { cleanedContent = String(cleanedContent.dropLast(3)) }
            cleanedContent = cleanedContent.trimmingCharacters(in: .whitespacesAndNewlines)

            if let jsonData = cleanedContent.data(using: .utf8),
               let flashcards = try? JSONDecoder().decode([Flashcard].self, from: jsonData) {
                return flashcards
            } else {
                // fallback
                return []
            }
            
        } catch {
            print("Network Error: \(error)")
            throw error
        }
    }
    
    func summarizeText(from text: String, wordCount: Int) async throws -> String {
        let prompt = """
        Summarize the following text in approximately \(wordCount) words. Provide the summary as a single block of text, without any introductory phrases like "Here is the summary:".

        Text:
        "\(text)"

        Summary:
        """

        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.5,
                "maxOutputTokens": 250 // Max tokens for the output
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

        let (data, _) = try await URLSession.shared.data(for: request)
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard let summary = geminiResponse.candidates?.first?.content?.parts?.first?.text else {
            throw FlashcardError.parsingError
        }
        
        return summary.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func humanizeText(from text: String) async throws -> String {
        let prompt = """
        Rewrite the following text to make it sound more natural, conversational, and human-like.
        Avoid overly formal language and complex sentence structures, but ensure the core meaning remains exactly the same.

        Original Text:
        "\(text)"

        Humanized Text:
        """

        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.8,
                "maxOutputTokens": 400
            ]
        ]

        let apiKey = ConfigurationManager.shared.geminiAPIKey
        let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
        
        guard let url = URL(string: "\(endpoint)?key=\(apiKey)"),
              let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw FlashcardError.invalidRequest
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        let (data, _) = try await URLSession.shared.data(for: request)
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard let humanizedResult = geminiResponse.candidates?.first?.content?.parts?.first?.text else {
            throw FlashcardError.parsingError
        }
        
        return humanizedResult.trimmingCharacters(in: .whitespacesAndNewlines)
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
