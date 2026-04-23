import SwiftUI

public struct FocusLaneCard: View {
    let title: String
    let iconSystemName: String
    let targetToday: String
    let progress: Double
    let accent: Color

    public init(
        title: String,
        iconSystemName: String,
        targetToday: String,
        progress: Double,
        accent: Color
    ) {
        self.title = title
        self.iconSystemName = iconSystemName
        self.targetToday = targetToday
        self.progress = progress
        self.accent = accent
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: iconSystemName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 28, height: 28)
                    .background(accent.opacity(0.16), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Target today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(progress, format: .percent.precision(.fractionLength(0)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(targetToday)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                ProgressView(value: progress)
                    .tint(accent)
            }
        }
        .commandCenterCard()
    }
}

// MARK: - Shared card styling

struct CommandCenterCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.28), radius: 18, x: 0, y: 10)
    }
}

extension View {
    func commandCenterCard() -> some View {
        modifier(CommandCenterCardModifier())
    }
}

struct FocusLaneCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            FocusLaneCard(
                title: "Build",
                iconSystemName: "hammer.fill",
                targetToday: "Finish the command center UI",
                progress: 0.42,
                accent: .cyan
            )
            .frame(width: 260)
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}
