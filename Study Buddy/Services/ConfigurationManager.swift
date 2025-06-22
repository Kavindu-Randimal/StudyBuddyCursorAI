import Foundation

class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    private var config: [String: Any]?
    
    private init() {
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        // First try environment variable (for development)
        if let envAPIKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] {
            config = ["GeminiAPIKey": envAPIKey]
            return
        }
        
        // Fall back to plist file
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("Error: Could not load Config.plist")
            return
        }
        self.config = config
    }
    
    var geminiAPIKey: String {
        guard let apiKey = config?["GeminiAPIKey"] as? String, !apiKey.isEmpty else {
            fatalError("Gemini API key not found in Config.plist or environment variables")
        }
        return apiKey
    }
} 