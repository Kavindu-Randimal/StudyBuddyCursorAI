import SwiftUI

struct SummarizeView: View {
    @StateObject private var viewModel = SummarizeViewModel()
    @State private var showScanner = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Summarize")
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 8)
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

            TextEditor(text: $viewModel.userInput)
                .frame(minHeight: 150, maxHeight: 300)
                .gradientBorder()

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
                    Text("Summary (\(viewModel.detectedLanguageName)):")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Text("Word count: \(viewModel.summaryWordCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 2)

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
        .onTapGesture { hideKeyboard() }
    }
} 
