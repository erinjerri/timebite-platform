import SwiftUI

struct TimeRangePicker: View {
    @Binding var selectedRange: TimeRange

    var body: some View {
        HStack(spacing: 8) {
            ForEach(TimeRange.allCases) { range in
                Button {
                    selectedRange = range
                } label: {
                    Text(range.rawValue)
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(selectedRange == range ? TBColor.textPrimary : TBColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule(style: .continuous)
                                .fill(selectedRange == range ? TBColor.primaryAccent.opacity(0.18) : TBColor.surfaceElevated)
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(selectedRange == range ? TBColor.primaryAccent.opacity(0.4) : TBColor.border, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

