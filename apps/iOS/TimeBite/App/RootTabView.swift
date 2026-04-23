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
                    Label("Track", systemImage: "chart.line.uptrend.xyaxis")
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
        .toolbarBackground(TBColor.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

