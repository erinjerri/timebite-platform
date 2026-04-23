import SwiftUI

struct TrackView: View {
    @StateObject private var viewModel: TrackViewModel

    init(viewModel: TrackViewModel = .mock()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TBSpacing.lg) {
                    TBSectionHeader(
                        title: "Track",
                        subtitle: "Daily rhythm with a calm, execution-first timeline",
                        actionTitle: "Add Habit"
                    ) {
                        viewModel.showAddSheet = true
                    }

                    TrackSegmentedControl(selectedPeriod: $viewModel.selectedPeriod)

                    content
                }
                .padding(.horizontal, TBSpacing.md)
                .padding(.top, TBSpacing.md)
                .padding(.bottom, TBSpacing.xl)
            }
            .scrollIndicators(.hidden)
            .background(background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Track")
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddHabitSheet(
                    habitName: $viewModel.newHabitName,
                    selectedCategory: $viewModel.newHabitCategory,
                    onSave: viewModel.addHabit,
                    onCancel: { viewModel.showAddSheet = false }
                )
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.selectedPeriod {
        case .daily:
            DailyTrackList(entries: viewModel.dailyEntries)
        case .weekly:
            WeeklyTrackGrid(minutes: viewModel.weeklyMinutes)
        case .monthly:
            MonthlyHeatmapView(intensity: viewModel.heatmapIntensity)
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
struct TrackView_Previews: PreviewProvider {
    static var previews: some View {
        TrackView()
            .preferredColorScheme(.dark)
    }
}
#endif
