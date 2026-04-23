import SwiftUI

struct InsightCard: View {
    let insight: InsightCardModel

    var body: some View {
        TBCard {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: insight.symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(insight.accent.tint)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(insight.accent.tint.opacity(0.12)))

                VStack(alignment: .leading, spacing: 6) {
                    Text(insight.title)
                        .font(TBTypography.body(.semibold))
                        .foregroundStyle(TBColor.textPrimary)
                    Text(insight.body)
                        .font(TBTypography.caption())
                        .foregroundStyle(TBColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
        }
    }
}

