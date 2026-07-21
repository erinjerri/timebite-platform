import Combine
import SwiftUI

struct ActionView: View {
    @State private var action = ActionItem.empty
    @State private var queue: [ActionQueueItem] = []
    @State private var labels: [WorkLabel] = []
    @State private var isRunning = false
    @State private var elapsedSeconds = 0
    @State private var now = Date()
    @State private var showingWorkLabels = false

    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let workLabelsStorageKey = "timebite.workLabels"

    private var visibleQueue: [ActionQueueItem] {
        let realItems = Array(queue.prefix(6))
        guard realItems.count < 6 else { return realItems }
        return realItems + ActionQueueItem.sixSlotPlaceholders.dropFirst(realItems.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    todaysActionCard
                    currentTaskCard
                    halfDayRingsCard
                }
                .padding(16)
                .padding(.bottom, 102)
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
            guard isRunning else { return }
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
    }

    private var todaysActionCard: some View {
        TBCard {
            heroContent
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var currentTaskCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 14) {
                currentTaskSummary

                HStack {
                    Text("UPCOMING")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .tracking(1.05)
                        .foregroundStyle(TBColor.textSecondary)

                    Spacer()

                    Text("6 slots")
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textSecondary)
                }

                LazyVStack(spacing: 10) {
                    ForEach(visibleQueue) { item in
                        if let index = queue.firstIndex(where: { $0.id == item.id }) {
                            queueRow(item: $queue[index])
                        } else {
                            queuePlaceholderRow(item)
                        }
                    }
                }
            }
        }
    }

    private var currentTaskSummary: some View {
        HStack(alignment: .top, spacing: 12) {
            currentTaskProgress

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text("CURRENT TASK")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .tracking(1.05)
                        .foregroundStyle(TBColor.textSecondary)

                    Spacer()

                    Text("\(durationText(Int(Double(elapsedSeconds) / 60))) / \(durationText(action.targetMinutes))")
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.primaryAccent)
                }

                Text(action.title)
                    .font(TBTypography.title(.headline, weight: .semibold))
                    .foregroundStyle(TBColor.textPrimary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                Text(action.note)
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Menu {
                        ForEach(labels) { workLabel in
                            Button(workLabel.displayName) {
                                action.labelID = workLabel.id
                            }
                        }
                    } label: {
                        workLabelBox(label(for: action.labelID))
                    }

                    Text("\(scheduledTimeText(action.scheduledStart)) · \(durationText(action.targetMinutes))")
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textSecondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(action.accent.opacity(0.14))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(action.accent.opacity(0.45), lineWidth: 1)
                )
        )
    }

    private var currentTaskProgress: some View {
        ZStack {
            Circle()
                .stroke(action.accent.opacity(0.18), lineWidth: 4)
            Circle()
                .trim(from: 0, to: currentActionProgress)
                .stroke(action.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 30, height: 30)
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: currentActionProgress)
        .accessibilityHidden(true)
    }

    private func queueRow(item: Binding<ActionQueueItem>) -> some View {
        HStack(spacing: 8) {
            queueProgress(item.wrappedValue)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.wrappedValue.title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(TBColor.textPrimary)
                    .lineLimit(2)

                Text("\(scheduledTimeText(item.wrappedValue.scheduledStart)) · \(durationText(item.wrappedValue.estimatedDurationMinutes))")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(TBColor.textSecondary)

                Menu {
                    ForEach(labels) { workLabel in
                        Button(workLabel.displayName) {
                            item.wrappedValue.labelID = workLabel.id
                        }
                    }
                } label: {
                    workLabelBox(label(for: item.wrappedValue.labelID))
                }
            }

            Spacer(minLength: 0)
        }
        .padding(8)
        .background(TBColor.surfaceElevated.opacity(0.72))
        .overlay(Rectangle().stroke(TBColor.border, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.wrappedValue.title), \(Int(item.wrappedValue.progress * 100)) percent complete")
    }

    private func queuePlaceholderRow(_ item: ActionQueueItem) -> some View {
        HStack(spacing: 8) {
            queueProgress(item)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(TBColor.textPrimary.opacity(0.72))
                    .lineLimit(2)

                Text("\(scheduledTimeText(item.scheduledStart)) · \(durationText(item.estimatedDurationMinutes))")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(TBColor.textSecondary)

                workLabelBox(label(for: item.labelID))
            }

            Spacer(minLength: 0)
        }
        .padding(8)
        .background(TBColor.surfaceElevated.opacity(0.42))
        .overlay(Rectangle().stroke(TBColor.border, lineWidth: 1))
    }

    @ViewBuilder
    private func queueProgress(_ item: ActionQueueItem) -> some View {
        if item.isComplete {
            Image(systemName: "checkmark.square.fill")
                .font(.system(size: 27, weight: .bold))
                .foregroundStyle(item.color)
                .frame(width: 30, height: 30)
                .transition(.scale.combined(with: .opacity))
        } else {
            ZStack {
                Circle()
                    .stroke(item.color.opacity(0.18), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: item.progress)
                    .stroke(item.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 30, height: 30)
            .animation(.spring(response: 0.3, dampingFraction: 0.85), value: item.progress)
        }
    }

    private var heroContent: some View {
        VStack(alignment: .center, spacing: 16) {
            VStack(alignment: .center, spacing: 8) {
                Text("TODAY’S ACTION")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(TBColor.textSecondary)

                TextField("Action title", text: $action.title)
                    .font(TBTypography.title(.headline, weight: .semibold))
                    .foregroundStyle(TBColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.sentences)
            }

            ZStack {
                Circle()
                    .stroke(TBColor.surfaceElevated, lineWidth: 15)

                Circle()
                    .trim(from: 0, to: currentActionProgress)
                    .stroke(
                        TBColor.accentGradient,
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: action.accent.opacity(0.25), radius: 12)

                VStack(spacing: 5) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(action.accent)
                    Text(consumedTimeText)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(TBColor.textPrimary)
                    Text("time consumed")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(TBColor.textSecondary)
                }
            }
            .frame(width: 154, height: 154)
            .accessibilityLabel("Current task \(Int(currentActionProgress * 100)) percent complete")

            compactTimerControls

            VStack(spacing: 7) {
                Text("\(durationText(Int(Double(elapsedSeconds) / 60))) / \(durationText(action.targetMinutes))")
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.textPrimary)

                timeReadout(title: "Time Now", value: clockText)
                timeReadout(title: "Est. Time Complete", value: estimatedCompletionText)
            }

            Text(action.note)
                .font(TBTypography.caption())
                .foregroundStyle(TBColor.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var compactTimerControls: some View {
        HStack(spacing: 12) {
            iconTimerButton(
                label: isRunning ? "Pause" : "Start",
                systemName: isRunning ? "pause.fill" : "play.fill",
                tint: TBColor.primaryAccent
            ) {
                isRunning.toggle()
            }

            iconTimerButton(label: "Restart", systemName: "arrow.counterclockwise", tint: TBColor.textPrimary) {
                isRunning = false
                elapsedSeconds = action.elapsedMinutes * 60
            }

            iconTimerButton(label: "Labels", systemName: "tag", tint: action.accent) {
                showingWorkLabels = true
            }
        }
        .accessibilityElement(children: .contain)
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

    private var halfDayRingsCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("AM and PM rings")
                        .font(TBTypography.title(.title2, weight: .bold))
                        .foregroundStyle(TBColor.textPrimary)

                    Text("Planned and completed time across the first and second half of today.")
                        .font(TBTypography.caption())
                        .foregroundStyle(TBColor.textSecondary)
                }

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 18) {
                        halfDayRing(.morning)
                        halfDayRing(.evening)
                    }

                    VStack(spacing: 18) {
                        halfDayRing(.morning)
                        halfDayRing(.evening)
                    }
                }
                .frame(maxWidth: .infinity)

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

    private func halfDayRing(_ halfDay: ActionHalfDay) -> some View {
        let slices = dailySlices.filter { $0.halfDay == halfDay }
        let consumedMinutes = slices.reduce(0) { $0 + $1.consumedMinutes }

        return VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(TBColor.surfaceElevated, lineWidth: 18)

                ForEach(0..<12, id: \.self) { hour in
                    Capsule(style: .continuous)
                        .fill(TBColor.textSecondary.opacity(hour % 3 == 0 ? 0.65 : 0.28))
                        .frame(width: 2, height: hour % 3 == 0 ? 8 : 5)
                        .offset(y: -71)
                        .rotationEffect(.degrees(Double(hour) * 30))
                }

                ForEach(slices) { slice in
                    Circle()
                        .trim(from: slice.startFraction, to: slice.plannedEndFraction)
                        .stroke(
                            slice.color.opacity(0.22),
                            style: StrokeStyle(lineWidth: 18, lineCap: .butt)
                        )
                        .rotationEffect(.degrees(-90))

                    Circle()
                        .trim(from: slice.startFraction, to: slice.completedEndFraction)
                        .stroke(
                            slice.color,
                            style: StrokeStyle(lineWidth: 18, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .shadow(color: slice.color.opacity(0.24), radius: 7)
                }

                VStack(spacing: 3) {
                    Text(halfDay.shortTitle)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(TBColor.textPrimary)

                    Text(durationText(Int(consumedMinutes.rounded())))
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.primaryAccent)

                    Text("logged")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(TBColor.textSecondary)
                }
            }
            .frame(width: 160, height: 160)
            .animation(.linear(duration: 0.3), value: consumedMinutes)

            Text(halfDay.rangeTitle)
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(halfDay.accessibilityLabel(for: slices, totalMinutes: consumedMinutes))
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

    private var consumedTimeText: String {
        let minutes = elapsedSeconds / 60
        if minutes >= 60 {
            return durationText(minutes)
        }
        return String(format: "%02d:%02d", minutes, elapsedSeconds % 60)
    }

    private var currentActionProgress: Double {
        guard action.targetMinutes > 0 else { return 0 }
        let liveProgress = Double(elapsedSeconds) / Double(action.targetMinutes * 60)
        return min(max(liveProgress, action.progress), 1)
    }

    private var dailySlices: [DailyActionSlice] {
        let current = makeDailySlices(
            id: action.id,
            title: action.title,
            scheduledStart: action.scheduledStart,
            plannedMinutes: Double(action.targetMinutes),
            consumedMinutes: min(Double(elapsedSeconds) / 60, Double(action.targetMinutes)),
            color: action.accent
        )

        let upcoming = queue.flatMap { item in
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
            if startMinute >= 24 * 60 { startMinute = 0 }

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

    private var clockText: String {
        let time = now.formatted(date: .omitted, time: .shortened)
        let zone = TimeZone.current.abbreviation() ?? ""
        return zone.isEmpty ? time : "\(time) \(zone)"
    }

    private var estimatedCompletionText: String {
        let elapsedMinutes = Int(Double(elapsedSeconds) / 60)
        let remainingMinutes = max(action.targetMinutes - elapsedMinutes, 0)
        let completion = Calendar.current.date(byAdding: .minute, value: remainingMinutes, to: now) ?? now
        let time = completion.formatted(date: .omitted, time: .shortened)
        let zone = TimeZone.current.abbreviation() ?? ""
        return zone.isEmpty ? time : "\(time) \(zone)"
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

    private func iconTimerButton(label: String, systemName: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 42, height: 42)
                .background(
                    Circle()
                        .fill(TBColor.surfaceElevated)
                        .overlay(Circle().stroke(tint.opacity(0.28), lineWidth: 1))
                )
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

private enum ActionHalfDay: String, CaseIterable {
    case morning
    case evening

    var shortTitle: String { self == .morning ? "AM" : "PM" }
    var rangeTitle: String { self == .morning ? "12 a.m. – 12 p.m." : "12 p.m. – 12 a.m." }

    func accessibilityLabel(for slices: [DailyActionSlice], totalMinutes: Double) -> String {
        let actions = slices
            .filter { $0.consumedMinutes > 0 }
            .map { "\($0.title), \(Int($0.consumedMinutes.rounded())) minutes" }
            .joined(separator: ", ")
        let detail = actions.isEmpty ? "No time logged" : actions
        return "\(rangeTitle), \(Int(totalMinutes.rounded())) minutes logged. \(detail)."
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
        ActionView().preferredColorScheme(.dark)
    }
}
#endif
