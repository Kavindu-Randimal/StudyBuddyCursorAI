import SwiftUI

struct GradientButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.headline.bold())
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(
                Theme.aiGradient
                    .cornerRadius(12)
                    .shadow(color: .purple.opacity(0.4), radius: 8, y: 4)
            )
            .opacity(isEnabled ? 1.0 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
