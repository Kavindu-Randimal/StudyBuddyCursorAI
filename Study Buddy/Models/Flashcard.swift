import SwiftUI
import Foundation

struct Flashcard: Identifiable, Codable {
    let id = UUID()
    let question: String
    let answer: String
}


#Preview {
    ContentView()
} 
