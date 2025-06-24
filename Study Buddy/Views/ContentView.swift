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
        }
    }
}

#Preview {
    ContentView()
}


