import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FlashcardsView()
                .tabItem {
                    Label("Flashcards", systemImage: "rectangle.stack")
                }
            
            SummarizeView()
                .tabItem {
                    Label("Summarize", systemImage: "doc.text.magnifyingglass")
                }
            
            HumanizerView()
                .tabItem {
                    Label("Humanizer", systemImage: "person.wave.2")
                }
            
            TranslateView()
                .tabItem {
                    Label("Translate", systemImage: "globe")
                }
            
            // Add the new Grammar Checker tab
            GrammarCheckerView()
                .tabItem {
                    Label("Grammar", systemImage: "text.badge.checkmark")
                }
        }
    }
}

#Preview {
    ContentView()
}


