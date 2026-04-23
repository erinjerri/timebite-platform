import SwiftUI

struct TrackSegmentedControl: View {
    @Binding var selectedPeriod: TrackPeriod

    var body: some View {
        HStack(spacing: 8) {
            ForEach(TrackPeriod.allCases) { period in
                Button {
                    selectedPeriod = period
                } label: {
                    Text(period.rawValue)
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(selectedPeriod == period ? TBColor.textPrimary : TBColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selectedPeriod == period ? TBColor.primaryAccent.opacity(0.18) : TBColor.surfaceElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(selectedPeriod == period ? TBColor.primaryAccent.opacity(0.42) : TBColor.border, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

