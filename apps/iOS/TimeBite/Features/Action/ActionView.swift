import Combine
import SwiftUI

struct ActionView: View {
    @State private var action: ActionItem
    @State private var queue: [ActionQueueItem]
    @State private var labels: [WorkLabel]
    @State private var isRunning: Bool
    @State private var elapsedSeconds: Int
    @State private var now = Date()
    @State private var showingWorkLabels = false

    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let workLabelsStorageKey = "timebite.workLabels"

    init(
        action: ActionItem = .mock,
        queue: [ActionQueueItem] = ActionQueueItem.samples,
        labels: [WorkLabel] = WorkLabel.samples,
        isRunning: Bool = false,
        elapsedSeconds: Int? = nil
    ) {
        _action = State(initialValue: action)
        _queue = State(initialValue: queue)
        _labels = State(initialValue: labels)
        _isRunning = State(initialValue: isRunning)
        _elapsedSeconds = State(initialValue: elapsedSeconds ?? action.elapsedMinutes * 60)
    }

    private var hasActiveAction: Bool {
        action.targetMinutes > 0 && action.title != ActionItem.empty.title
    }

    private var currentActionProgress: Double {
        guard action.targetMinutes > 0 else { return 0 }
        let liveProgress = Double(elapsedSeconds) / Double(action.targetMinutes * 60)
        return min(max(liveProgress, action.progress), 1)
    }

    private var upcomingActions: [ActionQueueItem] {
        queue
            .filter { $0.estimatedDurationMinutes > 0 }
            .sorted { $0.scheduledStart < $1.scheduledStart }
    }

    private var dailySlices: [DailyActionSlice] {
        let current: [DailyActionSlice]
        if hasActiveAction {
            current = makeDailySlices(
                id: action.id,
                title: action.title,
                scheduledStart: action.scheduledStart,
                plannedMinutes: Double(action.targetMinutes),
                consumedMinutes: min(Double(elapsedSeconds) / 60, Double(action.targetMinutes)),
                color: action.accent
            )
        } else {
            current = []
        }

        let upcoming = upcomingActions.flatMap { item in
            makeDailySlices(
                id: item.id,
                title: item.title,
                scheduledStart: item.scheduledStart,
                plannedMinutes: Double(item.estimatedDurationMinutes),
                consumedMinutes: Double(item.estimatedDurationMinutes) * item.progress,
                color: item.color
            )
        }

        return current + upcoming
    }

    private var dailyTotals: ActionRingTotals {
        totals(for: dailySlices)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    liveRingCard
                    hourglassTimerCard
                    upcomingActionsCard
                    halfDayRingsCard
                    dailyTotalCard
                }
                .padding(16)
            }
            .background(background)
            .navigationTitle("Action")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingWorkLabels = true
                    } label: {
                        Label("Work Labels", systemImage: "tag")
                            .font(TBTypography.caption(.semibold))
                    }
                    .foregroundStyle(TBColor.primaryAccent)
                }
            }
        }
        .sheet(isPresented: $showingWorkLabels) {
            WorkLabelsView(labels: $labels)
                .preferredColorScheme(.dark)
        }
        .onReceive(tick) { value in
            now = value
            guard hasActiveAction, isRunning else { return }

            let maxSeconds = action.targetMinutes * 60
            if elapsedSeconds < maxSeconds {
                elapsedSeconds += 1
            } else {
                isRunning = false
            }
        }
        .onAppear(perform: loadWorkLabels)
        .onChange(of: labels) { _, newLabels in
            guard let data = try? JSONEncoder().encode(newLabels) else { return }
            UserDefaults.standard.set(data, forKey: workLabelsStorageKey)
        }
        .onChange(of: hasActiveAction) { _, isActive in
            if !isActive {
                isRunning = false
            }
        }
    }

    private var liveRingCard: some View {
        TBCard {
            VStack(alignment: .center, spacing: 18) {
                VStack(alignment: .center, spacing: 8) {
                    Text("LIVE ACTION")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(TBColor.textSecondary)

                    if hasActiveAction {
                        TextField("Action title", text: $action.title)
                            .font(TBTypography.title(.headline, weight: .semibold))
                            .foregroundStyle(TBColor.textPrimary)
                            .multilineTextAlignment(.center)
                            .textInputAutocapitalization(.sentences)
                            .lineLimit(2)
                    } else {
                        Text("No active action")
                            .font(TBTypography.title(.headline, weight: .semibold))
                            .foregroundStyle(TBColor.textPrimary)
                    }
                }

                ActionProgressRing(
                    progress: currentActionProgress,
                    tint: action.accent,
                    size: 218,
                    lineWidth: 20
                ) {
                    VStack(spacing: 6) {
                        Text("\(Int((currentActionProgress * 100).rounded()))%")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(TBColor.textPrimary)
                            .minimumScaleFactor(0.72)
                        Text(hasActiveAction ? "in progress" : "idle")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(TBColor.textSecondary)
                    }
                }
                .accessibilityLabel(liveRingAccessibilityLabel)

                HStack(spacing: 8) {
                    if hasActiveAction {
                        Menu {
                            ForEach(labels) { workLabel in
                                Button(workLabel.displayName) {
                                    action.labelID = workLabel.id
                                }
                            }
                        } label: {
                            workLabelBox(label(for: action.labelID))
                        }

                        Text(action.category)
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(TBColor.textSecondary)
                            .lineLimit(1)
                    } else {
                        Text("Select an action to start the ring.")
                            .font(TBTypography.caption())
                            .foregroundStyle(TBColor.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity)

                Text(action.note)
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var hourglassTimerCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(hasActiveAction ? action.accent : TBColor.textSecondary)
                        .frame(width: 42, height: 42)
                        .background(
                            Circle()
                                .fill((hasActiveAction ? action.accent : TBColor.textSecondary).opacity(0.12))
                                .overlay(Circle().stroke((hasActiveAction ? action.accent : TBColor.textSecondary).opacity(0.24), lineWidth: 1))
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hourglass timer")
                            .font(TBTypography.title(.headline, weight: .semibold))
                            .foregroundStyle(TBColor.textPrimary)
                        Text(hasActiveAction ? "\(consumedTimeText) elapsed · \(remainingTimeText) remaining" : "No active timer")
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(TBColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 10) {
                    timerButton(label: isRunning ? "Pause" : "Start", systemName: isRunning ? "pause.fill" : "play.fill") {
                        guard hasActiveAction else { return }
                        isRunning.toggle()
                    }
                    .disabled(!hasActiveAction)

                    timerButton(label: "Restart", systemName: "arrow.counterclockwise") {
                        isRunning = false
                        elapsedSeconds = action.elapsedMinutes * 60
                    }
                    .disabled(!hasActiveAction)

                    timerButton(label: "Labels", systemName: "tag") {
                        showingWorkLabels = true
                    }
                }

                VStack(spacing: 7) {
                    timeReadout(title: "Time Now", value: clockText)
                    timeReadout(title: "Est. Time Complete", value: estimatedCompletionText)
                }
            }
        }
    }

    private var upcomingActionsCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader(title: "Upcoming actions", subtitle: "Next scheduled rings")

                if upcomingActions.isEmpty {
                    emptyState("No upcoming actions scheduled.")
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(upcomingActions) { scheduledItem in
                            if let index = queue.firstIndex(where: { $0.id == scheduledItem.id }) {
                                upcomingActionRow(item: $queue[index])
                            }
                        }
                    }
                }
            }
        }
    }

    private func upcomingActionRow(item: Binding<ActionQueueItem>) -> some View {
        HStack(alignment: .center, spacing: 12) {
            ActionProgressRing(
                progress: item.wrappedValue.progress,
                tint: item.wrappedValue.color,
                size: 46,
                lineWidth: 5
            ) {
                if item.wrappedValue.isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(item.wrappedValue.color)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(item.wrappedValue.title)
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textPrimary)
                        .lineLimit(2)
                    Spacer(minLength: 0)
                    Text("\(scheduledTimeText(item.wrappedValue.scheduledStart))")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(TBColor.textSecondary)
                }

                Text("\(durationText(item.wrappedValue.estimatedDurationMinutes)) · \(item.wrappedValue.status) · \(item.wrappedValue.dueText)")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(TBColor.textSecondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Menu {
                        ForEach(labels) { workLabel in
                            Button(workLabel.displayName) {
                                item.wrappedValue.labelID = workLabel.id
                            }
                        }
                    } label: {
                        workLabelBox(label(for: item.wrappedValue.labelID))
                    }

                    Text(item.wrappedValue.epic)
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .foregroundStyle(TBColor.textSecondary)
                        .lineLimit(1)

                    Text(item.wrappedValue.repoName)
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundStyle(TBColor.textSecondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(TBColor.surfaceElevated.opacity(0.70))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(TBColor.border, lineWidth: 1))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.wrappedValue.title), starts \(scheduledTimeText(item.wrappedValue.scheduledStart)), \(durationText(item.wrappedValue.estimatedDurationMinutes)), \(Int(item.wrappedValue.progress * 100)) percent complete")
    }

    private var halfDayRingsCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 18) {
                sectionHeader(title: "Half-day rings", subtitle: "Scheduled action time by 12-hour window")

                VStack(spacing: 18) {
                    ForEach(ActionHalfDay.allCases, id: \.self) { halfDay in
                        let slices = dailySlices.filter { $0.halfDay == halfDay }
                        HalfDayRingView(
                            halfDay: halfDay,
                            slices: slices,
                            totals: totals(for: slices)
                        )
                    }
                }

                HStack(spacing: 14) {
                    Label("Planned", systemImage: "circle")
                    Label("Completed", systemImage: "circle.fill")
                }
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityHidden(true)
            }
        }
    }

    private var dailyTotalCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 18) {
                sectionHeader(title: "Daily total", subtitle: "Weighted result across AM and PM")

                ActionProgressRing(
                    progress: dailyTotals.progress,
                    tint: TBColor.primaryAccent,
                    size: 184,
                    lineWidth: 18
                ) {
                    VStack(spacing: 5) {
                        Text("\(Int((dailyTotals.progress * 100).rounded()))%")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(TBColor.textPrimary)
                        Text(durationText(Int(dailyTotals.completedMinutes.rounded())))
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(TBColor.primaryAccent)
                        Text("completed")
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(TBColor.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 10) {
                    dailyMetric("Planned", value: durationText(Int(dailyTotals.plannedMinutes.rounded())))
                    dailyMetric("Completed", value: durationText(Int(dailyTotals.completedMinutes.rounded())))
                    dailyMetric("Remaining", value: durationText(Int(max(dailyTotals.plannedMinutes - dailyTotals.completedMinutes, 0).rounded())))
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Daily total, \(Int((dailyTotals.progress * 100).rounded())) percent complete, \(durationText(Int(dailyTotals.completedMinutes.rounded()))) completed of \(durationText(Int(dailyTotals.plannedMinutes.rounded()))) planned")
        }
    }

    private var background: some View {
        ZStack {
            TBColor.background
            RadialGradient(
                colors: [action.accent.opacity(0.22), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 420
            )
            .blendMode(.screen)
            LinearGradient(
                colors: [TBColor.background, TBColor.surface.opacity(0.4), TBColor.background],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    private var liveRingAccessibilityLabel: String {
        guard hasActiveAction else { return "No active action" }
        return "\(action.title), \(Int((currentActionProgress * 100).rounded())) percent complete, \(consumedTimeText) elapsed"
    }

    private var consumedTimeText: String {
        clockDurationText(elapsedSeconds)
    }

    private var remainingTimeText: String {
        let remaining = max(action.targetMinutes * 60 - elapsedSeconds, 0)
        return clockDurationText(remaining)
    }

    private func clockDurationText(_ seconds: Int) -> String {
        let safeSeconds = max(seconds, 0)
        let hours = safeSeconds / 3600
        let minutes = (safeSeconds % 3600) / 60
        let seconds = safeSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }

        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var clockText: String {
        let time = now.formatted(date: .omitted, time: .shortened)
        let zone = TimeZone.current.abbreviation() ?? ""
        return zone.isEmpty ? time : "\(time) \(zone)"
    }

    private var estimatedCompletionText: String {
        guard hasActiveAction else { return "Not scheduled" }
        let remainingSeconds = max(action.targetMinutes * 60 - elapsedSeconds, 0)
        let completion = now.addingTimeInterval(TimeInterval(remainingSeconds))
        let time = completion.formatted(date: .omitted, time: .shortened)
        let zone = TimeZone.current.abbreviation() ?? ""
        return zone.isEmpty ? time : "\(time) \(zone)"
    }

    private func makeDailySlices(
        id: UUID,
        title: String,
        scheduledStart: Date,
        plannedMinutes: Double,
        consumedMinutes: Double,
        color: Color
    ) -> [DailyActionSlice] {
        let components = Calendar.current.dateComponents([.hour, .minute], from: scheduledStart)
        var startMinute = Double((components.hour ?? 0) * 60 + (components.minute ?? 0))
        var remainingPlanned = min(max(plannedMinutes, 0), 24 * 60)
        var remainingConsumed = min(max(consumedMinutes, 0), remainingPlanned)
        var segmentIndex = 0
        var slices: [DailyActionSlice] = []

        while remainingPlanned > 0 {
            if startMinute >= 24 * 60 {
                startMinute = startMinute.truncatingRemainder(dividingBy: 24 * 60)
            }

            let halfDay: ActionHalfDay = startMinute < 12 * 60 ? .morning : .evening
            let boundary = halfDay == .morning ? Double(12 * 60) : Double(24 * 60)
            let segmentPlanned = min(remainingPlanned, boundary - startMinute)
            let segmentConsumed = min(remainingConsumed, segmentPlanned)

            slices.append(
                DailyActionSlice(
                    id: "\(id.uuidString)-\(segmentIndex)",
                    title: title,
                    halfDay: halfDay,
                    minuteInHalfDay: startMinute.truncatingRemainder(dividingBy: 12 * 60),
                    plannedMinutes: segmentPlanned,
                    consumedMinutes: segmentConsumed,
                    color: color
                )
            )

            startMinute += segmentPlanned
            remainingPlanned -= segmentPlanned
            remainingConsumed -= segmentConsumed
            segmentIndex += 1
        }

        return slices
    }

    private func totals(for slices: [DailyActionSlice]) -> ActionRingTotals {
        ActionRingTotals(
            plannedMinutes: slices.reduce(0) { $0 + $1.plannedMinutes },
            completedMinutes: slices.reduce(0) { $0 + $1.consumedMinutes }
        )
    }

    private func label(for id: UUID?) -> WorkLabel? {
        labels.first { $0.id == id }
    }

    private func loadWorkLabels() {
        guard
            let data = UserDefaults.standard.data(forKey: workLabelsStorageKey),
            let storedLabels = try? JSONDecoder().decode([WorkLabel].self, from: data),
            !storedLabels.isEmpty
        else { return }
        labels = storedLabels
    }

    private func durationText(_ totalMinutes: Int) -> String {
        let minutes = max(totalMinutes, 0)
        guard minutes >= 60 else { return "\(minutes) min" }

        let hours = minutes / 60
        let remainder = minutes % 60
        return remainder == 0 ? "\(hours) hr" : "\(hours) hr \(remainder) min"
    }

    private func scheduledTimeText(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    private func timeReadout(title: String, value: String) -> some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(TBColor.textSecondary)
            Text(value)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(TBColor.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(TBTypography.title(.headline, weight: .semibold))
                .foregroundStyle(TBColor.textPrimary)
            Text(subtitle)
                .font(TBTypography.caption())
                .foregroundStyle(TBColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func emptyState(_ text: String) -> some View {
        Text(text)
            .font(TBTypography.caption())
            .foregroundStyle(TBColor.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(TBColor.surfaceElevated.opacity(0.50))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(TBColor.border, lineWidth: 1))
            )
    }

    private func dailyMetric(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textPrimary)
                .minimumScaleFactor(0.78)
                .lineLimit(1)
            Text(title)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(TBColor.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(TBColor.surfaceElevated.opacity(0.64))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(TBColor.border, lineWidth: 1))
        )
    }

    @ViewBuilder
    private func workLabelBox(_ label: WorkLabel?) -> some View {
        if let label {
            Text(label.displayName)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(label.color)
                .lineLimit(1)
                .padding(.vertical, 3)
                .padding(.horizontal, 5)
                .background(label.color.opacity(0.12))
                .overlay(Rectangle().stroke(label.color.opacity(0.38), lineWidth: 1))
        } else {
            Text("+ label")
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(TBColor.textSecondary)
                .padding(.vertical, 3)
                .padding(.horizontal, 5)
                .overlay(Rectangle().stroke(TBColor.border, lineWidth: 1))
        }
    }

    private func timerButton(label: String, systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemName)
                    .font(.system(size: 16, weight: .semibold))
                Text(label)
                    .font(TBTypography.caption(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(TBColor.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(TBColor.surfaceElevated)
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(TBColor.border, lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }
}

private struct ActionProgressRing<Center: View>: View {
    let progress: Double
    let tint: Color
    let size: CGFloat
    let lineWidth: CGFloat
    @ViewBuilder let center: () -> Center
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .stroke(TBColor.surfaceElevated, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    tint,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: tint.opacity(0.24), radius: 10)

            center()
        }
        .frame(width: size, height: size)
        .animation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.86), value: progress)
    }
}

private struct HalfDayRingView: View {
    let halfDay: ActionHalfDay
    let slices: [DailyActionSlice]
    let totals: ActionRingTotals
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(halfDay.rangeTitle)
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textPrimary)
                    Text("\(durationText(Int(totals.completedMinutes.rounded()))) completed of \(durationText(Int(totals.plannedMinutes.rounded())))")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(TBColor.textSecondary)
                }

                Spacer()

                Text("\(Int((totals.progress * 100).rounded()))%")
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.primaryAccent)
            }

            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(TBColor.surfaceElevated, lineWidth: 16)

                    ForEach(0..<12, id: \.self) { hour in
                        Capsule(style: .continuous)
                            .fill(TBColor.textSecondary.opacity(hour % 3 == 0 ? 0.62 : 0.24))
                            .frame(width: 2, height: hour % 3 == 0 ? 8 : 5)
                            .offset(y: -62)
                            .rotationEffect(.degrees(Double(hour) * 30))
                    }

                    ForEach(slices) { slice in
                        Circle()
                            .trim(from: slice.startFraction, to: slice.plannedEndFraction)
                            .stroke(
                                slice.color.opacity(0.22),
                                style: StrokeStyle(lineWidth: 16, lineCap: .butt)
                            )
                            .rotationEffect(.degrees(-90))

                        Circle()
                            .trim(from: slice.startFraction, to: slice.completedEndFraction)
                            .stroke(
                                slice.color,
                                style: StrokeStyle(lineWidth: 16, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .shadow(color: slice.color.opacity(0.20), radius: 6)
                    }

                    VStack(spacing: 3) {
                        Text(halfDay.shortTitle)
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                            .foregroundStyle(TBColor.textPrimary)
                        Text(totals.plannedMinutes > 0 ? durationText(Int(totals.completedMinutes.rounded())) : "Empty")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(totals.plannedMinutes > 0 ? TBColor.primaryAccent : TBColor.textSecondary)
                            .minimumScaleFactor(0.72)
                            .lineLimit(1)
                    }
                }
                .frame(width: 142, height: 142)
                .animation(reduceMotion ? nil : .linear(duration: 0.25), value: totals.completedMinutes)

                VStack(alignment: .leading, spacing: 8) {
                    if slices.isEmpty {
                        Text("No actions scheduled in this window.")
                            .font(TBTypography.caption())
                            .foregroundStyle(TBColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        ForEach(slices.prefix(4)) { slice in
                            HStack(spacing: 7) {
                                Circle()
                                    .fill(slice.color)
                                    .frame(width: 7, height: 7)
                                Text(slice.title)
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .foregroundStyle(TBColor.textPrimary)
                                    .lineLimit(1)
                                Spacer(minLength: 0)
                                Text(durationText(Int(slice.consumedMinutes.rounded())))
                                    .font(.system(size: 9, weight: .medium, design: .rounded))
                                    .foregroundStyle(TBColor.textSecondary)
                                    .lineLimit(1)
                            }
                        }

                        if slices.count > 4 {
                            Text("+ \(slices.count - 4) more")
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                .foregroundStyle(TBColor.textSecondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(TBColor.surfaceElevated.opacity(0.54))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(TBColor.border, lineWidth: 1))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(halfDay.accessibilityLabel(for: slices, totals: totals))
    }

    private func durationText(_ totalMinutes: Int) -> String {
        let minutes = max(totalMinutes, 0)
        guard minutes >= 60 else { return "\(minutes) min" }

        let hours = minutes / 60
        let remainder = minutes % 60
        return remainder == 0 ? "\(hours) hr" : "\(hours) hr \(remainder) min"
    }
}

private enum ActionHalfDay: String, CaseIterable {
    case morning
    case evening

    var shortTitle: String { self == .morning ? "AM" : "PM" }
    var rangeTitle: String { self == .morning ? "12:00 AM-12:00 PM" : "12:00 PM-12:00 AM" }

    func accessibilityLabel(for slices: [DailyActionSlice], totals: ActionRingTotals) -> String {
        let actions = slices
            .filter { $0.consumedMinutes > 0 }
            .map { "\($0.title), \(Int($0.consumedMinutes.rounded())) minutes" }
            .joined(separator: ", ")
        let detail = actions.isEmpty ? "No completed time" : actions
        return "\(rangeTitle), \(Int((totals.progress * 100).rounded())) percent complete, \(Int(totals.completedMinutes.rounded())) of \(Int(totals.plannedMinutes.rounded())) minutes. \(detail)."
    }
}

private struct DailyActionSlice: Identifiable {
    let id: String
    let title: String
    let halfDay: ActionHalfDay
    let minuteInHalfDay: Double
    let plannedMinutes: Double
    let consumedMinutes: Double
    let color: Color

    var startFraction: Double {
        min(max(minuteInHalfDay / 720, 0), 1)
    }

    var plannedEndFraction: Double {
        min(max((minuteInHalfDay + plannedMinutes) / 720, startFraction), 1)
    }

    var completedEndFraction: Double {
        min(max((minuteInHalfDay + min(consumedMinutes, plannedMinutes)) / 720, startFraction), plannedEndFraction)
    }
}

private struct ActionRingTotals: Equatable {
    let plannedMinutes: Double
    let completedMinutes: Double

    var progress: Double {
        guard plannedMinutes > 0 else { return 0 }
        return min(max(completedMinutes / plannedMinutes, 0), 1)
    }
}

private struct WorkLabelsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var labels: [WorkLabel]
    @State private var draftName = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach($labels) { $label in
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(label.color)
                                .frame(width: 10, height: 32)
                            TextField("project", text: $label.name)
                                .textInputAutocapitalization(.never)
                        }
                    }
                    .onDelete { labels.remove(atOffsets: $0) }
                } header: {
                    Text("User-defined project tags")
                } footer: {
                    Text("Work Labels power server-aggregated Track rollups. They are separate from Goal Life Areas.")
                }

                Section("Add label") {
                    HStack {
                        TextField("#research", text: $draftName)
                            .textInputAutocapitalization(.never)
                        Button("Add") {
                            let cleanName = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !cleanName.isEmpty else { return }
                            labels.append(.init(name: cleanName, colorIndex: labels.count))
                            draftName = ""
                        }
                        .disabled(draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(TBColor.background)
            .navigationTitle("Work Labels")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#if DEBUG
struct ActionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ActionView(action: .empty, queue: [], labels: WorkLabel.samples)
                .previewDisplayName("No active action")

            ActionView(
                action: .mock,
                queue: ActionQueueItem.samples,
                labels: WorkLabel.samples,
                isRunning: true,
                elapsedSeconds: 38 * 60
            )
            .previewDisplayName("Live action with hourglass")

            ActionView(
                action: ActionPreviewData.activeCrossingNoon,
                queue: ActionPreviewData.partialDayQueue,
                labels: WorkLabel.samples,
                elapsedSeconds: 42 * 60
            )
            .previewDisplayName("Partial AM and PM rings")

            ActionView(
                action: ActionPreviewData.completedAction,
                queue: ActionPreviewData.completedDayQueue,
                labels: WorkLabel.samples,
                elapsedSeconds: 60 * 60
            )
            .previewDisplayName("Fully completed day")
        }
        .preferredColorScheme(.dark)
    }
}

private enum ActionPreviewData {
    static let activeCrossingNoon = ActionItem(
        title: "Bridge mobile task data",
        targetMinutes: 90,
        elapsedMinutes: 42,
        scheduledStart: previewDate(hour: 11, minute: 30),
        serverPercentComplete: 0.34,
        streakDays: 4,
        category: "Build",
        labelID: WorkLabel.samples[0].id,
        accent: TBColor.primaryAccent,
        note: "Spans noon so the AM and PM rings divide the scheduled block."
    )

    static let completedAction = ActionItem(
        title: "Complete release pass",
        targetMinutes: 60,
        elapsedMinutes: 60,
        scheduledStart: previewDate(hour: 8),
        serverPercentComplete: 1,
        streakDays: 9,
        category: "Release",
        labelID: WorkLabel.samples[3].id,
        accent: TBColor.primaryAccent,
        note: "All scheduled action time has been completed."
    )

    static let partialDayQueue: [ActionQueueItem] = [
        .init(title: "Morning compile pass", estimatedDurationMinutes: 75, scheduledStart: previewDate(hour: 9), serverPercentComplete: 0.66, colorIndex: 1, labelID: WorkLabel.samples[0].id, epic: "iOS QA", status: "In Progress", dueText: "Today", repoName: "timebite-platform"),
        .init(title: "Noon handoff review", estimatedDurationMinutes: 80, scheduledStart: previewDate(hour: 11, minute: 40), serverPercentComplete: 0.25, colorIndex: 2, labelID: WorkLabel.samples[2].id, epic: "iOS QA", dueText: "Today", repoName: "shared"),
        .init(title: "Afternoon polish", estimatedDurationMinutes: 120, scheduledStart: previewDate(hour: 14), serverPercentComplete: 0.30, colorIndex: 3, labelID: WorkLabel.samples[1].id, epic: "Design", dueText: "Today", repoName: "timebite-platform")
    ]

    static let completedDayQueue: [ActionQueueItem] = [
        .init(title: "Morning implementation", estimatedDurationMinutes: 120, scheduledStart: previewDate(hour: 9), serverPercentComplete: 1, colorIndex: 1, labelID: WorkLabel.samples[0].id, epic: "Build", status: "Done", dueText: "Today", repoName: "timebite-platform"),
        .init(title: "Cross-noon QA", estimatedDurationMinutes: 90, scheduledStart: previewDate(hour: 11, minute: 30), serverPercentComplete: 1, colorIndex: 2, labelID: WorkLabel.samples[2].id, epic: "QA", status: "Done", dueText: "Today", repoName: "timebite-platform"),
        .init(title: "Afternoon release notes", estimatedDurationMinutes: 75, scheduledStart: previewDate(hour: 15), serverPercentComplete: 1, colorIndex: 3, labelID: WorkLabel.samples[3].id, epic: "Release", status: "Done", dueText: "Today", repoName: "shared")
    ]

    private static func previewDate(hour: Int, minute: Int = 0) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: .now) ?? .now
    }
}
#endif
