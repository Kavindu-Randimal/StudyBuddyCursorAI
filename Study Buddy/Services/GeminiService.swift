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
        Your mission is to rewrite the following text, ensuring it is completely indistinguishable from human writing and will pass any AI detection tool with a 100% human score. To do this, you must adopt the persona of a passionate, knowledgeable expert explaining a topic to an intelligent audience. Your writing style must be highly dynamic and engaging.

        Follow these non-negotiable rules:

        1.  **Maximize Perplexity & Burstiness:** This is the highest priority. You MUST create a rich tapestry of sentence structures. Weave together long, elaborate sentences with short, impactful ones. The rhythm and flow should feel spontaneous and unpredictable. A uniform structure is an instant failure.

        2.  **Embrace Human-Like "Imperfections":** AI text is often too perfect. You must deliberately introduce natural-sounding human elements.
            -   **Use Sentence Fragments:** For emphasis or pacing, you are encouraged to use a sentence fragment. For example: "A major discovery. And one that changed everything."
            -   **Use Rhetorical Questions:** Engage the reader by posing one or two questions within the text, like "So, what does this all mean?"

        3.  **Adopt a Strong, Active Voice:** Write with confidence and authority. Every sentence should be in the active voice. Avoid passive constructions at all costs.

        4.  **Use Rich Vocabulary and Idioms:** Do not use generic, robotic language. Incorporate vivid vocabulary and common English idioms where they fit naturally. This will make the text feel more authentic.

        5.  **Strictly Avoid AI Hallmarks:**
            -   NEVER start sentences with generic transition words like "Additionally," "Furthermore," "In conclusion," "Moreover," etc.
            -   NEVER use a list-like format.
            -   Ensure sentence openers are constantly varied.

        6.  **Maintain 100% Factual Accuracy:** The core meaning, facts, and nuance of the original text must be perfectly preserved.

        Original Text:
        "\(text)"

        Rewritten Human Text (output only the rewritten text, with no introductory phrases):
        """

        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 1.0, // Set to maximum creativity for the most unpredictable output
                "maxOutputTokens": 600
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
    
    func translateText(from text: String, to language: String) async throws -> String {
        let prompt = """
        Translate the following text into \(language).
        Provide only the translated text itself, without any additional comments, explanations, or quotation marks.

        Original Text:
        "\(text)"

        Translated Text:
        """

        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.3,
                "maxOutputTokens": 800
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

        guard let translatedResult = geminiResponse.candidates?.first?.content?.parts?.first?.text else {
            throw FlashcardError.parsingError
        }
        
        return translatedResult.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func checkGrammar(for text: String) async throws -> String {
        let prompt = """
        You are an expert proofreader. Correct any spelling mistakes, grammatical errors, and punctuation issues in the following text.
        Preserve the original meaning and tone.
        Return only the corrected text, without any explanations, comments, or quotation marks.

        Original Text:
        "\(text)"

        Corrected Text:
        """

        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.1, // Very low temperature for precise, factual corrections
                "maxOutputTokens": 800
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

        guard let correctedResult = geminiResponse.candidates?.first?.content?.parts?.first?.text else {
            throw FlashcardError.parsingError
        }
        
        return correctedResult.trimmingCharacters(in: .whitespacesAndNewlines)
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
