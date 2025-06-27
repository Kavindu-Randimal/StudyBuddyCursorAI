import Foundation
import NaturalLanguage

@MainActor
class SummarizeViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var summary: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var wordCount: Int = 50
    @Published var detectedLanguageCode: String = "en"

    var detectedLanguageName: String {
        Locale.current.localizedString(forIdentifier: detectedLanguageCode) ?? "English"
    }

    var summaryWordCount: Int {
        summary
            .split { $0.isWhitespace || $0.isNewline }
            .filter { !$0.isEmpty }
            .count
    }

    private let textService: TextServiceProtocol

    init(textService: TextServiceProtocol = GeminiService()) {
        self.textService = textService
    }

    func summarizeText() async {
        guard !userInput.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        summary = ""

        if let lang = detectLanguage(for: userInput) {
            detectedLanguageCode = lang
        } else {
            detectedLanguageCode = "en"
        }

        do {
            let generatedSummary = try await textService.summarizeText(
                from: userInput,
                wordCount: self.wordCount,
                languageCode: detectedLanguageCode
            )
            summary = generatedSummary
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func detectLanguage(for text: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        if let language = recognizer.dominantLanguage {
            return language.rawValue
        }
        return nil
    }
}
