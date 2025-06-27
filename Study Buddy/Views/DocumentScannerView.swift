import SwiftUI
import VisionKit
import Vision
import NaturalLanguage

struct DocumentScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScannerView

        init(parent: DocumentScannerView) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var recognizedText = ""
            let group = DispatchGroup()

            for pageIndex in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                group.enter()
                recognizeText(from: image) { text in
                    recognizedText += text + "\n"
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.parent.onScan(recognizedText)
                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.presentationMode.wrappedValue.dismiss()
        }

        private func recognizeText(from image: UIImage, completion: @escaping (String) -> Void) {
            guard let cgImage = image.cgImage else {
                completion("")
                return
            }
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { (request, error) in
                let text = (request.results as? [VNRecognizedTextObservation])?
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n") ?? ""
                completion(text)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            try? requestHandler.perform([request])
        }
    }
}
/*
@MainActor
class SummarizeViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var summary: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var wordCount: Int = 50
    @Published var detectedLanguageCode: String = "en"

    var detectedLanguageName: String {
        Locale.current.localizedString(forIdentifier: detectedLanguageCode) ?? "English"
    }

    var summaryWordCount: Int {
        summary
            .split { $0.isWhitespace || $0.isNewline }
            .filter { !$0.isEmpty }
            .count
    }

    private let textService: TextServiceProtocol

    init(textService: TextServiceProtocol = GeminiService()) {
        self.textService = textService
    }

    func summarizeText() async {
        guard !userInput.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        summary = ""

        if let lang = detectLanguage(for: userInput) {
            detectedLanguageCode = lang
        } else {
            detectedLanguageCode = "en"
        }

        do {
            let generatedSummary = try await textService.summarizeText(
                from: userInput,
                wordCount: self.wordCount,
                languageCode: detectedLanguageCode
            )
            summary = generatedSummary
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func detectLanguage(for text: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        if let language = recognizer.dominantLanguage {
            return language.rawValue
        }
        return nil
    }
}

struct SummarizeView: View {
    @StateObject private var viewModel = SummarizeViewModel()
    @State private var showScanner = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
*/
