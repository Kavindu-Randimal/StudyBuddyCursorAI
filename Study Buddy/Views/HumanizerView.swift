import SwiftUI

struct HumanizerView: View {
    @StateObject private var viewModel = HumanizerViewModel()
    @State private var showCopiedMessage = false
    @State private var showScanner = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Humanize Text")
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 8)
            
            Text("Enter text to humanize:")
                .font(.headline)

            ZStack(alignment: .topTrailing) {
                TextEditor(text: $viewModel.userInput)
                    .frame(minHeight: 150, maxHeight: 300)
                    .gradientBorder()
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
            .buttonStyle(GradientButtonStyle())
            .disabled(viewModel.userInput.isEmpty)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            if !viewModel.humanizedText.isEmpty {
                HStack {
                    Text("Humanized Version:")
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
                        UIPasteboard.general.string = viewModel.humanizedText
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
        .onTapGesture {
            hideKeyboard()
        }
    }
} 
