import SwiftUI

struct KPIStatCard: View {
    let stat: KPIStat

    var body: some View {
        TBCard(padding: TBSpacing.md) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: stat.symbol)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(stat.tint.tint)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(stat.tint.tint.opacity(0.12)))
                    Spacer()
                }

                Text(stat.value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(TBColor.textPrimary)

                Text(stat.title)
                    .font(TBTypography.body(.semibold))
                    .foregroundStyle(TBColor.textPrimary)

                Text(stat.subtitle)
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
            }
        }
    }
}

