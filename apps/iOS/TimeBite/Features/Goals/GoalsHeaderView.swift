import SwiftUI

struct GoalsHeaderView: View {
    var body: some View {
        TBCard {
            VStack(alignment: .leading, spacing: TBSpacing.lg) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("GROW framework")
                        .font(TBTypography.caption(.semibold))
                        .tracking(1.2)
                        .foregroundStyle(TBColor.textSecondary)

                    Text("Goals that move from intention to commitment.")
                        .font(TBTypography.title(.title2, weight: .semibold))
                        .foregroundStyle(TBColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 10) {
                    growBadge(initial: "G", title: "Goal", subtitle: "What does success look like?", tint: TBColor.primaryAccent)
                    growBadge(initial: "R", title: "Reality", subtitle: "Where are you now?", tint: TBColor.secondaryAccent)
                }

                HStack(spacing: 10) {
                    growBadge(initial: "O", title: "Options", subtitle: "What paths exist?", tint: TBColor.gold)
                    growBadge(initial: "W", title: "Will", subtitle: "What is the next commitment?", tint: Color(red: 0.52, green: 0.91, blue: 0.72))
                }
            }
        }
    }

    private func growBadge(initial: String, title: String, subtitle: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(initial)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(tint.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TBTypography.body(.semibold))
                    .foregroundStyle(TBColor.textPrimary)
                Text(subtitle)
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(TBColor.surfaceElevated)
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(TBColor.border, lineWidth: 1))
        )
    }
}

