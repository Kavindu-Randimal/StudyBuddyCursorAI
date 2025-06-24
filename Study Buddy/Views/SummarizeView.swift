import SwiftUI

struct SummarizeView: View {
    @StateObject private var viewModel = SummarizeViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Summarize Text")
                .font(.largeTitle)
                .bold()
                .padding(.top, 16)
                .padding(.bottom, 8)

            Text("Enter text to summarize:")
                .font(.headline)

            TextEditor(text: $viewModel.userInput)
                .frame(minHeight: 150, maxHeight: 300)
                .border(Color.gray, width: 1)
                .cornerRadius(8)

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
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.userInput.isEmpty)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            if !viewModel.summary.isEmpty {
                Text("Summary:")
                    .font(.title2)
                    .fontWeight(.bold)
                
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
    }
} 