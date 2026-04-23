import SwiftUI

struct DashView: View {
    @StateObject private var viewModel: DashViewModel

    init(viewModel: DashViewModel = .mock()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TBSpacing.lg) {
                    TBSectionHeader(
                        title: "Dash",
                        subtitle: "Portfolio-grade analytics with local mock truth"
                    )

                    TimeRangePicker(selectedRange: $viewModel.selectedRange)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(viewModel.kpis) { stat in
                            KPIStatCard(stat: stat)
                        }
                    }

                    FocusHoursChart(points: viewModel.currentSeries)
                    CategorySplitDonut(shares: viewModel.categoryShares)

                    TBCard {
                        VStack(alignment: .leading, spacing: 10) {
                            TBSectionHeader(title: "Goal progress", subtitle: "Compact check-in")
                            ForEach(viewModel.goalProgress) { snapshot in
                                GoalProgressRow(snapshot: snapshot)
                            }
                        }
                    }

                    VStack(spacing: 12) {
                        ForEach(viewModel.insights) { insight in
                            InsightCard(insight: insight)
                        }
                    }
                }
                .padding(.horizontal, TBSpacing.md)
                .padding(.top, TBSpacing.md)
                .padding(.bottom, TBSpacing.xl)
            }
            .scrollIndicators(.hidden)
            .background(background)
            .navigationTitle("Dash")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [TBColor.background, TBColor.surface.opacity(0.4), TBColor.background],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#if DEBUG
struct DashView_Previews: PreviewProvider {
    static var previews: some View {
        DashView()
            .preferredColorScheme(.dark)
    }
}
#endif
