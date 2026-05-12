import SwiftData
import SwiftUI

struct TrackView: View {
    @EnvironmentObject private var timerManager: TimerManager
    @Query(sort: \DailyPlan.createdAt, order: .reverse) private var plans: [DailyPlan]
    @Query private var lanes: [FocusLane]
    @Query(sort: \CycleLog.startTime, order: .reverse) private var cycleLogs: [CycleLog]
    @Query(sort: \Reflection.date, order: .reverse) private var reflections: [Reflection]

    var body: some View {
        let layout = SpatialDashboardMapper.map(
            dailyPlan: plans.first,
            lanes: lanes,
            cycleLogs: cycleLogs,
            reflection: reflections.first
        )

        TBScreen(title: "Dash", eyebrow: "Behavioral operating state") {
            DashHero(layout: layout, isRunning: timerManager.isRunning, elapsedMinutes: timerManager.elapsedMinutes)
            LaneInsightStrip(summaries: layout.laneSummaries)
            BehavioralAnalyticsPanel(layout: layout, cycleLogs: cycleLogs)
        }
    }
}

private struct DashHero: View {
    let layout: SpatialDashboardLayout
    let isRunning: Bool
    let elapsedMinutes: Int

    var body: some View {
        TBCard(isProminent: true) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(remainingMinutes)m")
                        .font(.system(size: 52, weight: .medium, design: .rounded).monospacedDigit())
                        .foregroundStyle(TBTheme.primaryText)
                    Text("REMAINING LOAD")
                        .font(.caption.weight(.semibold))
                        .tracking(1.6)
                        .foregroundStyle(TBTheme.secondaryText)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(layout.visualState.totalLoggedMinutes)m")
                        .font(.title3.monospacedDigit().weight(.semibold))
                        .foregroundStyle(TBTheme.cyan)
                    Text(isRunning ? "\(elapsedMinutes)m active" : "idle")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(TBTheme.secondaryText)
                }
            }

            ReverseActivityRingsView(segments: layout.ringSegments)
                .frame(height: 286)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

            HStack {
                TBMetric(value: "\(Int(layout.visualState.overallPercentComplete * 100))%", label: "closed")
                Spacer()
                TBMetric(value: "\(layout.laneSummaries.reduce(0) { $0 + $1.completedCycles })", label: "cycles")
                Spacer()
                TBMetric(value: layout.visualState.hasReflection ? "yes" : "no", label: "reflect")
            }
        }
    }

    private var remainingMinutes: Int {
        max(0, layout.visualState.totalTargetMinutes - layout.visualState.totalLoggedMinutes)
    }
}

private struct ReverseActivityRingsView: View {
    let segments: [SpatialRingSegment]

    var body: some View {
        ZStack {
            ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
                ReverseRing(
                    percentComplete: segment.percentComplete,
                    color: TBTheme.laneColor(segment.laneType),
                    lineWidth: 18 - CGFloat(index * 3)
                )
                .frame(width: 220 - CGFloat(index * 42), height: 220 - CGFloat(index * 42))
            }
        }
        .drawingGroup()
        .accessibilityLabel("Reverse activity rings")
    }
}

private struct ReverseRing: View {
    let percentComplete: Double
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.12), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            Circle()
                .trim(from: percentComplete, to: 1)
                .stroke(
                    AngularGradient(colors: [color.opacity(0.26), color, color.opacity(0.54)], center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.30), radius: 14)
        }
        .animation(TBMotion.depletion, value: percentComplete)
    }
}

private struct LaneInsightStrip: View {
    let summaries: [SpatialLaneSummary]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TBSectionHeader(title: "Lane Balance", subtitle: "Reverse rings show what remains")
            VStack(spacing: 10) {
                ForEach(summaries) { summary in
                    TBFieldSurface {
                        HStack(spacing: 12) {
                            TBIconView(kind: .lane(summary.laneType), color: TBTheme.laneColor(summary.laneType), lineWidth: 1.7)
                                .frame(width: 28, height: 28)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(summary.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(TBTheme.primaryText)
                                    .lineLimit(1)
                                Text("\(summary.loggedMinutes) / \(summary.targetMinutes)m")
                                    .font(.caption.monospacedDigit().weight(.medium))
                                    .foregroundStyle(TBTheme.secondaryText)
                            }
                            Spacer()
                            Text("\(max(0, summary.targetMinutes - summary.loggedMinutes))m")
                                .font(.headline.monospacedDigit().weight(.semibold))
                                .foregroundStyle(TBTheme.laneColor(summary.laneType))
                        }
                    }
                }
            }
        }
    }
}

private struct BehavioralAnalyticsPanel: View {
    let layout: SpatialDashboardLayout
    let cycleLogs: [CycleLog]

    var body: some View {
        TBCard {
            TBSectionHeader(title: "Behavioral Analytics", subtitle: "Low-noise local signal")

            VStack(spacing: 12) {
                analyticsRow("Most active lane", value: mostActiveLane)
                analyticsRow("Recent cycle", value: recentCycle)
                analyticsRow("Reflection state", value: layout.visualState.hasReflection ? "Closed" : "Open")
            }
        }
    }

    private func analyticsRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1.1)
                .foregroundStyle(TBTheme.tertiaryText)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TBTheme.primaryText)
                .multilineTextAlignment(.trailing)
        }
    }

    private var mostActiveLane: String {
        layout.laneSummaries.max(by: { $0.loggedMinutes < $1.loggedMinutes })?.laneType.title ?? "None"
    }

    private var recentCycle: String {
        guard let cycle = cycleLogs.first else { return "None" }
        return "\(cycle.durationMinutes)m \(cycle.laneType.title)"
    }
}
