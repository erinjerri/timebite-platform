import SwiftUI

struct LaneBadge: View {
    let laneType: FocusLaneType

    var body: some View {
        Text(laneType.title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.secondary.opacity(0.16), in: Capsule())
    }
}
