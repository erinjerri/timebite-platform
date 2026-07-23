import Combine
import SwiftUI

struct ActionView: View {
    @State private var action = ActionItem.mock
    @State private var queue = ActionQueueItem.samples
    @State private var labels = WorkLabel.samples
    @State private var isRunning = false
    @State private var elapsedSeconds = ActionItem.mock.elapsedMinutes * 60
    @State private var now = Date()
    @State private var ringMode: ActionRingMode = .focus
    @State private var showingWorkLabels = false

    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let workLabelsStorageKey = "timebite.workLabels"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    executionCard
                    timerCard
                    releaseCard
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

    private var executionCard: some View {
        TBCard {
            HStack(alignment: .top, spacing: 14) {
                upcomingRail
                    .frame(width: 128, height: 344)

                Divider()
                    .overlay(TBColor.border)

                heroContent
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private var upcomingRail: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CURRENT TASK")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .tracking(1.05)
                .foregroundStyle(TBColor.textSecondary)

            VStack(alignment: .leading, spacing: 7) {
                Text(action.title)
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.textPrimary)
                    .lineLimit(2)

                Menu {
                    ForEach(labels) { workLabel in
                        Button(workLabel.displayName) {
                            action.labelID = workLabel.id
                        }
                    }
                } label: {
                    workLabelBox(label(for: action.labelID))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(action.accent.opacity(0.14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(action.accent.opacity(0.7), lineWidth: 1)
                    )
            )

            Text("UPCOMING")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .tracking(1.05)
                .foregroundStyle(TBColor.textSecondary)

            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 8) {
                    ForEach($queue) { $item in
                        queueRow(item: $item)
                    }
                }
            }
        }
    }

    private func queueRow(item: Binding<ActionQueueItem>) -> some View {
        HStack(spacing: 8) {
            queueProgress(item.wrappedValue)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.wrappedValue.title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(TBColor.textPrimary)
                    .lineLimit(2)

                Text("\(item.wrappedValue.estimatedDurationMinutes)m")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(TBColor.textSecondary)

                Text("\(item.wrappedValue.status) • \(item.wrappedValue.dueText)")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundStyle(item.wrappedValue.color)
                    .lineLimit(1)

                Text(item.wrappedValue.epic)
                    .font(.system(size: 8, weight: .medium, design: .rounded))
                    .foregroundStyle(TBColor.textSecondary)
                    .lineLimit(1)

                Text(item.wrappedValue.repoName)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(TBColor.textSecondary)
                    .lineLimit(1)

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
        VStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
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

            Picker("Ring mode", selection: $ringMode) {
                ForEach(ActionRingMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            ZStack {
                Circle()
                    .stroke(TBColor.surfaceElevated, lineWidth: 15)

                Circle()
                    .trim(from: 0, to: action.progress)
                    .stroke(
                        ringMode == .focus ? AnyShapeStyle(TBColor.accentGradient) : AnyShapeStyle(action.accent),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round, dash: ringMode == .cycles ? [18, 7] : [])
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
            .accessibilityLabel("Current task \(Int(action.progress * 100)) percent complete")

            VStack(spacing: 7) {
                Text("\(action.elapsedMinutes) / \(action.targetMinutes) min")
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

    private var timerCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hourglass controls")
                        .font(TBTypography.title(.headline, weight: .semibold))
                        .foregroundStyle(TBColor.textPrimary)
                    Text("Progress is rendered from TaskSvc; controls change the running session only.")
                        .font(TBTypography.caption())
                        .foregroundStyle(TBColor.textSecondary)
                }

                HStack(spacing: 10) {
                    timerButton(label: isRunning ? "Pause" : "Start", systemName: isRunning ? "pause.fill" : "play.fill") {
                        isRunning.toggle()
                    }

                    timerButton(label: "Restart", systemName: "arrow.counterclockwise") {
                        isRunning = false
                        elapsedSeconds = action.elapsedMinutes * 60
                    }

                    timerButton(label: "Labels", systemName: "tag") {
                        showingWorkLabels = true
                    }
                }
            }
        }
    }

    private var releaseCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("RELEASE COMMAND CENTER")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(1.1)
                            .foregroundStyle(TBColor.textSecondary)
                        Text("Ship TimeBite on iOS + visionOS")
                            .font(TBTypography.title(.headline, weight: .semibold))
                            .foregroundStyle(TBColor.textPrimary)
                    }
                    Spacer()
                    Text("\(queue.count + 1) tasks")
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.primaryAccent)
                }

                HStack(spacing: 10) {
                    releaseDeadline(label: "TESTFLIGHT", date: "JUL 25", tint: TBColor.gold)
                    releaseDeadline(label: "SUBMISSION", date: "JUL 30", tint: TBColor.primaryAccent)
                }

                Text("Notion is the planning mirror. This queue is seeded from the same real release work so the app can dogfood its own execution loop.")
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func releaseDeadline(label: String, date: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .tracking(0.9)
                .foregroundStyle(TBColor.textSecondary)
            Text(date)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(TBColor.surfaceElevated)
        .overlay(Rectangle().stroke(tint.opacity(0.35), lineWidth: 1))
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
        String(format: "%02d:%02d", elapsedSeconds / 60, elapsedSeconds % 60)
    }

    private var clockText: String {
        let time = now.formatted(date: .omitted, time: .shortened)
        let zone = TimeZone.current.abbreviation() ?? ""
        return zone.isEmpty ? time : "\(time) \(zone)"
    }

    private var estimatedCompletionText: String {
        let remainingMinutes = max(action.targetMinutes - action.elapsedMinutes, 0)
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

    private func timerButton(label: String, systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemName)
                    .font(.system(size: 16, weight: .semibold))
                Text(label)
                    .font(TBTypography.caption(.semibold))
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

private enum ActionRingMode: String, CaseIterable, Identifiable {
    case focus
    case cycles

    var id: String { rawValue }
    var title: String { self == .focus ? "Focus" : "Cycles" }
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
