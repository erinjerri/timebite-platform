import SwiftUI

struct TimeBiteRootView: View {
    var body: some View {
        TabView {
            ActionsView()
                .tabItem {
                    Label("Actions", systemImage: "timer")
                }
                .accessibilityLabel("Actions")

            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .accessibilityLabel("Goals")

            TrackView()
                .tabItem {
                    Label("Track", systemImage: "chart.xyaxis.line")
                }
                .accessibilityLabel("Track")

            ReflectionView()
                .tabItem {
                    Label("Reflect", systemImage: "checklist")
                }
        }
    }
}
