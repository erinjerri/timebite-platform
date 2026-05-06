import SwiftUI

struct GoalsView: View {
    let environment: SpatialEnvironment
    let tokens: DesignTokens

    private let goals = [
        ("App", "Prototype spatial engine"),
        ("Income", "Package reusable offer"),
        ("Brand", "Refine TimeBite identity")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: tokens.spacing.spacious) {
            Text("Goals")
                .font(tokens.typography.title)
                .foregroundStyle(tokens.color.primaryText)

            ForEach(goals, id: \.0) { goal in
                SpatialCard(title: goal.0, subtitle: environment.intent == .operator ? "Weekly target" : "Focus area", tokens: tokens) {
                    HStack {
                        Text(goal.1)
                            .font(tokens.typography.body)
                            .foregroundStyle(tokens.color.primaryText)
                        Spacer()
                        Text(environment.intent == .operator ? "72%" : "On track")
                            .font(tokens.typography.monospaced)
                            .foregroundStyle(tokens.color.accent)
                    }
                }
            }
        }
        .padding(tokens.spacing.spacious)
    }
}

