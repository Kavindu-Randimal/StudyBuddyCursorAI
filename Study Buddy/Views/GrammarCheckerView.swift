import SwiftUI

struct GrammarCheckerView: View {
    @StateObject private var viewModel = GrammarCheckerViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Grammar Checker")
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 8)

            Text("Enter text to check:")
                .font(.headline)

            ZStack(alignment: .topTrailing) {
                TextEditor(text: $viewModel.userInput)
                    .frame(minHeight: 150, maxHeight: 300)
                    .border(Color.gray, width: 1)
                    .cornerRadius(8)

                if !viewModel.userInput.isEmpty {
                    Button(action: { viewModel.userInput = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                }
            }

            Button(action: {
                hideKeyboard()
                Task { await viewModel.checkGrammar() }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Check Grammar")
                }
            }
            .buttonStyle(GradientButtonStyle())
            .disabled(viewModel.userInput.isEmpty)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            if !viewModel.correctedText.isEmpty {
                HStack {
                    Text("Corrected Text:")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        UIPasteboard.general.string = viewModel.correctedText
                    }) {
                        Image(systemName: "doc.on.doc")
                    }
                }
                
                ScrollView {
                    Text(viewModel.correctedText)
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
