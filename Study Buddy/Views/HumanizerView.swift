import SwiftUI

struct HumanizerView: View {
    @StateObject private var viewModel = HumanizerViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Humanize Text")
                .font(.largeTitle)
                .bold()
                .padding(.top, 16)
                .padding(.bottom, 8)

            Text("Enter text to humanize:")
                .font(.headline)

            TextEditor(text: $viewModel.userInput)
                .frame(minHeight: 150, maxHeight: 300)
                .border(Color.gray, width: 1)
                .cornerRadius(8)

            Button(action: {
                hideKeyboard()
                Task { await viewModel.humanizeText() }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Humanize")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.userInput.isEmpty)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            if !viewModel.humanizedText.isEmpty {
                Text("Humanized Version:")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ScrollView {
                    Text(viewModel.humanizedText)
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