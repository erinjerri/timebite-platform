import Combine
import SwiftUI

struct ActionView: View {
    @State private var action = ActionItem.mock
    @State private var isRunning = false
    @State private var elapsedSeconds = ActionItem.mock.elapsedMinutes * 60
    @State private var steps: [ActionStep] = [
        .init(title: "Tighten the hero ring layout", minutes: 8, isDone: true),
        .init(title: "Polish timer controls and states", minutes: 12, isDone: false),
        .init(title: "Add one more pass of realism", minutes: 10, isDone: false)
    ]
    @State private var completionCapture: TaskCompletionCapture?

    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    heroCard
                    if let completionCapture {
                        inlineCompletionCapture(completionCapture)
                    }
                    timerCard
                    subtasksCard
                }
                .padding(16)
            }
            .background(background)
            .navigationTitle("Action")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onReceive(tick) { _ in
            guard isRunning else { return }
            let maxSeconds = action.targetMinutes * 60
            if elapsedSeconds < maxSeconds {
                elapsedSeconds += 1
            } else {
                isRunning = false
            }
        }
    }

    private var heroCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today’s action")
                        .font(TBTypography.caption(.semibold))
                        .tracking(1.2)
                        .foregroundStyle(TBColor.textSecondary)

                    TextField("Action title", text: $action.title)
                        .font(TBTypography.title(.title2, weight: .semibold))
                        .foregroundStyle(TBColor.textPrimary)
                        .textInputAutocapitalization(.sentences)

                    HStack(spacing: 8) {
                        pill(label: action.category, systemName: "sparkles")
                        pill(label: "\(action.streakDays)-day streak", systemName: "flame.fill", tint: TBColor.gold)
                    }
                }

                ZStack {
                    Circle()
                        .stroke(TBColor.surfaceElevated, lineWidth: 20)

                    Circle()
                        .trim(from: 0, to: action.progress)
                        .stroke(
                            TBColor.accentGradient,
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .shadow(color: action.accent.opacity(0.25), radius: 14)

                    VStack(spacing: 8) {
                        Text(timeText)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(TBColor.textPrimary)

                        Text("\(action.elapsedMinutes) / \(action.targetMinutes) min")
                            .font(TBTypography.caption())
                            .foregroundStyle(TBColor.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)

                Text(action.note)
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
            }
        }
    }

    private var timerCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader(title: "Timer", subtitle: "Keep the flow visible")

                HStack(spacing: 10) {
                    timerButton(label: isRunning ? "Pause" : "Start", systemName: isRunning ? "pause.fill" : "play.fill") {
                        isRunning.toggle()
                    }

                    timerButton(label: "Reset", systemName: "arrow.counterclockwise") {
                        isRunning = false
                        elapsedSeconds = 0
                        action.elapsedMinutes = 0
                    }

                    timerButton(label: "-5", systemName: "minus") {
                        elapsedSeconds = max(0, elapsedSeconds - 5 * 60)
                        action.elapsedMinutes = max(0, elapsedSeconds / 60)
                    }

                    timerButton(label: "+5", systemName: "plus") {
                        elapsedSeconds = min(action.targetMinutes * 60, elapsedSeconds + 5 * 60)
                        action.elapsedMinutes = elapsedSeconds / 60
                    }
                }
            }
        }
    }

    private var subtasksCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader(title: "Micro-subtasks", subtitle: "Three believable next moves")

                ForEach(steps) { step in
                    Button {
                        toggle(step)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: step.isDone ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(step.isDone ? TBColor.primaryAccent : TBColor.textSecondary)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(step.title)
                                    .font(TBTypography.body(.semibold))
                                    .foregroundStyle(TBColor.textPrimary)
                                    .strikethrough(step.isDone, color: TBColor.textSecondary)
                                Text("\(step.minutes) min micro-task")
                                    .font(TBTypography.caption())
                                    .foregroundStyle(TBColor.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)

                    if step.id != steps.last?.id {
                        Divider().overlay(TBColor.border)
                    }
                }
            }
        }
    }

    private var background: some View {
        ZStack {
            TBColor.background

            RadialGradient(
                colors: [
                    action.accent.opacity(0.22),
                    .clear
                ],
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

    private var timeText: String {
        let remaining = max(action.targetMinutes * 60 - elapsedSeconds, 0)
        return String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }

    private func toggle(_ step: ActionStep) {
        guard let index = steps.firstIndex(where: { $0.id == step.id }) else { return }
        steps[index].isDone.toggle()

        if steps[index].isDone {
            let capture = TaskCompletionCapture(
                goalID: "goal-timebite",
                goalTitle: "Ship TimeBite Quarterly Chart",
                minutes: step.minutes
            )
            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                completionCapture = capture
            }
            NotificationCenter.default.post(
                name: .timeBiteTaskCompleted,
                object: nil,
                userInfo: [
                    "goalID": capture.goalID,
                    "goalTitle": capture.goalTitle,
                    "minutes": capture.minutes
                ]
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.easeOut(duration: 0.22)) {
                    completionCapture = nil
                }
            }
        }
    }

    private func inlineCompletionCapture(_ capture: TaskCompletionCapture) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(TBColor.primaryAccent)

            Text("+\(capture.minutes)m -> \(capture.goalTitle)")
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textPrimary)

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(TBColor.primaryAccent.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(TBColor.primaryAccent.opacity(0.24), lineWidth: 1))
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func pill(label: String, systemName: String, tint: Color? = nil) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemName)
                .font(.caption.weight(.semibold))
            Text(label)
                .font(TBTypography.caption(.semibold))
        }
        .foregroundStyle(tint ?? TBColor.primaryAccent)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            Capsule(style: .continuous)
                .fill((tint ?? TBColor.primaryAccent).opacity(0.12))
                .overlay(Capsule(style: .continuous).stroke((tint ?? TBColor.primaryAccent).opacity(0.22), lineWidth: 1))
        )
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

private struct ActionStep: Identifiable {
    let id = UUID()
    var title: String
    var minutes: Int
    var isDone: Bool
}

#if DEBUG
struct ActionView_Previews: PreviewProvider {
    static var previews: some View {
        ActionView().preferredColorScheme(.dark)
    }
}
#endif
