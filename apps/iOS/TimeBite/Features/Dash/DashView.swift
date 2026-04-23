import Charts
import SwiftUI

struct DashView: View {
    private let kpis: [DashKPI] = [
        .init(title: "Focus Time", value: "7h 42m", subtitle: "+18% vs last week", icon: "clock.fill", tint: TBColor.primaryAccent),
        .init(title: "Completion", value: "84%", subtitle: "Goals on track", icon: "checkmark.circle.fill", tint: Color(red: 0.39, green: 0.77, blue: 0.98)),
        .init(title: "Streak", value: "12 days", subtitle: "Best in 30 days", icon: "flame.fill", tint: TBColor.gold)
    ]

    private let focusSeries: [FocusPoint] = [
        .init(label: "Mon", minutes: 62),
        .init(label: "Tue", minutes: 74),
        .init(label: "Wed", minutes: 69),
        .init(label: "Thu", minutes: 91),
        .init(label: "Fri", minutes: 83),
        .init(label: "Sat", minutes: 48),
        .init(label: "Sun", minutes: 36)
    ]

    private let slices: [CategorySlice] = [
        .init(label: "Build", value: 42, tint: TBColor.primaryAccent),
        .init(label: "Growth", value: 20, tint: TBColor.secondaryAccent),
        .init(label: "Health", value: 16, tint: TBColor.gold),
        .init(label: "Admin", value: 12, tint: Color(red: 0.39, green: 0.77, blue: 0.98)),
        .init(label: "Creative", value: 10, tint: Color(red: 0.92, green: 0.47, blue: 0.82))
    ]

    private let goalRows: [GoalRow] = [
        .init(title: "TimeBite MVP", progress: 0.76, status: "Active", tint: TBColor.primaryAccent),
        .init(title: "Consistency", progress: 0.58, status: "On Track", tint: Color(red: 0.39, green: 0.77, blue: 0.98)),
        .init(title: "Recovery", progress: 0.34, status: "At Risk", tint: TBColor.gold)
    ]

    private let insights: [InsightCard] = [
        .init(
            title: "Best focus block is mid-morning",
            body: "You consistently hit your strongest sessions between 9:30 and 11:30. Front-load heavy work there.",
            icon: "sun.max.fill",
            tint: TBColor.primaryAccent
        ),
        .init(
            title: "Creative work needs a protected slot",
            body: "Creative entries are present but short. Reserve one longer block before the day fragments.",
            icon: "wand.and.stars",
            tint: Color(red: 0.92, green: 0.47, blue: 0.82)
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    kpiGrid
                    focusChart
                    categoryDonut
                    goalProgressCard
                    insightStack
                }
                .padding(16)
            }
            .background(background)
            .navigationTitle("Dash")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Execution truth")
                    .font(TBTypography.title(.title2, weight: .semibold))
                    .foregroundStyle(TBColor.textPrimary)
                Text("A clean dashboard view built from local mock data.")
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
            }
        }
    }

    private var kpiGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(kpis) { kpi in
                TBCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: kpi.icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(kpi.tint)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(kpi.tint.opacity(0.12)))
                        Text(kpi.value)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(TBColor.textPrimary)
                        Text(kpi.title)
                            .font(TBTypography.body(.semibold))
                            .foregroundStyle(TBColor.textPrimary)
                        Text(kpi.subtitle)
                            .font(TBTypography.caption())
                            .foregroundStyle(TBColor.textSecondary)
                    }
                }
            }
        }
    }

    private var focusChart: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(title: "Focus hours", subtitle: "A simple chart that still feels polished")

                Chart(focusSeries) { point in
                    BarMark(
                        x: .value("Day", point.label),
                        y: .value("Minutes", point.minutes)
                    )
                    .foregroundStyle(TBColor.accentGradient)
                    .cornerRadius(8)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine().foregroundStyle(TBColor.border)
                        AxisTick().foregroundStyle(TBColor.border)
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label).foregroundStyle(TBColor.textSecondary)
                            }
                        }
                    }
                }
                .chartYScale(domain: 0...110)
            }
        }
    }

    private var categoryDonut: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(title: "Category split", subtitle: "A compact donut-style overview")

                HStack(alignment: .center, spacing: 18) {
                    DonutChart(slices: slices)
                        .frame(width: 170, height: 170)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(slices) { slice in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(slice.tint)
                                    .frame(width: 10, height: 10)
                                Text(slice.label)
                                    .font(TBTypography.caption(.semibold))
                                    .foregroundStyle(TBColor.textPrimary)
                                Spacer()
                                Text("\(Int(slice.value))%")
                                    .font(TBTypography.caption(.semibold))
                                    .foregroundStyle(TBColor.textSecondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private var goalProgressCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(title: "Goal progress", subtitle: "Compact check-in rows")
                ForEach(goalRows) { row in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(row.title)
                                    .font(TBTypography.body(.semibold))
                                    .foregroundStyle(TBColor.textPrimary)
                                Text(row.status)
                                    .font(TBTypography.caption())
                                    .foregroundStyle(row.tint)
                            }
                            Spacer()
                            Text("\(Int(row.progress * 100))%")
                                .font(TBTypography.caption(.semibold))
                                .foregroundStyle(TBColor.textSecondary)
                        }
                        ProgressView(value: row.progress)
                            .tint(row.tint)
                    }
                }
            }
        }
    }

    private var insightStack: some View {
        VStack(spacing: 12) {
            ForEach(insights) { insight in
                TBCard {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: insight.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(insight.tint)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(insight.tint.opacity(0.12)))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(insight.title)
                                .font(TBTypography.body(.semibold))
                                .foregroundStyle(TBColor.textPrimary)
                            Text(insight.body)
                                .font(TBTypography.caption())
                                .foregroundStyle(TBColor.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [TBColor.background, TBColor.surface.opacity(0.40), TBColor.background],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(TBTypography.title(.headline, weight: .semibold))
                .foregroundStyle(TBColor.textPrimary)
            Text(subtitle)
                .font(TBTypography.caption())
                .foregroundStyle(TBColor.textSecondary)
        }
    }
}

private struct DashKPI: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let tint: Color
}

private struct FocusPoint: Identifiable {
    let id = UUID()
    let label: String
    let minutes: Double
}

    private struct CategorySlice: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
        let tint: Color
    }

private struct GoalRow: Identifiable {
    let id = UUID()
    let title: String
    let progress: Double
    let status: String
    let tint: Color
}

private struct InsightCard: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let icon: String
    let tint: Color
}

private struct DonutChart: View {
    let slices: [CategorySlice]

    var body: some View {
        ZStack {
            Circle()
                .fill(TBColor.surfaceElevated)

            ForEach(Array(slices.enumerated()), id: \.offset) { index, slice in
                SegmentArc(start: startAngle(for: index), end: endAngle(for: index))
                    .stroke(slice.tint, style: StrokeStyle(lineWidth: 22, lineCap: .round))
                    .opacity(0.95)
            }

            Circle()
                .fill(TBColor.background)
                .frame(width: 86, height: 86)
                .overlay(
                    VStack(spacing: 4) {
                        Text("7h 42m")
                            .font(TBTypography.body(.semibold))
                            .foregroundStyle(TBColor.textPrimary)
                        Text("focus")
                            .font(TBTypography.caption())
                            .foregroundStyle(TBColor.textSecondary)
                    }
                )
        }
    }

    private func startAngle(for index: Int) -> Angle {
        let preceding = slices.prefix(index).map(\.value).reduce(0, +)
        return .degrees((preceding / 100) * 360 - 90)
    }

    private func endAngle(for index: Int) -> Angle {
        let preceding = slices.prefix(index + 1).map(\.value).reduce(0, +)
        return .degrees((preceding / 100) * 360 - 90)
    }
}

private struct SegmentArc: Shape {
    let start: Angle
    let end: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.addArc(
            center: center,
            radius: radius - 11,
            startAngle: start,
            endAngle: end,
            clockwise: false
        )
        return path
    }
}

#if DEBUG
struct DashView_Previews: PreviewProvider {
    static var previews: some View {
        DashView().preferredColorScheme(.dark)
    }
}
#endif
