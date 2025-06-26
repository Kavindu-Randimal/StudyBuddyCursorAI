import SwiftUI

struct SummarizeView: View {
    @StateObject private var viewModel = SummarizeViewModel()
    @State private var showCopiedMessage = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Summarize Text")
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 8)
            
            Text("Enter text to summarize:")
                .font(.headline)

            ZStack(alignment: .topTrailing) {
                TextEditor(text: $viewModel.userInput)
                    .frame(minHeight: 150, maxHeight: 300)
                    .border(Color.gray, width: 1)
                    .cornerRadius(8)

                if !viewModel.userInput.isEmpty {
                    Button(action: {
                        viewModel.userInput = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                }
            }

            HStack {
                Text("Summary Word Count:")
                Spacer()
                Text("\(viewModel.wordCount)")
                    .fontWeight(.bold)
                Stepper("", value: $viewModel.wordCount, in: 20...200, step: 10)
                    .labelsHidden()
            }
            .padding(.vertical, 8)

            Button(action: {
                hideKeyboard()
                Task { await viewModel.summarizeText() }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Summarize")
                }
            }
            .buttonStyle(GradientButtonStyle())
            .disabled(viewModel.userInput.isEmpty)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            if !viewModel.summary.isEmpty {
                HStack {
                    Text("Summary:")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    if showCopiedMessage {
                        Text("Copied!")
                            .font(.caption)
                            .foregroundColor(.green)
                            .transition(.opacity)
                    }
                    Button(action: {
                        UIPasteboard.general.string = viewModel.summary
                        withAnimation {
                            showCopiedMessage = true
                        }
                        // Hide the message after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showCopiedMessage = false
                            }
                        }
                    }) {
                        Image(systemName: "doc.on.doc")
                            .imageScale(.large)
                    }
                }
                
                ScrollView {
                    Text(viewModel.summary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            Spacer()
        }
        .padding()
        .onTapGesture {
            hideKeyboard()
        }
    }
} 
