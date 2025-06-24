import SwiftUI

// The struct name should be FlashcardsView
struct FlashcardsView: View {
    @StateObject private var viewModel = FlashcardViewModel()
    @State private var showSaveAlert = false
    @State private var topicTitle = ""
    @State private var selectedTopic: SavedTopic?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Study Buddy")
                .font(.largeTitle)
                .bold()
                .padding(.top, 16)
                .padding(.bottom, 8)

            Text("Enter your notes or topics:")
                .font(.headline)

            TextEditor(text: $viewModel.userInput)
                .frame(height: 100)
                .border(Color.gray, width: 1)
                .cornerRadius(8)
                .padding(.bottom)

            Button(action: {
                hideKeyboard()
                Task { await viewModel.generateFlashcards() }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Generate Flashcards")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canGenerateFlashcards)

            if !viewModel.canGenerateFlashcards && !viewModel.isLoading && !viewModel.userInput.isEmpty {
                Text("Please wait \(viewModel.timeUntilNextRequest) before next request")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            if !viewModel.flashcards.isEmpty {
                Text("Generated Flashcards:")
                    .font(.title2)
                    .fontWeight(.bold)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.flashcards) { flashcard in
                            FlashcardView(flashcard: flashcard)
                        }
                    }
                    .padding(.vertical)
                }
                .frame(minHeight: 200, maxHeight: 350)

                Button("Save This Topic") {
                    showSaveAlert = true
                }
                .buttonStyle(.bordered)
                .padding(.vertical, 4)
            }

            /*HStack {
                Text("Number of Flashcards: \(viewModel.numberOfFlashcards)")
                Stepper("", value: $viewModel.numberOfFlashcards, in: 1...10)
            }*/

            Divider().padding(.vertical)
            Text("Saved Topics")
                .font(.headline)
            List {
                ForEach(viewModel.savedTopics) { topic in
                    Button(action: {
                        selectedTopic = topic
                    }) {
                        VStack(alignment: .leading) {
                            Text(topic.title)
                                .fontWeight(.bold)
                            Text(topic.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { i in
                        viewModel.deleteTopic(viewModel.savedTopics[i])
                    }
                }
            }
            .frame(height: 200)
        }
        .padding()
        .sheet(item: $selectedTopic) { topic in
            TopicDetailView(topic: topic)
        }
        .alert("Save Topic", isPresented: $showSaveAlert, actions: {
            TextField("Topic Title", text: $topicTitle)
            Button("Save") {
                viewModel.saveCurrentTopic(title: topicTitle)
                topicTitle = ""
            }
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
