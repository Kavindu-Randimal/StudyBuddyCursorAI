import SwiftUI

struct AnimatedLaunchScreen: View {
    @State private var animate = false
    @State private var finished = false

    // Define the AI-inspired gradient
    let aiGradient = LinearGradient(
        gradient: Gradient(colors: [Color.purple, Color.orange, Color.blue]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 24) {
                // Animated Dots with Gradient
                ZStack {
                    ForEach(0..<6) { i in
                        Circle()
                            .fill(aiGradient)
                            .frame(width: 18, height: 18)
                            .offset(
                                x: animate ? CGFloat(sin(Double(i) * .pi / 3 + (animate ? .pi : 0))) * 40 : 0,
                                y: animate ? CGFloat(cos(Double(i) * .pi / 3 + (animate ? .pi : 0))) * 40 : 0
                            )
                            .opacity(animate ? 1 : 0.3)
                            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(Double(i) * 0.1), value: animate)
                    }
                    // Brain icon with gradient
                    Image(systemName: "brain.head.profile")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .overlay(
                            aiGradient
                                .mask(
                                    Image(systemName: "brain.head.profile")
                                        .resizable()
                                        .scaledToFit()
                                )
                        )
                        .shadow(color: Color.purple.opacity(0.5), radius: 10)
                }
                // App name with gradient
                Text("Study Buddy AI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .overlay(
                        aiGradient
                            .mask(
                                Text("Study Buddy AI")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                            )
                    )
                    .shadow(color: Color.purple.opacity(0.3), radius: 4)
                // Subtitle with gradient
                Text("Your AI-powered study companion")
                    .font(.headline)
                    .overlay(
                        aiGradient
                            .mask(
                                Text("Your AI-powered study companion")
                                    .font(.headline)
                            )
                    )
            }
            .opacity(finished ? 0 : 1)
        }
        .onAppear {
            animate = true
            // Hide after 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.7)) {
                    finished = true
                }
            }
        }
    }
} 