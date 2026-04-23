import SwiftUI

struct GoalsView: View {
    @StateObject private var viewModel: GoalsViewModel

    init(viewModel: GoalsViewModel = .mock()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TBSpacing.lg) {
                    GoalsHeaderView()

                    CategoryFilterChips(selectedFilter: $viewModel.selectedFilter)

                    if viewModel.filteredGoals.isEmpty {
                        EmptyGoalsState()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(viewModel.filteredGoals) { goal in
                                GoalCardView(
                                    goal: goal,
                                    isExpanded: viewModel.isExpanded(goal),
                                    toggleExpansion: {
                                        viewModel.toggleExpansion(for: goal)
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, TBSpacing.md)
                .padding(.top, TBSpacing.md)
                .padding(.bottom, TBSpacing.xl)
            }
            .scrollIndicators(.hidden)
            .background(background)
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    viewModel.showNewGoalSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(TBColor.textPrimary)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(TBColor.surfaceElevated))
                }
            }
            .sheet(isPresented: $viewModel.showNewGoalSheet) {
                NewGoalSheet(
                    title: $viewModel.newGoalTitle,
                    summary: $viewModel.newGoalSummary,
                    category: $viewModel.newGoalCategory,
                    onSave: viewModel.addGoal,
                    onCancel: { viewModel.showNewGoalSheet = false }
                )
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [TBColor.background, TBColor.surface.opacity(0.45), TBColor.background],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#if DEBUG
struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
            .preferredColorScheme(.dark)
    }
}
#endif
