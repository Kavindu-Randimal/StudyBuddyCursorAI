import SwiftUI

struct CustomKeyboard: View {
    var onKeyPress: (String) -> Void
    var onBackspace: () -> Void
    var onReturn: (() -> Void)? = nil

    let keys: [[String]] = [
        ["Q","W","E","R","T","Y","U","I","O","P"],
        ["A","S","D","F","G","H","J","K","L"],
        ["Z","X","C","V","B","N","M"]
    ]

    // Your app's gradient
    let aiGradient = LinearGradient(
        gradient: Gradient(colors: [Color.purple, Color.orange, Color.blue]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        VStack(spacing: 8) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.self) { key in
                        Button(action: { onKeyPress(key) }) {
                            Text(key)
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 44)
                                .background(
                                    aiGradient
                                        .cornerRadius(8)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            HStack(spacing: 6) {
                Button(action: { onKeyPress(" ") }) {
                    Text("Space")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 44)
                        .background(
                            aiGradient
                                .cornerRadius(8)
                        )
                }
                .buttonStyle(.plain)
                Button(action: { onBackspace() }) {
                    Image(systemName: "delete.left")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            aiGradient
                                .cornerRadius(8)
                        )
                }
                .buttonStyle(.plain)
                if let onReturn = onReturn {
                    Button(action: { onReturn() }) {
                        Text("Return")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 70, height: 44)
                            .background(
                                aiGradient
                                    .cornerRadius(8)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
} 