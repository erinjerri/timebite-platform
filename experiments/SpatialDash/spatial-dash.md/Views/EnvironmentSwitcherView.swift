import SwiftUI

struct EnvironmentSwitcherView: View {
    @Binding var environment: SpatialEnvironment
    let tokens: DesignTokens

    var body: some View {
        HStack(spacing: tokens.spacing.compact) {
            ForEach(SpatialEnvironment.presets) { preset in
                Button {
                    environment = preset
                } label: {
                    Text(shortName(for: preset))
                        .font(tokens.typography.caption)
                        .foregroundStyle(environment.id == preset.id ? tokens.color.background : tokens.color.primaryText)
                        .padding(.horizontal, tokens.spacing.standard)
                        .padding(.vertical, tokens.spacing.compact)
                        .background(environment.id == preset.id ? tokens.color.accent : tokens.color.surface.opacity(0.6))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .animation(SpatialEnvironmentRenderer.animation(for: tokens), value: environment.id)
    }

    private func shortName(for environment: SpatialEnvironment) -> String {
        switch environment.id {
        case SpatialEnvironment.timebiteLight.id:
            return "Light"
        case SpatialEnvironment.timebiteDark.id:
            return "Dark"
        default:
            return "Operator"
        }
    }
}

