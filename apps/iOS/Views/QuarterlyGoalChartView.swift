import SwiftUI

struct QuarterlyGoalChartView: View {
    @StateObject private var viewModel: QuarterlyGoalViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @MainActor
    init() {
        _viewModel = StateObject(wrappedValue: QuarterlyGoalViewModel())
    }

    @MainActor
    init(viewModel: QuarterlyGoalViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            if viewModel.goals.isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.goals) { goal in
                        QuarterlyGoalProgressRow(goal: goal, reduceMotion: reduceMotion)
                    }
                }
            }
        }
        .padding(16)
        .background(cardBackground)
        .task {
            await viewModel.fetch()
        }
        .overlay(alignment: .topTrailing) {
            if let capture = viewModel.lastCompletion {
                completionCaptureToast(capture)
                    .padding(12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Quarterly Goal Chart")
                    .font(TBTypography.title(.headline, weight: .semibold))
                    .foregroundStyle(TBColor.textPrimary)

                Text("Time lands as tasks complete.")
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
            }

            Spacer()

            HStack(spacing: 6) {
                quarterButton(systemName: "chevron.left") {
                    viewModel.moveQuarter(by: -1)
                }

                Text(viewModel.quarterDisplayTitle)
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.primaryAccent)
                    .frame(minWidth: 72)

                quarterButton(systemName: "chevron.right") {
                    viewModel.moveQuarter(by: 1)
                }
            }
            .padding(6)
            .background(
                Capsule(style: .continuous)
                    .fill(TBColor.surfaceElevated.opacity(0.72))
                    .overlay(Capsule(style: .continuous).stroke(TBColor.primaryAccent.opacity(0.18), lineWidth: 1))
            )
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "target")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(TBColor.primaryAccent)

            Text("Set a quarterly target on an existing goal.")
                .font(TBTypography.body(.semibold))
                .foregroundStyle(TBColor.textPrimary)

            Text("Add a quarter and target hours, then completed task time will fill the chart.")
                .font(TBTypography.caption())
                .foregroundStyle(TBColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(TBColor.surfaceElevated.opacity(0.62))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(TBColor.border, lineWidth: 1))
        )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        TBColor.surfaceElevated.opacity(0.94),
                        TBColor.surface.opacity(0.82),
                        Color(red: 0.04, green: 0.05, blue: 0.10).opacity(0.96)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(TBColor.primaryAccent.opacity(0.20), lineWidth: 1)
                    .shadow(color: TBColor.primaryAccent.opacity(0.22), radius: 12)
            )
    }

    private func quarterButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(TBColor.textPrimary)
                .frame(width: 26, height: 26)
        }
        .buttonStyle(.plain)
    }

    private func completionCaptureToast(_ capture: TaskCompletionCapture) -> some View {
        Text("+\(capture.minutes)m -> \(capture.goalTitle)")
            .font(TBTypography.caption(.semibold))
            .foregroundStyle(Color.black.opacity(0.86))
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(Capsule(style: .continuous).fill(TBColor.primaryAccent))
            .shadow(color: TBColor.primaryAccent.opacity(0.34), radius: 14)
    }
}

private struct QuarterlyGoalProgressRow: View {
    let goal: QuarterlyGoalRollup
    let reduceMotion: Bool

    private var loggedHours: Int {
        Int((Double(goal.loggedMinutes) / 60).rounded(.down))
    }

    private var targetHours: Int {
        max(Int((Double(goal.targetMinutes) / 60).rounded(.up)), 1)
    }

    private var clampedProgress: Double {
        min(max(goal.percentComplete, 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(goal.title)
                    .font(TBTypography.body(.semibold))
                    .foregroundStyle(TBColor.textPrimary)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text("\(loggedHours)h of \(targetHours)h")
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.primaryAccent)
            }

            HStack(spacing: 8) {
                Text(goal.pillar)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(pillarTint)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 8)
                    .background(Capsule(style: .continuous).fill(pillarTint.opacity(0.12)))

                Text("\(goal.completedTaskCount)/\(goal.taskCount) tasks")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(TBColor.textSecondary)

                if let recentDeltaMinutes = goal.recentDeltaMinutes {
                    Text("+\(recentDeltaMinutes)m")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(TBColor.primaryAccent)
                }
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.055))
                        .overlay(Capsule(style: .continuous).stroke(TBColor.primaryAccent.opacity(0.16), lineWidth: 1))
                        .shadow(color: TBColor.primaryAccent.opacity(0.16), radius: 8)

                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [TBColor.primaryAccent, Color(red: 0.72, green: 0.37, blue: 1.0), Color(red: 0.95, green: 0.29, blue: 0.78)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, proxy.size.width * clampedProgress))
                        .shadow(color: TBColor.primaryAccent.opacity(0.32), radius: 10)
                        .animation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.82), value: goal.loggedMinutes)
                }
            }
            .frame(height: 9)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(goal.title) progress")
            .accessibilityValue("\(Int(clampedProgress * 100)) percent, \(loggedHours) of \(targetHours) hours, \(goal.completedTaskCount) of \(goal.taskCount) tasks complete")
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(TBColor.surface.opacity(0.62))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(TBColor.border, lineWidth: 1))
        )
    }

    private var pillarTint: Color {
        switch goal.pillar.lowercased() {
        case "work":
            return TBColor.primaryAccent
        case "personal":
            return Color(red: 0.95, green: 0.29, blue: 0.78)
        case "admin":
            return Color(red: 0.72, green: 0.37, blue: 1.0)
        default:
            return Color(red: 0.39, green: 0.77, blue: 0.98)
        }
    }
}

#if DEBUG
struct QuarterlyGoalChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            TBColor.background.ignoresSafeArea()
            QuarterlyGoalChartView(
                viewModel: QuarterlyGoalViewModel(
                    quarter: "2026-Q3",
                    goals: QuarterlyGoalViewModel.mockGoals,
                    allowsMockFallback: true
                )
            )
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}
#endif
