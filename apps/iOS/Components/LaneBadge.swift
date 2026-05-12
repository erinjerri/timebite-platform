import SwiftUI

struct LaneBadge: View {
    let laneType: FocusLaneType

    var body: some View {
        HStack(spacing: 6) {
            TBIconView(kind: .lane(laneType), color: TBTheme.laneColor(laneType), lineWidth: 1.5)
                .frame(width: 14, height: 14)
            Text(laneType.title)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(TBTheme.primaryText)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(TBTheme.laneColor(laneType).opacity(0.14), in: Capsule())
        .overlay(
            Capsule()
                .stroke(TBTheme.laneColor(laneType).opacity(0.32), lineWidth: 1)
        )
    }
}
