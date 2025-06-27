import SwiftUI

struct TranslateView: View {
    @StateObject private var viewModel = TranslateViewModel()
    @State private var showScanner = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Translate Text")
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 8)

            Text("Enter text to translate:")
                .font(.headline)

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

            ZStack(alignment: .topTrailing) {
                TextEditor(text: $viewModel.userInput)
                    .frame(minHeight: 150, maxHeight: 300)
                    .gradientBorder()
                    .cornerRadius(8)
                    .foregroundColor(.primary)
                    .background(Color(.systemBackground))

                if !viewModel.userInput.isEmpty {
                    Button(action: { viewModel.userInput = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                }
            }

            // Dropdown Language Picker
            Menu {
                Picker("Translate to:", selection: $viewModel.targetLanguage) {
                    ForEach(viewModel.availableLanguages, id: \.self) { language in
                        Text(language).tag(language)
                    }
                }
            } label: {
                HStack {
                    Text("Translate to:")
                    Spacer()
                    Text(viewModel.targetLanguage)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.up.chevron.down")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .foregroundColor(.primary)
            }
            .padding(.vertical, 8)

            Button(action: {
                hideKeyboard()
                Task { await viewModel.translateText() }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Translate")
                }
            }
            .buttonStyle(GradientButtonStyle())
            .disabled(viewModel.userInput.isEmpty)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            if !viewModel.translatedText.isEmpty {
                HStack {
                    Text("Translation:")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        UIPasteboard.general.string = viewModel.translatedText
                    }) {
                        Image(systemName: "doc.on.doc")
                    }
                }
                
                ScrollView {
                    Text(viewModel.translatedText)
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
