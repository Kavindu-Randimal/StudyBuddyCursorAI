import SwiftUI

// The struct name should be FlashcardsView
struct FlashcardsView: View {
    @StateObject private var viewModel = FlashcardViewModel()
    @State private var showSaveAlert = false
    @State private var topicTitle = ""
    @State private var selectedTopic: SavedTopic?
    @State private var showCustomKeyboard = false
    @State private var showScanner = false
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea() // A subtle background color
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Flashcards")
                        .font(.largeTitle.bold())
                        .padding(.horizontal)

                    // MARK: - Input Section
                    PremiumCardView(hasBorder: false) {
                        VStack(alignment: .leading) {
                            HStack {
                                Button(action: { showScanner = true }) {
                                    Label("Scan Document", systemImage: "doc.text.viewfinder")
                                        .font(.headline)
                                }
                                .buttonStyle(GradientButtonStyle())
                                .sheet(isPresented: $showScanner) {
                                    DocumentScannerView { scannedText in
                                        viewModel.userInput = scannedText
                                    }
                                }
                                Spacer()
                            }
                            Text("Enter your notes or topics:")
                                .font(.headline)
                            ZStack(alignment: .topTrailing) {
                                TextEditor(text: $viewModel.userInput)
                                    .frame(height: 100)
                                    .gradientBorder()
                                if !viewModel.userInput.isEmpty {
                                    Button(action: { viewModel.userInput = "" }) {
                                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                                    }
                                    .padding(8)
                                }
                            }
                        }
                    }

                    // MARK: - Action Button
                    Button(action: {
                        hideKeyboard()
                        Task { await viewModel.generateFlashcards() }
                    }) {
                        Text("Generate Flashcards")
                    }
                    .buttonStyle(GradientButtonStyle())
                    .disabled(viewModel.userInput.isEmpty)
                    .frame(maxWidth: .infinity)


                    // MARK: - Generated Flashcards
                    if !viewModel.flashcards.isEmpty {
                        Text("Generated Flashcards:")
                            .font(.title2.bold())
                            .padding(.horizontal)

                        ForEach(viewModel.flashcards) { flashcard in
                            PremiumCardView {
                                FlashcardView(flashcard: flashcard)
                            }
                        }

                        Button("Save This Topic") { showSaveAlert = true }
                            .buttonStyle(GradientButtonStyle())
                            .frame(maxWidth: .infinity)
                    }

                    // MARK: - Saved Topics
                    Divider().padding(.vertical)
                    Text("Saved Topics")
                        .font(.title2.bold())
                        .padding(.horizontal)

                    if viewModel.savedTopics.isEmpty {
                        EmptyStateView(systemImageName: "tray.fill", message: "No saved topics yet!")
                    } else {
                        ForEach(viewModel.savedTopics) { topic in
                            PremiumCardView(verticalPadding: 2) {
                                VStack(alignment: .leading) {
                                    Text(topic.title).bold()
                                    Text(topic.date, style: .date).font(.caption).foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .onTapGesture { selectedTopic = topic }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .onTapGesture { hideKeyboard() }
        .sheet(item: $selectedTopic) { topic in TopicDetailView(topic: topic) }
        .alert("Save Topic", isPresented: $showSaveAlert, actions: {
            TextField("Topic Title", text: $topicTitle)
            Button("Save") { viewModel.saveCurrentTopic(title: topicTitle); topicTitle = "" }
            Button("Cancel", role: .cancel) { topicTitle = "" }
        })
        .onAppear { viewModel.loadSavedTopics() }
    }
}

// You can keep the helper views here
struct FlashcardView: View {
    let flashcard: Flashcard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Q: \(flashcard.question)")
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
            
            Text("A: \(flashcard.answer)")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

struct TopicDetailView: View {
    let topic: SavedTopic
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(topic.title)
                .font(.largeTitle)
                .bold()
            Text("Notes: \(topic.notes)")
                .font(.body)
            Text("Flashcards:")
                .font(.headline)
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(topic.flashcards) { flashcard in
                        FlashcardView(flashcard: flashcard)
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

// Helper to dismiss keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
