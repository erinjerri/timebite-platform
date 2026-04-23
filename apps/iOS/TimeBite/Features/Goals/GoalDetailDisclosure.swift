import SwiftUI

struct GoalDetailDisclosure: View {
    let title: String
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.textSecondary)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TBColor.textSecondary)
            }
            .padding(.top, 8)
        }
        .buttonStyle(.plain)
    }
}

