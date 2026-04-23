import SwiftUI

struct GoalCardView: View {
    let goal: GoalItem
    let isExpanded: Bool
    let toggleExpansion: () -> Void

    var body: some View {
        TBCard {
            VStack(alignment: .leading, spacing: TBSpacing.md) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text(goal.phase)
                                .font(TBTypography.caption(.semibold))
                                .foregroundStyle(goal.category.tint)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(goal.category.tint.opacity(0.12))
                                )

                            Label(goal.status.title, systemImage: goal.status.symbol)
                                .font(TBTypography.caption(.semibold))
                                .foregroundStyle(goal.status.tint)
                        }

                        Text(goal.title)
                            .font(TBTypography.title(.headline, weight: .semibold))
                            .foregroundStyle(TBColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(goal.summary)
                            .font(TBTypography.caption())
                            .foregroundStyle(TBColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        Text(goal.targetDate)
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(TBColor.textPrimary)
                        Text("\(Int(goal.progress * 100))%")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(TBColor.textPrimary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: goal.progress)
                        .tint(goal.category.tint)
                    HStack {
                        Text(goal.checkpoints.first ?? "In progress")
                            .font(TBTypography.caption())
                            .foregroundStyle(TBColor.textSecondary)
                        Spacer()
                        Text(goal.checkpoints.last ?? "Next milestone")
                            .font(TBTypography.caption())
                            .foregroundStyle(TBColor.textSecondary)
                    }
                }

                HStack(spacing: 8) {
                    ForEach(goal.badges, id: \.self) { badge in
                        Text(badge)
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(TBColor.textPrimary)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(TBColor.surfaceElevated)
                            )
                    }
                }

                GoalDetailDisclosure(title: isExpanded ? "Hide details" : "Show details", isExpanded: isExpanded, action: toggleExpansion)

                if isExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(goal.details, id: \.self) { detail in
                            HStack(alignment: .top, spacing: 8) {
                                Circle()
                                    .fill(goal.category.tint)
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 6)
                                Text(detail)
                                    .font(TBTypography.caption())
                                    .foregroundStyle(TBColor.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.top, 2)
                }
            }
        }
    }
}

