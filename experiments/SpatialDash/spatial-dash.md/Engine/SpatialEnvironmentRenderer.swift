import SwiftUI

enum SpatialEnvironmentRenderer {
    static func animation(for tokens: DesignTokens) -> Animation {
        switch tokens.motion.curve {
        case .easeInOut:
            return .easeInOut(duration: tokens.motion.duration)
        case .easeOut:
            return .easeOut(duration: tokens.motion.duration)
        case .spring:
            return .spring(response: tokens.motion.duration, dampingFraction: 0.82)
        }
    }

    static func shadowColor(for tokens: DesignTokens) -> Color {
        switch tokens.lighting.shadow {
        case .soft:
            return .black.opacity(0.08)
        case .subtleGlow:
            return tokens.color.accent.opacity(0.18)
        case .crispGlow:
            return tokens.color.accent.opacity(0.26)
        }
    }

    static func shadowRadius(for tokens: DesignTokens) -> CGFloat {
        switch tokens.lighting.shadow {
        case .soft:
            return 16
        case .subtleGlow:
            return 24
        case .crispGlow:
            return 12
        }
    }

    static func surfaceStroke(for tokens: DesignTokens) -> Color {
        switch tokens.material.surface {
        case .matte:
            return tokens.color.divider
        case .softGlass:
            return tokens.color.primaryText.opacity(0.08)
        case .sharpGlass:
            return tokens.color.accent.opacity(0.28)
        }
    }
}

extension View {
    func spatialBackground(_ tokens: DesignTokens) -> some View {
        background(tokens.color.background.ignoresSafeArea())
    }

    func spatialSurface(_ tokens: DesignTokens, radius: CGFloat = 18) -> some View {
        background(tokens.color.surface.opacity(tokens.material.opacity))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(SpatialEnvironmentRenderer.surfaceStroke(for: tokens), lineWidth: 1)
            )
            .shadow(
                color: SpatialEnvironmentRenderer.shadowColor(for: tokens),
                radius: SpatialEnvironmentRenderer.shadowRadius(for: tokens),
                y: tokens.lighting.shadow == .soft ? 8 : 0
            )
    }
}

