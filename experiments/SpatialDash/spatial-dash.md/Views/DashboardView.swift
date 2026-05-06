import SwiftUI

struct DashboardView: View {
    let environment: SpatialEnvironment
    let tokens: DesignTokens

    var body: some View {
        VStack(alignment: .leading, spacing: tokens.spacing.spacious) {
            Text("Dashboard")
                .font(tokens.typography.title)
                .foregroundStyle(tokens.color.primaryText)

            HStack(alignment: .center, spacing: tokens.spacing.standard) {
                SpatialCard(title: "Rhythm", subtitle: "Data visualization", tokens: tokens) {
                    DataVizPlaceholder(tokens: tokens, compact: environment.density != .dense)
                }
                .frame(maxWidth: .infinity)

                SpatialCard(title: "Active Timer", subtitle: "Current TimeBite", tokens: tokens) {
                    TorusTimerPlaceholder(tokens: tokens, progress: 0.68)
                        .frame(maxHeight: environment.intent == .operator ? 240 : 300)
                }
                .frame(maxWidth: .infinity)

                SpatialCard(title: "Ambient", subtitle: "Music placeholder", tokens: tokens) {
                    MusicPlayerPlaceholder(tokens: tokens)
                }
                .frame(maxWidth: .infinity)
            }

            summaryStrip
        }
        .padding(tokens.spacing.spacious)
    }

    private var summaryStrip: some View {
        HStack(spacing: tokens.spacing.standard) {
            summary("Focus", "3h 24m")
            summary("Cycles", "8")
            summary("Goal Flow", "72%")
            summary("Mood", environment.mood.rawValue.capitalized)
        }
    }

    private func summary(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: tokens.spacing.compact) {
            Text(label)
                .font(tokens.typography.caption)
                .foregroundStyle(tokens.color.secondaryText)
            Text(value)
                .font(tokens.typography.section)
                .foregroundStyle(tokens.color.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(tokens.spacing.standard)
        .spatialSurface(tokens, radius: 12)
    }
}

