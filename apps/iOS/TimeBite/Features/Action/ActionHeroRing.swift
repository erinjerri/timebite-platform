import SwiftUI

struct ActionHeroRing: View {
    @Binding var title: String
    let category: CategoryType
    let streakDays: Int
    let progress: Double
    let countdownText: String
    let progressText: String

    var body: some View {
        TBCard(padding: TBSpacing.xl) {
            VStack(alignment: .leading, spacing: TBSpacing.lg) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today’s Action")
                            .font(TBTypography.caption(.semibold))
                            .tracking(1.1)
                            .foregroundStyle(TBColor.textSecondary)

                        TextField("What are we doing right now?", text: $title, axis: .vertical)
                            .font(TBTypography.title(.title2, weight: .semibold))
                            .foregroundStyle(TBColor.textPrimary)
                            .textInputAutocapitalization(.sentences)
                            .lineLimit(2...3)

                        HStack(spacing: 10) {
                            Label(category.title, systemImage: category.symbol)
                                .font(TBTypography.caption(.semibold))
                                .foregroundStyle(category.tint)
                                .padding(.vertical, 7)
                                .padding(.horizontal, 10)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(category.tint.opacity(0.14))
                                )

                            StreakBadge(count: streakDays)
                        }
                    }

                    Spacer()
                }

                ZStack {
                    Circle()
                        .stroke(TBColor.borderStrong, lineWidth: 20)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            TBColor.ringGradient,
                            style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .shadow(color: TBShadow.glow, radius: 20, x: 0, y: 0)

                    Circle()
                        .strokeBorder(TBColor.primaryAccent.opacity(0.08), lineWidth: 36)

                    VStack(spacing: 8) {
                        Text(countdownText)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(TBColor.textPrimary)

                        Text(progressText)
                            .font(TBTypography.caption())
                            .foregroundStyle(TBColor.textSecondary)
                    }
                }
                .frame(width: 230, height: 230)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)

                HStack {
                    Label("Momentum: locked in", systemImage: "bolt.fill")
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.primaryAccent)
                    Spacer()
                    Text("Focus loop")
                        .font(TBTypography.caption())
                        .foregroundStyle(TBColor.textSecondary)
                }
            }
        }
    }
}

