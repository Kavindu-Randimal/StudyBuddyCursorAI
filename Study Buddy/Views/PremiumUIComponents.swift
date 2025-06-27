import SwiftUI

// MARK: - App Theme
struct Theme {
    static let aiGradient = LinearGradient(
        gradient: Gradient(colors: [Color.purple, Color.orange, Color.blue]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Premium Card View
struct PremiumCardView<Content: View>: View {
    let content: Content
    let verticalPadding: CGFloat
    let hasBorder: Bool

    init(verticalPadding: CGFloat = 8, hasBorder: Bool = true, @ViewBuilder content: () -> Content) {
        self.verticalPadding = verticalPadding
        self.hasBorder = hasBorder
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .overlay(
                Group {
                    if hasBorder {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Theme.aiGradient, lineWidth: 2)
                    }
                }
            )
            .padding(.horizontal)
            .padding(.vertical, verticalPadding)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let systemImageName: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImageName)
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(Theme.aiGradient)
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Gradient Border Modifier (from before)
struct GradientBorderModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var lineWidth: CGFloat = 2

    func body(content: Content) -> some View {
        content
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Theme.aiGradient, lineWidth: lineWidth)
            )
    }
}

extension View {
    func gradientBorder(cornerRadius: CGFloat = 20, lineWidth: CGFloat = 2) -> some View {
        self.modifier(GradientBorderModifier(cornerRadius: cornerRadius, lineWidth: lineWidth))
    }
} 
