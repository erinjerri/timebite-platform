import SwiftUI

struct TimeBiteRootView: View {
    var body: some View {
        TabView {
            IntentView()
                .tabItem {
                    Label("Intent", systemImage: "target")
                }

            ExecutionView()
                .tabItem {
                    Label("Execution", systemImage: "timer")
                }

            SpatialRingDemoView()
                .tabItem {
                    Label("Ring", systemImage: "circle.hexagongrid.circle")
                }

            ReflectionView()
                .tabItem {
                    Label("Reflect", systemImage: "checklist")
                }
        }
    }
}
