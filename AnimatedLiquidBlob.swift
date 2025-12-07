import SwiftUI

struct AnimatedLiquidBlob: View {
    @State private var phase: CGFloat = 0
    @State private var gradientRotation: CGFloat = 0

    var body: some View {
        ZStack {
            // Main liquid colour layer
            Rectangle()
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            .red,
                            .orange,
                            .yellow,
                            .cyan,
                            .blue,
                            .purple,
                            .pink,
                            .red
                        ]),
                        center: .center,
                        angle: .degrees(gradientRotation)
                    )
                )
                .blur(radius: 26)      // colours blend
                .frame(width: 230, height: 230)
                .mask(
                    LiquidBlob(phase: phase)
                        .frame(width: 230, height: 230)
                )
                // very subtle soft shadow, not a ring
                .shadow(color: .black.opacity(0.45),
                        radius: 24, x: 0, y: 12)

            // Soft highlight on top (still no outline)
            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.55),
                            .white.opacity(0.0)
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .blur(radius: 22)
                .frame(width: 230, height: 230)
                .mask(
                    LiquidBlob(phase: phase)
                        .frame(width: 230, height: 230)
                )
                .blendMode(.screen)
                .opacity(0.9)
        }
        .frame(width: 260, height: 260)
        .drawingGroup()
        .onAppear {
            // shape wobble
            withAnimation(
                .easeInOut(duration: 7)
                    .repeatForever(autoreverses: true)
            ) {
                phase = .pi * 4
            }

            // slow colour rotation
            withAnimation(
                .linear(duration: 18)
                    .repeatForever(autoreverses: false)
            ) {
                gradientRotation = 360
            }
        }
    }
}
