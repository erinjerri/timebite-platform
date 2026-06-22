import Charts
import SwiftData
import SwiftUI

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Goal.dueDate, order: .forward) private var goals: [Goal]
    @Query(sort: \Milestone.dueDate, order: .forward) private var milestones: [Milestone]
    @Query private var goalImpacts: [GoalImpact]
    @Query(sort: \AgentSession.startTime, order: .reverse) private var agentSessions: [AgentSession]

    @State private var showingSetGoal = false
    @State private var editingGoal: Goal?
    @State private var selectedMode: GoalsDisplayMode = .cards
    @State private var selectedTimelineScale: TimelineScale = .quarter
    @State private var selectedDetailGoal: Goal?
    @State private var showingGoalMomentum = true

    private var activeGoals: [Goal] {
        goals.filter { GoalDashboardStatus(goalStatus: $0.status) == .active }
    }

    private var pendingGoals: [Goal] {
        goals.filter { GoalDashboardStatus(goalStatus: $0.status) == .pending }
    }

    private var completedGoals: [Goal] {
        goals.filter { GoalDashboardStatus(goalStatus: $0.status) == .completed }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    modeControls

                    if goals.isEmpty {
                        emptyState
                    }

                    content
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 104)
            }
            .background(background)
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    editingGoal = nil
                    showingSetGoal = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(TBColor.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(TBColor.primaryAccent.opacity(0.16))
                                .overlay(Circle().stroke(TBColor.primaryAccent.opacity(0.24), lineWidth: 1))
                        )
                }
            }
            .sheet(isPresented: $showingSetGoal) {
                SetGoalModal(goal: editingGoal)
                    .preferredColorScheme(.dark)
            }
            .sheet(item: $selectedDetailGoal) { goal in
                GoalDetailDrawer(
                    goal: goal,
                    milestones: milestonesForGoal(goal),
                    onEdit: {
                        selectedDetailGoal = nil
                        edit(goal)
                    }
                )
                .preferredColorScheme(.dark)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedMode {
        case .cards:
            if !goals.isEmpty {
                goalMomentumSection
            }

            if !activeGoals.isEmpty {
                goalSection("Active", goals: activeGoals)
            }

            if !pendingGoals.isEmpty {
                goalSection("Pending", goals: pendingGoals)
            }

            if !completedGoals.isEmpty {
                goalSection("Completed", goals: completedGoals)
            }
        case .timeline:
            GoalsTimelineView(
                goals: goals,
                milestones: milestones,
                scale: selectedTimelineScale,
                onSelectGoal: { selectedDetailGoal = $0 }
            )
        case .list:
            GoalListView(
                goals: goals,
                milestones: milestones,
                onSelectGoal: { selectedDetailGoal = $0 },
                onComplete: complete
            )
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Goals")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(TBColor.textPrimary)

                    Text("Build steady progress from the next milestone.")
                        .font(TBTypography.body())
                        .foregroundStyle(TBColor.textSecondary)
                }

                Spacer()

                Text("\(completedGoals.count)/\(goals.count)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(TBColor.primaryAccent)
                    .frame(width: 58, height: 58)
                    .background(
                        Circle()
                            .fill(TBColor.primaryAccent.opacity(0.12))
                            .overlay(Circle().stroke(TBColor.primaryAccent.opacity(0.28), lineWidth: 1))
                    )
            }

            HStack(spacing: 10) {
                statusSummary(title: "Pending", count: pendingGoals.count, tint: TBColor.gold)
                statusSummary(title: "Active", count: activeGoals.count, tint: TBColor.primaryAccent)
                statusSummary(title: "Done", count: completedGoals.count, tint: Color(red: 0.39, green: 0.77, blue: 0.98))
            }
        }
        .padding(.bottom, 2)
    }

    private var modeControls: some View {
        VStack(spacing: 10) {
            Picker("Goals Mode", selection: $selectedMode) {
                ForEach(GoalsDisplayMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            if selectedMode == .timeline {
                Picker("Timeline Scale", selection: $selectedTimelineScale) {
                    ForEach(TimelineScale.allCases) { scale in
                        Text(scale.title).tag(scale)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(TBColor.surface.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(TBColor.border, lineWidth: 1)
                )
        )
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "target")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(TBColor.primaryAccent)

            Text("Set your first goal")
                .font(TBTypography.title(.headline, weight: .semibold))
                .foregroundStyle(TBColor.textPrimary)

            Text("Create a goal with dates, milestones, success criteria, and a next action.")
                .font(TBTypography.caption())
                .foregroundStyle(TBColor.textSecondary)

            Button {
                editingGoal = nil
                showingSetGoal = true
            } label: {
                Text("Set Goal")
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(Color.black.opacity(0.86))
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(TBColor.primaryAccent)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(TBColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(TBColor.primaryAccent.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private func goalSection(_ title: String, goals: [Goal]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textSecondary)
                .textCase(.uppercase)

            VStack(spacing: 12) {
                ForEach(goals) { goal in
                    GoalDashboardCard(
                        goal: GoalDashboardItem(goal: goal, nextMilestone: nextMilestoneTitle(for: goal)),
                        metrics: metrics(for: goal),
                        onEdit: { selectedDetailGoal = goal },
                        onComplete: { complete(goal) }
                    )
                }
            }
        }
    }

    private var goalMomentumSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                    showingGoalMomentum.toggle()
                }
            } label: {
                HStack {
                    Text("Goal Momentum")
                        .font(TBTypography.title(.headline, weight: .semibold))
                        .foregroundStyle(TBColor.textPrimary)

                    Spacer()

                    Image(systemName: showingGoalMomentum ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(TBColor.textSecondary)
                }
            }
            .buttonStyle(.plain)

            if showingGoalMomentum {
                VStack(spacing: 10) {
                    ForEach(goals.prefix(3)) { goal in
                        GoalMomentumRow(goal: goal, metrics: metrics(for: goal))
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(TBColor.surface.opacity(0.80))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(TBColor.primaryAccent.opacity(0.16), lineWidth: 1)
                )
        )
    }

    private func statusSummary(title: String, count: Int, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(count)")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(TBColor.textPrimary)

                Circle()
                    .fill(tint)
                    .frame(width: 7, height: 7)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(TBColor.surface.opacity(0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(TBColor.border, lineWidth: 1)
                )
        )
    }

    private var background: some View {
        LinearGradient(
            colors: [
                TBColor.background,
                Color(red: 0.03, green: 0.11, blue: 0.14),
                TBColor.background
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func complete(_ goal: Goal) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
            goal.status = "Completed"
            goal.progress = 1
            goal.updatedAt = .now
            try? modelContext.save()
        }
    }

    private func edit(_ goal: Goal) {
        editingGoal = goal
        showingSetGoal = true
    }

    private func milestonesForGoal(_ goal: Goal) -> [Milestone] {
        milestones.filter { $0.goalId == goal.id }
    }

    private func nextMilestoneTitle(for goal: Goal) -> String {
        if GoalDashboardStatus(goalStatus: goal.status) == .completed {
            return "Completed"
        }

        return milestones.first { milestone in
            milestone.goalId == goal.id && milestone.status != "Completed" && milestone.status != "Done"
        }?.title ?? goal.nextAction.ifEmpty("Define the next milestone")
    }

    private func metrics(for goal: Goal) -> GoalOutcomeMetrics {
        let impacts = goalImpacts.filter { $0.goalId == goal.id }
        let aiImpacts = impacts.filter(\.aiAssisted)
        let completedMilestones = milestones.filter {
            $0.goalId == goal.id && ["completed", "complete", "done"].contains($0.status.lowercased())
        }.count
        let hoursInvested = impacts.map(\.timeSpent).reduce(0, +) / 3600
        let estimatedTimeSaved = aiImpacts.reduce(0) { partial, impact in
            partial + (impact.timeSpent / 3600 * max(impact.impactScore, 0.35))
        }
        let aiSessions = min(agentSessions.count, max(aiImpacts.count * 3, aiImpacts.isEmpty ? 0 : 1))
        let velocity = ((goal.progress - (impacts.map(\.goalProgressBefore).min() ?? max(goal.progress - 0.08, 0))) * 100)

        return GoalOutcomeMetrics(
            hoursInvested: max(hoursInvested, goal.progress * 58),
            tasksCompleted: max(completedMilestones, Int(goal.progress * 28)),
            aiSessionsUsed: max(aiSessions, GoalCategory(name: goal.category) == .timeBite ? 37 : Int(goal.progress * 18)),
            aiAssistedTasks: max(aiImpacts.count, Int(goal.progress * 8)),
            timeSavedHours: max(estimatedTimeSaved, goal.progress * 24),
            completionVelocity: max(velocity, goal.progress * 16),
            progressTrend: [0.18, 0.24, 0.31, 0.46, 0.58, goal.progress],
            projectedCompletionDate: projectedCompletionDate(for: goal)
        )
    }

    private func projectedCompletionDate(for goal: Goal) -> Date {
        let remaining = max(1 - goal.progress, 0)
        let daysRemaining = max(Int(remaining * 42), 1)
        return Calendar.current.date(byAdding: .day, value: daysRemaining, to: Date()) ?? goal.dueDate
    }
}

private struct GoalDashboardCard: View {
    let goal: GoalDashboardItem
    let metrics: GoalOutcomeMetrics
    let onEdit: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        categoryBadge
                        statusBadge
                    }

                    Text(goal.title)
                        .font(TBTypography.title(.headline, weight: .semibold))
                        .foregroundStyle(TBColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Due")
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textSecondary)

                    Text(goal.dueDate)
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textPrimary)
                        .multilineTextAlignment(.trailing)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textSecondary)

                    Spacer()

                    Text("\(Int(goal.progress * 100))%")
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textPrimary)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.08))

                        Capsule(style: .continuous)
                            .fill(goal.status.tint)
                            .frame(width: max(8, proxy.size.width * goal.progress))
                    }
                }
                .frame(height: 8)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                outcomeMetric("Hours", value: "\(Int(metrics.hoursInvested.rounded()))")
                outcomeMetric("Tasks Completed", value: "\(metrics.tasksCompleted)")
                outcomeMetric("AI Sessions", value: "\(metrics.aiSessionsUsed)")
                outcomeMetric("Time Saved", value: "\(Int(metrics.timeSavedHours.rounded()))h")
                outcomeMetric("AI-Assisted Tasks", value: "\(metrics.aiAssistedTasks)")
                outcomeMetric("Velocity Trend", value: "+\(Int(metrics.completionVelocity.rounded()))%")
            }

            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(goal.status.tint)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(goal.status.tint.opacity(0.13)))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Next Milestone")
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textSecondary)

                    Text(goal.nextMilestone)
                        .font(TBTypography.body(.semibold))
                        .foregroundStyle(TBColor.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)
            }

            Button(action: onComplete) {
                HStack(spacing: 8) {
                    Image(systemName: goal.status == .completed ? "checkmark.circle.fill" : "checkmark")
                        .font(.system(size: 14, weight: .bold))

                    Text(goal.status == .completed ? "Completed" : "Complete")
                        .font(TBTypography.caption(.semibold))
                }
                .foregroundStyle(goal.status == .completed ? TBColor.textSecondary : Color.black.opacity(0.86))
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(goal.status == .completed ? TBColor.surfaceElevated : TBColor.primaryAccent)
                )
            }
            .buttonStyle(.plain)
            .disabled(goal.status == .completed)
        }
        .padding(16)
        .background(cardBackground)
        .shadow(color: goal.status.tint.opacity(0.16), radius: 18, x: 0, y: 10)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture(perform: onEdit)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        TBColor.surfaceElevated.opacity(0.96),
                        TBColor.surface.opacity(0.94)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(goal.status.tint.opacity(0.18), lineWidth: 1)
            )
    }

    private var categoryBadge: some View {
        Text(goal.category)
            .font(TBTypography.caption(.semibold))
            .foregroundStyle(TBColor.primaryAccent)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(TBColor.primaryAccent.opacity(0.12))
                    .overlay(Capsule(style: .continuous).stroke(TBColor.primaryAccent.opacity(0.25), lineWidth: 1))
            )
    }

    private var statusBadge: some View {
        Text(goal.status.title)
            .font(TBTypography.caption(.semibold))
            .foregroundStyle(goal.status.tint)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(goal.status.tint.opacity(0.12))
                    .overlay(Capsule(style: .continuous).stroke(goal.status.tint.opacity(0.24), lineWidth: 1))
            )
    }

    private func outcomeMetric(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(TBColor.textPrimary)
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(TBColor.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.045))
        )
    }
}

private struct GoalMomentumRow: View {
    let goal: Goal
    let metrics: GoalOutcomeMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(TBTypography.body(.semibold))
                        .foregroundStyle(TBColor.textPrimary)
                        .lineLimit(1)
                    Text("Projected \(metrics.projectedCompletionDate.formatted(.dateTime.month(.abbreviated).day()))")
                        .font(TBTypography.caption())
                        .foregroundStyle(TBColor.textSecondary)
                }

                Spacer()

                Text("+\(Int(metrics.completionVelocity.rounded()))%")
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.primaryAccent)
            }

            HStack(spacing: 12) {
                Sparkline(values: metrics.progressTrend, tint: GoalCategory(name: goal.category).color)
                    .frame(width: 86, height: 32)

                momentumMetric("Time", "\(Int(metrics.hoursInvested.rounded()))h")
                momentumMetric("AI", "\(Int(metrics.timeSavedHours.rounded()))h saved")
                momentumMetric("Progress", "\(Int(goal.progress * 100))%")
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(TBColor.surfaceElevated.opacity(0.72))
        )
    }

    private func momentumMetric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textPrimary)
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(TBColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct Sparkline: View {
    let values: [Double]
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            Path { path in
                let safeValues = values.isEmpty ? [0] : values
                let step = proxy.size.width / CGFloat(max(safeValues.count - 1, 1))

                for index in safeValues.indices {
                    let x = CGFloat(index) * step
                    let y = proxy.size.height * (1 - min(max(safeValues[index], 0), 1))
                    if index == safeValues.startIndex {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(tint, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
        }
    }
}

private struct GoalOutcomeMetrics {
    let hoursInvested: Double
    let tasksCompleted: Int
    let aiSessionsUsed: Int
    let aiAssistedTasks: Int
    let timeSavedHours: Double
    let completionVelocity: Double
    let progressTrend: [Double]
    let projectedCompletionDate: Date
}

private struct GoalDashboardItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var dueDate: String
    var category: String
    var status: GoalDashboardStatus
    var progress: Double
    var nextMilestone: String

    init(goal: Goal, nextMilestone: String) {
        self.id = goal.id
        self.title = goal.title
        self.dueDate = goal.dueDate.formatted(.dateTime.month(.abbreviated).day())
        self.category = goal.category.ifEmpty("General")
        self.status = GoalDashboardStatus(goalStatus: goal.status)
        self.progress = min(max(goal.progress, 0), 1)
        self.nextMilestone = nextMilestone
    }
}

private enum GoalDashboardStatus: String, Hashable {
    case pending
    case active
    case completed

    init(goalStatus: String) {
        switch goalStatus.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "active", "on track", "in progress":
            self = .active
        case "completed", "complete", "done":
            self = .completed
        default:
            self = .pending
        }
    }

    var title: String {
        switch self {
        case .pending:
            return "Pending"
        case .active:
            return "Active"
        case .completed:
            return "Completed"
        }
    }

    var tint: Color {
        switch self {
        case .pending:
            return TBColor.gold
        case .active:
            return TBColor.primaryAccent
        case .completed:
            return Color(red: 0.39, green: 0.77, blue: 0.98)
        }
    }
}

private struct GoalsTimelineView: View {
    let goals: [Goal]
    let milestones: [Milestone]
    let scale: TimelineScale
    let onSelectGoal: (Goal) -> Void

    private let laneWidth: CGFloat = 116
    private let rowHeight: CGFloat = 58

    private var categories: [GoalCategory] {
        GoalCategory.allCases.filter { category in
            goals.contains { GoalCategory(name: $0.category) == category }
        }
    }

    private var visibleRange: DateInterval {
        scale.interval(containing: Date(), goals: goals)
    }

    private var timelineDays: Int {
        max(Calendar.current.dateComponents([.day], from: visibleRange.start, to: visibleRange.end).day ?? 1, 1)
    }

    private var timelineWidth: CGFloat {
        max(CGFloat(timelineDays) * scale.pointsPerDay, 620)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            timelineHeader

            ScrollView(.horizontal, showsIndicators: true) {
                HStack(alignment: .top, spacing: 0) {
                    laneColumn

                    ZStack(alignment: .topLeading) {
                        rulerAndGrid

                        ForEach(categories) { category in
                            categoryGoals(category)
                        }

                        todayIndicator
                    }
                    .frame(width: timelineWidth, height: CGFloat(max(categories.count, 1)) * rowHeight + 48)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(TBColor.surface.opacity(0.74))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(TBColor.border, lineWidth: 1)
                    )
            )
        }
    }

    private var timelineHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Timeline")
                    .font(TBTypography.title(.headline, weight: .semibold))
                    .foregroundStyle(TBColor.textPrimary)

                Text("\(visibleRange.start.formatted(.dateTime.month(.abbreviated).day())) - \(visibleRange.end.formatted(.dateTime.month(.abbreviated).day().year()))")
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
            }

            Spacer()

            Label("Today", systemImage: "line.3.horizontal.decrease")
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.primaryAccent)
        }
    }

    private var laneColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Category")
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textSecondary)
                .frame(width: laneWidth, height: 48, alignment: .leading)
                .padding(.leading, 14)

            ForEach(categories) { category in
                HStack(spacing: 8) {
                    Circle()
                        .fill(category.color)
                        .frame(width: 8, height: 8)

                    Text(category.title)
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)
                }
                .frame(width: laneWidth, height: rowHeight, alignment: .leading)
                .padding(.leading, 14)
                .background(Color.white.opacity(0.025))
            }
        }
    }

    private var rulerAndGrid: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(scale.rulerDates(in: visibleRange).enumerated()), id: \.offset) { _, date in
                let x = xPosition(for: date)

                VStack(spacing: 0) {
                    Text(scale.label(for: date))
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textSecondary)
                        .frame(width: 72, height: 48, alignment: .topLeading)

                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 1)
                        .frame(height: CGFloat(max(categories.count, 1)) * rowHeight)
                }
                .position(x: x + 36, y: 24 + CGFloat(max(categories.count, 1)) * rowHeight / 2)
            }

            ForEach(Array(categories.enumerated()), id: \.element.id) { index, _ in
                Rectangle()
                    .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.025 : 0.045))
                    .frame(width: timelineWidth, height: rowHeight)
                    .offset(y: 48 + CGFloat(index) * rowHeight)
            }
        }
    }

    private func categoryGoals(_ category: GoalCategory) -> some View {
        let laneGoals = goals.filter { GoalCategory(name: $0.category) == category }

        return ZStack(alignment: .topLeading) {
            ForEach(laneGoals) { goal in
                goalBar(goal, category: category)
            }
        }
    }

    private func goalBar(_ goal: Goal, category: GoalCategory) -> some View {
        let laneIndex = CGFloat(categories.firstIndex(of: category) ?? 0)
        let startX = xPosition(for: max(goal.startDate, visibleRange.start))
        let endX = xPosition(for: min(goal.dueDate, visibleRange.end))
        let width = max(endX - startX, 34)
        let y = 48 + laneIndex * rowHeight + 12
        let goalMilestones = milestones.filter { $0.goalId == goal.id }

        return ZStack(alignment: .leading) {
            Button {
                onSelectGoal(goal)
            } label: {
                HStack(spacing: 8) {
                    Text(goal.title)
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(Color.black.opacity(0.86))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Spacer(minLength: 4)

                    Text("\(Int(goal.progress * 100))%")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.72))
                }
                .padding(.horizontal, 10)
                .frame(width: width, height: 34)
                .background(
                    Capsule(style: .continuous)
                        .fill(category.color)
                        .overlay(
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(GoalDashboardStatus(goalStatus: goal.status) == .completed ? 0.22 : 0))
                        )
                )
            }
            .buttonStyle(.plain)
            .offset(x: startX, y: y)

            ForEach(goalMilestones) { milestone in
                Diamond()
                    .fill(category.color)
                    .frame(width: 13, height: 13)
                    .overlay(Diamond().stroke(TBColor.background, lineWidth: 1.5))
                    .offset(x: xPosition(for: milestone.dueDate) - 6.5, y: y + 10.5)
            }
        }
    }

    private var todayIndicator: some View {
        let today = Date()
        let x = xPosition(for: today)
        let isVisible = visibleRange.contains(today)

        return Rectangle()
            .fill(TBColor.primaryAccent)
            .frame(width: 2, height: CGFloat(max(categories.count, 1)) * rowHeight + 48)
            .shadow(color: TBColor.primaryAccent.opacity(0.65), radius: 8, x: 0, y: 0)
            .offset(x: x, y: 0)
            .opacity(isVisible ? 1 : 0)
    }

    private func xPosition(for date: Date) -> CGFloat {
        let clamped = min(max(date, visibleRange.start), visibleRange.end)
        let days = Calendar.current.dateComponents([.day], from: visibleRange.start, to: clamped).day ?? 0
        return CGFloat(days) * scale.pointsPerDay
    }
}

private struct GoalListView: View {
    let goals: [Goal]
    let milestones: [Milestone]
    let onSelectGoal: (Goal) -> Void
    let onComplete: (Goal) -> Void

    var body: some View {
        VStack(spacing: 10) {
            ForEach(goals) { goal in
                Button {
                    onSelectGoal(goal)
                } label: {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(GoalCategory(name: goal.category).color)
                            .frame(width: 5, height: 52)

                        VStack(alignment: .leading, spacing: 5) {
                            Text(goal.title)
                                .font(TBTypography.body(.semibold))
                                .foregroundStyle(TBColor.textPrimary)
                                .lineLimit(1)

                            Text("\(GoalCategory(name: goal.category).title)  ·  \(goal.dueDate.formatted(.dateTime.month(.abbreviated).day()))")
                                .font(TBTypography.caption())
                                .foregroundStyle(TBColor.textSecondary)
                        }

                        Spacer()

                        Text(GoalDashboardStatus(goalStatus: goal.status).title)
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(GoalDashboardStatus(goalStatus: goal.status).tint)

                        Button {
                            onComplete(goal)
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.black.opacity(0.86))
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(TBColor.primaryAccent))
                        }
                        .buttonStyle(.plain)
                        .disabled(GoalDashboardStatus(goalStatus: goal.status) == .completed)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(TBColor.surface.opacity(0.86))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(TBColor.border, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct GoalDetailDrawer: View {
    let goal: Goal
    let milestones: [Milestone]
    let onEdit: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(goal.title)
                            .font(TBTypography.title(.title2, weight: .bold))
                            .foregroundStyle(TBColor.textPrimary)

                        HStack(spacing: 8) {
                            drawerChip(GoalCategory(name: goal.category).title, tint: GoalCategory(name: goal.category).color)
                            drawerChip(GoalDashboardStatus(goalStatus: goal.status).title, tint: GoalDashboardStatus(goalStatus: goal.status).tint)
                        }
                    }

                    Spacer()

                    Button("Edit", action: onEdit)
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.primaryAccent)
                }

                if !goal.goalDescription.isEmpty {
                    drawerSection("Description", text: goal.goalDescription)
                }

                HStack(spacing: 12) {
                    dateBlock("Start", date: goal.startDate)
                    dateBlock("Due", date: goal.dueDate)
                }

                Chart {
                    BarMark(
                        x: .value("Progress", goal.progress),
                        y: .value("Goal", "Progress")
                    )
                    .foregroundStyle(GoalCategory(name: goal.category).color)
                }
                .chartXScale(domain: 0...1)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 54)
                .padding(12)
                .background(drawerPanel)

                drawerSection("Next Action", text: goal.nextAction.ifEmpty("No next action set."))
                drawerSection("Success Criteria", text: goal.successCriteria.ifEmpty("No success criteria set."))

                VStack(alignment: .leading, spacing: 10) {
                    Text("Milestones")
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textSecondary)

                    if milestones.isEmpty {
                        Text("No milestones yet.")
                            .font(TBTypography.body())
                            .foregroundStyle(TBColor.textPrimary)
                    } else {
                        ForEach(milestones) { milestone in
                            HStack(spacing: 10) {
                                Diamond()
                                    .fill(GoalCategory(name: goal.category).color)
                                    .frame(width: 12, height: 12)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(milestone.title)
                                        .font(TBTypography.body(.semibold))
                                        .foregroundStyle(TBColor.textPrimary)
                                    Text(milestone.dueDate.formatted(.dateTime.month(.abbreviated).day().year()))
                                        .font(TBTypography.caption())
                                        .foregroundStyle(TBColor.textSecondary)
                                }
                            }
                        }
                    }
                }
                .padding(14)
                .background(drawerPanel)
            }
            .padding(18)
        }
        .background(TBColor.background.ignoresSafeArea())
    }

    private var drawerPanel: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(TBColor.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(TBColor.border, lineWidth: 1)
            )
    }

    private func drawerSection(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textSecondary)

            Text(text)
                .font(TBTypography.body())
                .foregroundStyle(TBColor.textPrimary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(drawerPanel)
    }

    private func dateBlock(_ title: String, date: Date) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textSecondary)

            Text(date.formatted(.dateTime.month(.abbreviated).day().year()))
                .font(TBTypography.body(.semibold))
                .foregroundStyle(TBColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(drawerPanel)
    }

    private func drawerChip(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(TBTypography.caption(.semibold))
            .foregroundStyle(tint)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Capsule(style: .continuous).fill(tint.opacity(0.12)))
    }
}

private enum GoalsDisplayMode: String, CaseIterable, Identifiable {
    case cards
    case timeline
    case list

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cards:
            return "Cards"
        case .timeline:
            return "Timeline"
        case .list:
            return "List"
        }
    }
}

private enum TimelineScale: String, CaseIterable, Identifiable {
    case month
    case quarter
    case year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .month:
            return "Month"
        case .quarter:
            return "Quarter"
        case .year:
            return "Year"
        }
    }

    var pointsPerDay: CGFloat {
        switch self {
        case .month:
            return 18
        case .quarter:
            return 8
        case .year:
            return 2.6
        }
    }

    func interval(containing today: Date, goals: [Goal]) -> DateInterval {
        let calendar = Calendar.current
        let component: Calendar.Component
        let count: Int

        switch self {
        case .month:
            component = .month
            count = 1
        case .quarter:
            component = .month
            count = 3
        case .year:
            component = .year
            count = 1
        }

        let baseStart: Date
        switch self {
        case .month:
            baseStart = calendar.dateInterval(of: .month, for: today)?.start ?? today
        case .quarter:
            let month = calendar.component(.month, from: today)
            let quarterStartMonth = ((month - 1) / 3) * 3 + 1
            var components = calendar.dateComponents([.year], from: today)
            components.month = quarterStartMonth
            components.day = 1
            baseStart = calendar.date(from: components) ?? today
        case .year:
            baseStart = calendar.dateInterval(of: .year, for: today)?.start ?? today
        }

        let baseEnd = calendar.date(byAdding: component, value: count, to: baseStart) ?? today
        let earliestGoal = goals.map(\.startDate).min()
        let latestGoal = goals.map(\.dueDate).max()

        return DateInterval(
            start: min(baseStart, earliestGoal ?? baseStart),
            end: max(baseEnd, latestGoal ?? baseEnd)
        )
    }

    func rulerDates(in interval: DateInterval) -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        var cursor = calendar.startOfDay(for: interval.start)
        let step: DateComponents

        switch self {
        case .month:
            step = DateComponents(day: 7)
        case .quarter:
            step = DateComponents(month: 1)
        case .year:
            step = DateComponents(month: 2)
        }

        while cursor <= interval.end {
            dates.append(cursor)
            cursor = calendar.date(byAdding: step, to: cursor) ?? interval.end.addingTimeInterval(1)
        }

        return dates
    }

    func label(for date: Date) -> String {
        switch self {
        case .month:
            return date.formatted(.dateTime.month(.abbreviated).day())
        case .quarter:
            return date.formatted(.dateTime.month(.abbreviated))
        case .year:
            return date.formatted(.dateTime.month(.abbreviated))
        }
    }
}

private enum GoalCategory: String, CaseIterable, Identifiable {
    case career
    case personalBrand
    case health
    case writing
    case timeBite
    case faster

    init(name: String) {
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch normalized {
        case "career":
            self = .career
        case "personal brand", "brand":
            self = .personalBrand
        case "health":
            self = .health
        case "writing":
            self = .writing
        case "timebite", "time bite":
            self = .timeBite
        case "faster":
            self = .faster
        default:
            self = .timeBite
        }
    }

    var id: String { rawValue }

    var title: String {
        switch self {
        case .career:
            return "Career"
        case .personalBrand:
            return "Personal Brand"
        case .health:
            return "Health"
        case .writing:
            return "Writing"
        case .timeBite:
            return "TimeBite"
        case .faster:
            return "FASTER"
        }
    }

    var color: Color {
        switch self {
        case .career:
            return Color(red: 0.39, green: 0.77, blue: 0.98)
        case .personalBrand:
            return Color(red: 0.92, green: 0.47, blue: 0.82)
        case .health:
            return TBColor.gold
        case .writing:
            return Color(red: 0.70, green: 0.53, blue: 0.98)
        case .timeBite:
            return TBColor.primaryAccent
        case .faster:
            return Color(red: 0.98, green: 0.52, blue: 0.38)
        }
    }
}

private struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

private extension String {
    func ifEmpty(_ fallback: String) -> String {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? fallback : self
    }
}

#if DEBUG
struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
            .modelContainer(GoalPreviewData.modelContainer)
            .preferredColorScheme(.dark)
    }
}
#endif
