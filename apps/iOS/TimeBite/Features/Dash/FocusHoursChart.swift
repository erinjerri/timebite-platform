import SwiftUI
import Charts

struct FocusHoursChart: View {
    let points: [FocusHourPoint]

    var body: some View {
        TBCard {
            VStack(alignment: .leading, spacing: TBSpacing.md) {
                TBSectionHeader(title: "Focus hours", subtitle: "Execution truth by time range")

                Chart(points) { point in
                    BarMark(
                        x: .value("Day", point.label),
                        y: .value("Minutes", point.minutes)
                    )
                    .cornerRadius(8)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [TBColor.primaryAccent, TBColor.secondaryAccent],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine().foregroundStyle(TBColor.border)
                        AxisTick().foregroundStyle(TBColor.border)
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .foregroundStyle(TBColor.textSecondary)
                            }
                        }
                    }
                }
                .chartYScale(domain: 0...220)
            }
        }
    }
}

