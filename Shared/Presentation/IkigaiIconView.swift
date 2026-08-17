import SwiftUI

struct IkigaiIconView: View {
    var body: some View {
        Image(systemName: "circle.hexagongrid.fill")
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(TimeBitePalette.sky)
    }
}
