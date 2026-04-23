import SwiftUI
import Charts

struct CategorySplitDonut: View {
    let shares: [CategoryShare]

    var body: some View {
        TBCard {
            VStack(alignment: .leading, spacing: TBSpacing.md) {
                TBSectionHeader(title: "Category split", subtitle: "Where the time went")

                HStack(alignment: .center, spacing: TBSpacing.lg) {
                    Chart(shares) { share in
                        SectorMark(
                            angle: .value("Share", share.value),
                            innerRadius: .ratio(0.65),
                            angularInset: 1.2
                        )
                        .foregroundStyle(share.category.tint)
                    }
                    .frame(width: 180, height: 180)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(shares) { share in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(share.category.tint)
                                    .frame(width: 10, height: 10)
                                Text(share.category.title)
                                    .font(TBTypography.caption(.semibold))
                                    .foregroundStyle(TBColor.textPrimary)
                                Spacer()
                                Text("\(Int(share.value))%")
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

