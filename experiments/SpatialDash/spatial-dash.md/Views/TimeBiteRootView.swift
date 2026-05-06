import SwiftUI

struct TimeBiteRootView: View {
    @State private var environment: SpatialEnvironment = .timebiteLight

    private var tokens: DesignTokens {
        TokenResolver.resolve(environment)
    }

    var body: some View {
        TabView {
            shell {
                ActionsView(environment: environment, tokens: tokens)
            }
            .tabItem { Label("Actions", systemImage: "timer") }

            shell {
                GoalsView(environment: environment, tokens: tokens)
            }
            .tabItem { Label("Goals", systemImage: "target") }

            shell {
                TrackView(environment: environment, tokens: tokens)
            }
            .tabItem { Label("Track", systemImage: "chart.bar.xaxis") }

            shell {
                DashboardView(environment: environment, tokens: tokens)
            }
            .tabItem { Label("Dashboard", systemImage: "square.grid.2x2") }
        }
        .tint(tokens.color.accent)
        .animation(SpatialEnvironmentRenderer.animation(for: tokens), value: environment.id)
    }

    private func shell<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack(alignment: .topTrailing) {
            tokens.color.background.ignoresSafeArea()

            ScrollView {
                content()
                    .frame(maxWidth: 1180)
                    .frame(maxWidth: .infinity)
            }

            EnvironmentSwitcherView(environment: $environment, tokens: tokens)
                .padding(tokens.spacing.standard)
        }
    }
}

#Preview {
    TimeBiteRootView()
}
