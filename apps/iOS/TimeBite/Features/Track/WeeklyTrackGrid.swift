import SwiftUI

struct WeeklyTrackGrid: View {
    let minutes: [Int]

    var body: some View {
        TBCard {
            VStack(alignment: .leading, spacing: TBSpacing.md) {
                TBSectionHeader(title: "Weekly rhythm", subtitle: "Seven-day snapshot")

                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(Array(minutes.enumerated()), id: \.offset) { index, value in
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            TBColor.primaryAccent.opacity(0.9),
                                            TBColor.secondaryAccent.opacity(0.75)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: max(CGFloat(value) * 1.6, 28))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(TBColor.primaryAccent.opacity(0.18), lineWidth: 1)
                                )

                            Text(shortWeekday(index))
                                .font(TBTypography.caption(.semibold))
                                .foregroundStyle(TBColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 180)
            }
        }
    }

    private func shortWeekday(_ index: Int) -> String {
        ["M", "T", "W", "T", "F", "S", "S"][index % 7]
    }
}

