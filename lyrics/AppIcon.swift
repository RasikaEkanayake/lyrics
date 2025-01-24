import SwiftUI

struct AppIcon: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Dynamic gradient background
            AngularGradient(
                gradient: Gradient(colors: [
                    .purple,
                    .blue,
                    .cyan,
                    .purple
                ]),
                center: .center,
                startAngle: .degrees(isAnimating ? 0 : 360),
                endAngle: .degrees(isAnimating ? 360 : 0)
            )
            
            // Overlay gradient for depth
            RadialGradient(
                gradient: Gradient(colors: [
                    .white.opacity(0.2),
                    .clear
                ]),
                center: .topLeading,
                startRadius: 0,
                endRadius: 900
            )
            
            // Music note with 3D effect
            Image(systemName: "music.note")
                .font(.system(size: 120, weight: .bold))
                .foregroundStyle(
                    .linearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 15, y: 8)
                .rotationEffect(.degrees(-15))
                .scaleEffect(isAnimating ? 1.1 : 1.0)
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 224))
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    AppIcon()
        .frame(width: 200, height: 200)
        .preferredColorScheme(.dark)
} 