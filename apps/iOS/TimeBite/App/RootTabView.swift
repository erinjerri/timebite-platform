import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            ActionView()
                .tabItem {
                    Label("Action", systemImage: "target")
                }

            TrackView()
                .tabItem {
                    Label("Track", systemImage: "calendar.day.timeline.left")
                }

            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "list.bullet.rectangle")
                }

            DashView()
                .tabItem {
                    Label("Dash", systemImage: "chart.bar.xaxis")
                }
        }
        .tint(TBColor.primaryAccent)
    }
}

