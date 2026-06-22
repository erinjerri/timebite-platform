import SwiftUI

struct ActionsView: View {
    let environment: SpatialEnvironment
    let tokens: DesignTokens

    var body: some View {
        VStack(alignment: .leading, spacing: tokens.spacing.spacious) {
            header

            HStack(alignment: .center, spacing: tokens.spacing.spacious) {
                TorusTimerPlaceholder(tokens: tokens, progress: 0.68)
                    .frame(maxWidth: environment.intent == .focus ? 420 : 360)

                VStack(spacing: tokens.spacing.standard) {
                    SpatialCard(title: "Daily Goals", subtitle: "Today's anchor", tokens: tokens) {
                        Text("Ship the clearest version of the spatial dashboard engine.")
                            .font(tokens.typography.body)
                            .foregroundStyle(tokens.color.primaryText)
                    }

                    SpatialCard(title: "Current Focus", subtitle: "Active TimeBite cycle", tokens: tokens) {
                        metricRow("Sprint", value: "2 of 4")
                        metricRow("Energy", value: environment.energy.rawValue.capitalized)
                    }
                }
            }
        }
        .padding(tokens.spacing.spacious)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: tokens.spacing.compact) {
            Text("Actions")
                .font(tokens.typography.title)
                .foregroundStyle(tokens.color.primaryText)
            Text(environment.intent == .focus ? "Minimal surface for today's actions and active time." : "Active command surface for the current cycle.")
                .font(tokens.typography.body)
                .foregroundStyle(tokens.color.secondaryText)
        }
    }

    private func metricRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(tokens.color.secondaryText)
            Spacer()
            Text(value)
                .foregroundStyle(tokens.color.primaryText)
        }
        .font(tokens.typography.body)
    }
}
