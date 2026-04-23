import SwiftUI

struct EmptyGoalsState: View {
    var body: some View {
        TBCard {
            VStack(spacing: 10) {
                Image(systemName: "target")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(TBColor.primaryAccent)
                Text("No goals in this filter")
                    .font(TBTypography.body(.semibold))
                    .foregroundStyle(TBColor.textPrimary)
                Text("Try another category or add a new strategic objective.")
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
        }
    }
}

