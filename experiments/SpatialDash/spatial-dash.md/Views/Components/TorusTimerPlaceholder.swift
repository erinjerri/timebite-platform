import SwiftUI

struct TorusTimerPlaceholder: View {
    let tokens: DesignTokens
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(tokens.color.ringSecondary.opacity(0.55), lineWidth: 28)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [tokens.color.ringPrimary, tokens.color.accent, tokens.color.ringPrimary],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 28, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(SpatialEnvironmentRenderer.animation(for: tokens), value: progress)

            VStack(spacing: tokens.spacing.compact) {
                Text("42:18")
                    .font(.system(size: 42, weight: .semibold, design: .rounded))
                    .foregroundStyle(tokens.color.primaryText)

                Text("Deep Focus")
                    .font(tokens.typography.caption)
                    .foregroundStyle(tokens.color.secondaryText)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(tokens.spacing.standard)
        .accessibilityLabel("Active timer, 42 minutes and 18 seconds remaining")
    }
}

