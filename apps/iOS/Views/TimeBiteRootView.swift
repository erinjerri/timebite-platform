import SwiftUI

struct TimeBiteRootView: View {
    @State private var selection: TBTab = .actions

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selection {
                case .actions:
                    ActionsView()
                case .dash:
                    TrackView()
                case .goals:
                    GoalsView()
                case .reflect:
                    ReflectionView()
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.985)))

            TBTabBar(selection: $selection)
                .padding(.bottom, 10)
        }
        .tint(TBTheme.cyan)
    }
}
