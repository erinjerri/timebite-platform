import SwiftUI

struct ActionTimerControls: View {
    let isRunning: Bool
    let onPrimary: () -> Void
    let onReset: () -> Void
    let onSkipBack: () -> Void
    let onSkipForward: () -> Void

    var body: some View {
        TBCard {
            VStack(alignment: .leading, spacing: TBSpacing.md) {
                TBSectionHeader(title: "Timer", subtitle: "Keep the loop moving")

                HStack(spacing: 12) {
                    timerButton(
                        title: isRunning ? "Pause" : "Start",
                        systemName: isRunning ? "pause.fill" : "play.fill",
                        tint: TBColor.primaryAccent,
                        action: onPrimary
                    )

                    timerButton(
                        title: "Reset",
                        systemName: "arrow.counterclockwise",
                        tint: TBColor.secondaryAccent,
                        action: onReset
                    )

                    timerButton(
                        title: "-5",
                        systemName: "minus",
                        tint: TBColor.gold,
                        action: onSkipBack
                    )

                    timerButton(
                        title: "+5",
                        systemName: "plus",
                        tint: TBColor.gold,
                        action: onSkipForward
                    )
                }
            }
        }
    }

    private func timerButton(title: String, systemName: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Text(title)
                    .font(TBTypography.caption(.semibold))
            }
            .foregroundStyle(TBColor.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(tint.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(tint.opacity(0.35), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

