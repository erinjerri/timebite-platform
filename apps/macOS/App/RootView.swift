import SwiftUI

struct RootView: View {
    @State private var selectedSection: String = "now"

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider()
            content
        }
        .background(TimeBitePalette.background.ignoresSafeArea())
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TimeBite")
                .font(TimeBiteTypography.font(.title2, weight: .bold))
                .foregroundStyle(.primary)
            Button("Now") { selectedSection = "now" }
            Button("Goals") { selectedSection = "goals" }
            Button("Track") { selectedSection = "track" }
            Spacer()
        }
        .padding(20)
        .frame(width: 240)
        .background(TimeBitePalette.surface)
    }

    @ViewBuilder
    private var content: some View {
        switch selectedSection {
        case "goals":
            placeholder(title: "Goals")
        case "track":
            placeholder(title: "Track")
        default:
            placeholder(title: "Now")
        }
    }

    private func placeholder(title: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(TimeBiteTypography.font(.largeTitle, weight: .bold))
            Text("macOS shell scaffold is in place. Next step is to wire in shared models, ring state, and the real workspace views.")
                .foregroundStyle(.secondary)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
