import SwiftData
import SwiftUI

struct ActionsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var timerManager: TimerManager
    @Query private var lanes: [FocusLane]
    @Query(sort: \CycleLog.startTime, order: .reverse) private var cycleLogs: [CycleLog]

    var body: some View {
        TBScreen(title: "Execution", eyebrow: timerManager.isRunning ? "Cycle 04 - Deep Work" : "Behavioral OS v1.0") {
            ActionTorusHero(
                elapsedMinutes: timerManager.elapsedMinutes,
                progress: activeProgress,
                activeTaskTitle: timerManager.activeTaskTitle,
                activeLaneType: timerManager.activeLaneType,
                isRunning: timerManager.isRunning,
                canStart: !sortedLanes.isEmpty,
                action: togglePrimaryAction
            )

            HStack {
                Text("Current Intent")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(TBTheme.primaryText)
                Spacer()
                Text("\(activeLaneIndex) of \(max(sortedLanes.count, 1))")
                    .font(.caption.monospacedDigit().weight(.medium))
                    .foregroundStyle(TBTheme.tertiaryText)
            }
            .padding(.horizontal, 4)

            VStack(spacing: 12) {
                ForEach(sortedLanes) { lane in
                    ActionQueueRow(
                        lane: lane,
                        isActive: timerManager.activeLaneType == lane.type,
                        isRunning: timerManager.isRunning
                    ) {
                        timerManager.startSession(laneType: lane.type, taskTitle: lane.title)
                    }
                }
            }

            if !cycleLogs.isEmpty {
                RecentSignalStrip(cycleLogs: Array(cycleLogs.prefix(3)))
            }
        }
    }

    private var activeProgress: Double {
        guard
            timerManager.isRunning,
            let activeLaneType = timerManager.activeLaneType,
            let lane = sortedLanes.first(where: { $0.type == activeLaneType })
        else {
            return 0
        }
        return timerManager.progress(for: lane.targetMinutes)
    }

    private func togglePrimaryAction() {
        if timerManager.isRunning {
            timerManager.stopSession(modelContext: modelContext)
        } else if let firstLane = sortedLanes.first {
            timerManager.startSession(laneType: firstLane.type, taskTitle: firstLane.title)
        }
    }

    private var sortedLanes: [FocusLane] {
        lanes.sorted { $0.type.rawValue < $1.type.rawValue }
    }

    private var activeLaneIndex: Int {
        guard let activeLaneType = timerManager.activeLaneType else { return sortedLanes.isEmpty ? 0 : 1 }
        return (sortedLanes.firstIndex { $0.type == activeLaneType } ?? 0) + 1
    }
}

private struct ActionTorusHero: View {
    let elapsedMinutes: Int
    let progress: Double
    let activeTaskTitle: String?
    let activeLaneType: FocusLaneType?
    let isRunning: Bool
    let canStart: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            ActionTorusGlyph(
                progress: progress,
                elapsedMinutes: elapsedMinutes,
                isRunning: isRunning,
                color: laneColor
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .padding(.horizontal, 8)

            TBCard(isProminent: true) {
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 7) {
                        if let activeLaneType {
                            LaneBadge(laneType: activeLaneType)
                        }
                        Text(activeTaskTitle ?? "Choose a lane and begin the next calm cycle.")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(TBTheme.primaryText)
                            .lineLimit(2)
                        Text(isRunning ? "Bound to the active timer" : "The torus holds the day’s next action.")
                            .font(.subheadline)
                            .foregroundStyle(TBTheme.secondaryText)
                    }
                    Spacer()
                    Button(isRunning ? "Stop" : "Start", action: action)
                        .buttonStyle(TBPrimaryButtonStyle())
                        .disabled(!isRunning && !canStart)
                        .accessibilityLabel(isRunning ? "Stop active timer" : "Start first action")
                }
            }
        }
    }

    private var laneColor: Color {
        activeLaneType.map { TBTheme.laneColor($0) } ?? TBTheme.cyan
    }
}

private struct ActionTorusGlyph: View {
    let progress: Double
    let elapsedMinutes: Int
    let isRunning: Bool
    let color: Color

    private var remainingMinutes: Int {
        max(0, 45 - elapsedMinutes)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(TBTheme.indigo.opacity(0.08))
                .blur(radius: 26)
                .scaleEffect(0.82)

            Canvas { context, size in
                let rect = CGRect(origin: .zero, size: size)
                let center = CGPoint(x: rect.midX, y: rect.midY)
                let base = min(size.width, size.height)
                let outerRadius = base * 0.405
                let ringRadius = base * 0.305
                let lineWidth = base * 0.058

                var outer = Path()
                outer.addEllipse(in: CGRect(
                    x: center.x - outerRadius,
                    y: center.y - outerRadius,
                    width: outerRadius * 2,
                    height: outerRadius * 2
                ))
                context.stroke(outer, with: .color(.white.opacity(0.035)), lineWidth: 2)

                var inner = Path()
                inner.addEllipse(in: CGRect(
                    x: center.x - ringRadius,
                    y: center.y - ringRadius,
                    width: ringRadius * 2,
                    height: ringRadius * 2
                ))
                context.stroke(inner, with: .color(.white.opacity(0.055)), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

                var active = Path()
                active.addArc(
                    center: center,
                    radius: ringRadius,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(-90 + (360 * max(0.04, 1 - progress))),
                    clockwise: false
                )
                context.stroke(active, with: .color(color.opacity(0.18)), style: StrokeStyle(lineWidth: lineWidth * 1.85, lineCap: .round))
                context.stroke(
                    active,
                    with: .linearGradient(
                        Gradient(colors: [TBTheme.cyan, TBTheme.indigo]),
                        startPoint: CGPoint(x: rect.minX, y: rect.minY),
                        endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

                for angle in stride(from: -90.0, through: 180.0, by: 90.0) {
                    let radians = angle * .pi / 180
                    let point = CGPoint(
                        x: center.x + CGFloat(cos(radians)) * outerRadius,
                        y: center.y + CGFloat(sin(radians)) * outerRadius
                    )
                    let dotRect = CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4)
                    context.fill(Path(ellipseIn: dotRect), with: .color(.white.opacity(0.22)))
                }
            }
            .rotationEffect(.degrees(0))
            .animation(TBMotion.depletion, value: progress)

            VStack(spacing: 7) {
                Text(isRunning ? "IN FLOW" : "READY")
                    .font(.caption.weight(.medium))
                    .tracking(2.1)
                    .foregroundStyle(isRunning ? TBTheme.cyan : TBTheme.secondaryText)
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(isRunning ? "\(remainingMinutes)" : "45")
                        .font(.system(size: 48, weight: .light, design: .default).monospacedDigit())
                        .foregroundStyle(TBTheme.primaryText)
                    Text("m")
                        .font(.title3.weight(.light))
                        .foregroundStyle(TBTheme.tertiaryText)
                }
                Text("Remaining")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(TBTheme.tertiaryText)
            }
        }
    }
}

private struct ActionQueueRow: View {
    let lane: FocusLane
    let isActive: Bool
    let isRunning: Bool
    let start: () -> Void

    var body: some View {
        TBFieldSurface {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(TBTheme.laneColor(lane.type).opacity(0.25), lineWidth: 1)
                    if isActive {
                        Circle()
                            .fill(TBTheme.laneColor(lane.type))
                            .frame(width: 11, height: 11)
                    }
                }
                .frame(width: 22, height: 22)

                VStack(alignment: .leading, spacing: 6) {
                    Text(lane.title)
                        .font(.subheadline.weight(isActive ? .medium : .light))
                        .foregroundStyle(TBTheme.primaryText)
                        .lineLimit(2)
                    if isActive {
                        Text("Map out core data structures for visionOS integration.")
                            .font(.caption.weight(.light))
                            .foregroundStyle(TBTheme.secondaryText)
                            .lineLimit(2)
                    }
                }
                Spacer()
                Text("\(lane.targetMinutes)m")
                    .font(.caption.monospacedDigit().weight(.medium))
                    .foregroundStyle(isActive ? TBTheme.secondaryText : TBTheme.tertiaryText)
            }
        }
        .opacity(isActive ? 1 : 0.62)
        .overlay(alignment: .leading) {
            if isActive {
                Rectangle()
                    .fill(TBTheme.laneColor(lane.type))
                    .frame(width: 3)
                }
            }
        .onTapGesture {
            guard !isRunning else { return }
            start()
        }
    }
}

private struct RecentSignalStrip: View {
    let cycleLogs: [CycleLog]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TBSectionHeader(title: "Recent Signals", subtitle: "Last completed cycles")
            HStack(spacing: 10) {
                ForEach(cycleLogs) { log in
                    VStack(alignment: .leading, spacing: 7) {
                        TBIconView(kind: .lane(log.laneType), color: TBTheme.laneColor(log.laneType), lineWidth: 1.5)
                            .frame(width: 18, height: 18)
                        Text("\(log.durationMinutes)m")
                            .font(.headline.monospacedDigit().weight(.semibold))
                            .foregroundStyle(TBTheme.primaryText)
                        Text(log.taskTitle)
                            .font(.caption)
                            .foregroundStyle(TBTheme.secondaryText)
                            .lineLimit(1)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(TBTheme.field.opacity(0.46), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(TBTheme.stroke.opacity(0.65), lineWidth: 1)
                    )
                }
            }
        }
    }
}
