import SwiftUI

struct GoalProgressRow: View {
    let snapshot: GoalProgressSnapshot

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(snapshot.title)
                    .font(TBTypography.body(.semibold))
                    .foregroundStyle(TBColor.textPrimary)
                Text(snapshot.status.title)
                    .font(TBTypography.caption())
                    .foregroundStyle(snapshot.status.tint)
            }

            Spacer()

            Text("\(Int(snapshot.progress * 100))%")
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textSecondary)
                .frame(width: 42, alignment: .trailing)
        }
        .overlay(alignment: .bottom) {
            ProgressView(value: snapshot.progress)
                .tint(snapshot.status.tint)
                .offset(y: 12)
        }
        .padding(.bottom, 20)
    }
}

