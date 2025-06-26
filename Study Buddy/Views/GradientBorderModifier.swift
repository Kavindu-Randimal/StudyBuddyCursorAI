import SwiftUI

struct GradientBorderModifier: ViewModifier {
    var cornerRadius: CGFloat = 8
    var lineWidth: CGFloat = 2

    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color.purple, Color.orange, Color.blue]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(gradient, lineWidth: lineWidth)
            )
    }
}

extension View {
    func gradientBorder(cornerRadius: CGFloat = 8, lineWidth: CGFloat = 2) -> some View {
        self.modifier(GradientBorderModifier(cornerRadius: cornerRadius, lineWidth: lineWidth))
    }
} 