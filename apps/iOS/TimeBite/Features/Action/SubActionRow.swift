import SwiftUI

struct SubActionRow: View {
    let subAction: SubAction
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: subAction.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(subAction.isDone ? TBColor.primaryAccent : TBColor.textSecondary)
                    .font(.system(size: 20, weight: .semibold))

                VStack(alignment: .leading, spacing: 4) {
                    Text(subAction.title)
                        .font(TBTypography.body(.semibold))
                        .foregroundStyle(TBColor.textPrimary)
                        .strikethrough(subAction.isDone, color: TBColor.textSecondary)
                    Text("\(subAction.estimatedMinutes) min micro-task")
                        .font(TBTypography.caption())
                        .foregroundStyle(TBColor.textSecondary)
                }

                Spacer()
            }
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

