import SwiftUI

struct TBPillButton: View {
    let title: String
    let systemName: String?
    let isSelected: Bool
    let action: () -> Void

    init(title: String, systemName: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.systemName = systemName
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemName {
                    Image(systemName: systemName)
                        .font(.caption.weight(.semibold))
                }

                Text(title)
                    .font(TBTypography.caption(.semibold))
            }
            .foregroundStyle(isSelected ? TBColor.textPrimary : TBColor.textSecondary)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? TBColor.primaryAccent.opacity(0.18) : TBColor.surfaceElevated)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(isSelected ? TBColor.primaryAccent.opacity(0.5) : TBColor.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

