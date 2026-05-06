import SwiftUI

struct SpatialCard<Content: View>: View {
    let title: String
    let subtitle: String?
    let tokens: DesignTokens
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        tokens: DesignTokens,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.tokens = tokens
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: tokens.spacing.standard) {
            VStack(alignment: .leading, spacing: tokens.spacing.compact / 2) {
                Text(title)
                    .font(tokens.typography.section)
                    .foregroundStyle(tokens.color.primaryText)

                if let subtitle {
                    Text(subtitle)
                        .font(tokens.typography.caption)
                        .foregroundStyle(tokens.color.secondaryText)
                }
            }

            content
        }
        .padding(tokens.spacing.standard)
        .spatialSurface(tokens, radius: tokens.dataViz.cornerRadius)
    }
}

