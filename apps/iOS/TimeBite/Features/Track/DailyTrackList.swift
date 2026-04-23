import SwiftUI

struct DailyTrackList: View {
    let entries: [HabitEntry]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(entries) { entry in
                TBCard {
                    HStack(alignment: .top, spacing: 14) {
                        VStack(spacing: 6) {
                            Image(systemName: entry.completed ? "checkmark.circle.fill" : "clock.badge.exclamationmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(entry.completed ? TBColor.primaryAccent : entry.category.tint)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(entry.category.tint.opacity(0.12)))

                            RoundedRectangle(cornerRadius: 99, style: .continuous)
                                .fill(entry.completed ? TBColor.primaryAccent : TBColor.textSecondary.opacity(0.35))
                                .frame(width: 2, height: 34)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(entry.title)
                                    .font(TBTypography.body(.semibold))
                                    .foregroundStyle(TBColor.textPrimary)
                                Spacer()
                                Text("\(entry.durationMinutes) min")
                                    .font(TBTypography.caption(.semibold))
                                    .foregroundStyle(entry.completed ? TBColor.primaryAccent : TBColor.textSecondary)
                            }

                            Text(entry.note)
                                .font(TBTypography.caption())
                                .foregroundStyle(TBColor.textSecondary)
                                .lineLimit(2)

                            HStack(spacing: 8) {
                                Label(entry.category.title, systemImage: entry.category.symbol)
                                    .font(TBTypography.caption(.semibold))
                                    .foregroundStyle(entry.category.tint)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill(entry.category.tint.opacity(0.12))
                                    )

                                Spacer()

                                Text(entry.completed ? "Logged" : "Upcoming")
                                    .font(TBTypography.caption(.semibold))
                                    .foregroundStyle(TBColor.textSecondary)
                            }
                        }
                    }
                }
            }
        }
    }
}

