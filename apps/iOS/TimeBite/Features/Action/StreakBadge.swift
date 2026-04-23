import SwiftUI

struct StreakBadge: View {
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .foregroundStyle(TBColor.gold)
            Text("\(count)-day streak")
                .font(TBTypography.caption(.semibold))
        }
        .foregroundStyle(TBColor.textPrimary)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            Capsule(style: .continuous)
                .fill(TBColor.gold.opacity(0.12))
                .overlay(Capsule(style: .continuous).stroke(TBColor.gold.opacity(0.28), lineWidth: 1))
        )
    }
}

