import SwiftUI

struct TBSectionHeader: View {
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let action: (() -> Void)?

    init(title: String, subtitle: String? = nil, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(TBTypography.title(.headline, weight: .semibold))
                    .foregroundStyle(TBColor.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(TBTypography.caption())
                        .foregroundStyle(TBColor.textSecondary)
                }
            }

            Spacer()

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.primaryAccent)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

