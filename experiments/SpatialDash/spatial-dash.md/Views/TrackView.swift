import SwiftUI

struct TrackView: View {
    let environment: SpatialEnvironment
    let tokens: DesignTokens

    private let blocks = ["Plan", "Build", "Review", "Reset"]

    var body: some View {
        VStack(alignment: .leading, spacing: tokens.spacing.spacious) {
            Text("Track")
                .font(tokens.typography.title)
                .foregroundStyle(tokens.color.primaryText)

            SpatialCard(title: "Cycle History", subtitle: "Productivity rhythm", tokens: tokens) {
                DataVizPlaceholder(tokens: tokens, compact: false)
            }

            LazyVGrid(columns: columns, spacing: tokens.spacing.standard) {
                ForEach(blocks, id: \.self) { block in
                    SpatialCard(title: block, subtitle: "Time block", tokens: tokens) {
                        Text(environment.intent == .operator ? "Logged precisely" : "Logged quietly")
                            .font(tokens.typography.body)
                            .foregroundStyle(tokens.color.secondaryText)
                    }
                }
            }
        }
        .padding(tokens.spacing.spacious)
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: tokens.spacing.standard), count: environment.density == .dense ? 4 : 2)
    }
}

