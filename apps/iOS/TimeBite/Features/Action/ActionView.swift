import SwiftUI

struct ActionView: View {
    @StateObject private var viewModel: ActionViewModel
    @StateObject private var timerService = TimerService()

    init(viewModel: ActionViewModel = .mock()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TBSpacing.lg) {
                    ActionHeroRing(
                        title: $viewModel.actionTitle,
                        category: viewModel.actionCategory,
                        streakDays: viewModel.streakDays,
                        progress: timerService.progress,
                        countdownText: timerText,
                        progressText: "\(viewModel.completedSubActions)/\(viewModel.subActions.count) subtasks done"
                    )

                    ActionTimerControls(
                        isRunning: timerService.isRunning,
                        onPrimary: toggleTimer,
                        onReset: resetTimer,
                        onSkipBack: { timerService.skip(minutes: -5); viewModel.addFiveMinutes() },
                        onSkipForward: { timerService.skip(minutes: 5); viewModel.skipFiveMinutes() }
                    )

                    TBCard {
                        VStack(alignment: .leading, spacing: TBSpacing.xs) {
                            TBSectionHeader(title: "Micro-subtasks", subtitle: "Keep the flow small and visible")

                            VStack(spacing: 4) {
                                ForEach(viewModel.subActions) { subAction in
                                    SubActionRow(subAction: subAction) {
                                        viewModel.toggleSubAction(subAction)
                                    }

                                    if subAction.id != viewModel.subActions.last?.id {
                                        Divider().overlay(TBColor.border)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, TBSpacing.md)
                .padding(.top, TBSpacing.md)
                .padding(.bottom, TBSpacing.xl)
            }
            .scrollIndicators(.hidden)
            .background(background)
            .navigationTitle("Action")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            timerService.configure(totalMinutes: viewModel.targetMinutes, elapsedMinutes: max(viewModel.targetMinutes - viewModel.remainingMinutes, 0))
        }
    }

    private var timerText: String {
        let remainingSeconds = max(timerService.totalSeconds - timerService.elapsedSeconds, 0)
        return String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
    }

    private func toggleTimer() {
        if timerService.isRunning {
            timerService.pause()
            syncRemainingMinutes()
        } else {
            timerService.start()
        }
        HapticsService.soft()
    }

    private func resetTimer() {
        timerService.reset()
        viewModel.resetTimer()
        HapticsService.warning()
    }

    private func syncRemainingMinutes() {
        let remainingSeconds = max(timerService.totalSeconds - timerService.elapsedSeconds, 0)
        viewModel.remainingMinutes = max(remainingSeconds / 60, 0)
    }

    private var background: some View {
        ZStack {
            TBColor.background

            RadialGradient(
                colors: [
                    TBColor.secondaryAccent.opacity(0.20),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 380
            )
            .blendMode(.screen)

            LinearGradient(
                colors: [
                    TBColor.background,
                    TBColor.surface.opacity(0.56),
                    TBColor.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

#if DEBUG
struct ActionView_Previews: PreviewProvider {
    static var previews: some View {
        ActionView()
            .preferredColorScheme(.dark)
    }
}
#endif
