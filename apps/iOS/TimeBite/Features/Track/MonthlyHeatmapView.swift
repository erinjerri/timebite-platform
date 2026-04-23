import SwiftUI

struct MonthlyHeatmapView: View {
    let intensity: [[Double]]

    var body: some View {
        TBCard {
            VStack(alignment: .leading, spacing: TBSpacing.md) {
                TBSectionHeader(title: "Monthly heatmap", subtitle: "Momentum at a glance")

                VStack(spacing: 8) {
                    ForEach(Array(intensity.enumerated()), id: \.offset) { rowIndex, row in
                        HStack(spacing: 8) {
                            ForEach(Array(row.enumerated()), id: \.offset) { columnIndex, value in
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(cellColor(value))
                                    .frame(height: 22)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(TBColor.border, lineWidth: value > 0.7 ? 0.5 : 0)
                                    )
                                    .accessibilityLabel("Row \(rowIndex) column \(columnIndex)")
                            }
                        }
                    }
                }

                HStack {
                    Text("Lighter = lighter day")
                        .font(TBTypography.caption())
                        .foregroundStyle(TBColor.textSecondary)
                    Spacer()
                    HStack(spacing: 6) {
                        Circle().fill(TBColor.surfaceElevated).frame(width: 8, height: 8)
                        Circle().fill(TBColor.primaryAccent.opacity(0.55)).frame(width: 8, height: 8)
                        Circle().fill(TBColor.primaryAccent).frame(width: 8, height: 8)
                    }
                }
            }
        }
    }

    private func cellColor(_ value: Double) -> Color {
        let opacity = 0.10 + (value * 0.70)
        return TBColor.primaryAccent.opacity(opacity)
    }
}

