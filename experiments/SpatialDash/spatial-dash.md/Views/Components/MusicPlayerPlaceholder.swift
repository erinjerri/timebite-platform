import SwiftUI

struct MusicPlayerPlaceholder: View {
    let tokens: DesignTokens

    var body: some View {
        VStack(alignment: .leading, spacing: tokens.spacing.standard) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            tokens.color.accent.opacity(0.75),
                            tokens.color.ringSecondary.opacity(0.65)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 92)
                .overlay(alignment: .bottomLeading) {
                    Text("Ambient Focus")
                        .font(tokens.typography.caption)
                        .foregroundStyle(tokens.color.primaryText)
                        .padding(tokens.spacing.compact)
                }

            HStack(spacing: tokens.spacing.compact) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index == 1 ? tokens.color.accent : tokens.color.secondaryText.opacity(0.35))
                        .frame(width: 12, height: 12)
                }

                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(tokens.color.secondaryText.opacity(0.3))
                    .frame(height: 6)
            }
        }
        .accessibilityLabel("Ambient music panel placeholder")
    }
}

