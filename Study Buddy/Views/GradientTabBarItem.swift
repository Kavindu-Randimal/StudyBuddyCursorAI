import SwiftUI

struct GradientTabBarItem: View {
    let systemImage: String
    let title: String
    let isSelected: Bool

    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color.purple, Color.orange, Color.blue]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        VStack(spacing: 2) {
            if isSelected {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .bold))
                    .overlay(
                        gradient
                            .mask(
                                Image(systemName: systemImage)
                                    .font(.system(size: 22, weight: .bold))
                            )
                    )
                Text(title)
                    .font(.caption)
                    .overlay(
                        gradient
                            .mask(
                                Text(title)
                                    .font(.caption)
                            )
                    )
            } else {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.gray)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
} 