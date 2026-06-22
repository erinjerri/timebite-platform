import SwiftUI

struct GoalsView: View {
    @State private var selectedFilter: String = "All"
    @State private var goals: [GoalItem] = GoalItem.mock
    @State private var expandedGoalIDs: Set<UUID> = []
    @State private var showingNewGoal = false
    @State private var draftTitle = ""
    @State private var draftSummary = ""
    @State private var draftPhase = "Short-Term"

    private let filters = ["All", "Build", "Growth", "Health", "Creative"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    filtersRow
                    goalCards
                }
                .padding(16)
            }
            .background(background)
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    showingNewGoal = true
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
            .sheet(isPresented: $showingNewGoal) {
                NewGoalSheet(
                    title: $draftTitle,
                    summary: $draftSummary,
                    phase: $draftPhase,
                    onSave: addGoal,
                    onCancel: { showingNewGoal = false }
                )
                .preferredColorScheme(.dark)
            }
        }
    }

    private var header: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("GROW framework")
                    .font(TBTypography.caption(.semibold))
                    .tracking(1.2)
                    .foregroundStyle(TBColor.textSecondary)

                Text("Goals that move from intention into clean commitments.")
                    .font(TBTypography.title(.title2, weight: .semibold))
                    .foregroundStyle(TBColor.textPrimary)

                HStack(spacing: 10) {
                    growBadge(initial: "G", title: "Goal", subtitle: "What does success look like?")
                    growBadge(initial: "R", title: "Reality", subtitle: "Where are you now?")
                }

                HStack(spacing: 10) {
                    growBadge(initial: "O", title: "Options", subtitle: "What paths exist?")
                    growBadge(initial: "W", title: "Will", subtitle: "What is the next commitment?")
                }
            }
        }
    }

    private var filtersRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter)
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(selectedFilter == filter ? TBColor.textPrimary : TBColor.textSecondary)
                            .padding(.vertical, 9)
                            .padding(.horizontal, 14)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(selectedFilter == filter ? TBColor.primaryAccent.opacity(0.18) : TBColor.surfaceElevated)
                                    .overlay(Capsule(style: .continuous).stroke(selectedFilter == filter ? TBColor.primaryAccent.opacity(0.35) : TBColor.border, lineWidth: 1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var goalCards: some View {
        let filtered = selectedFilter == "All" ? goals : goals.filter { $0.category == selectedFilter }

        return VStack(spacing: 12) {
            ForEach(filtered) { goal in
                TBCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    tag(goal.phase, tint: goal.accent)
                                    tag(goal.status, tint: goal.statusTint)
                                }

                                Text(goal.title)
                                    .font(TBTypography.title(.headline, weight: .semibold))
                                    .foregroundStyle(TBColor.textPrimary)

                                Text(goal.summary)
                                    .font(TBTypography.caption())
                                    .foregroundStyle(TBColor.textSecondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 6) {
                                Text(goal.dueDate)
                                    .font(TBTypography.caption(.semibold))
                                    .foregroundStyle(TBColor.textPrimary)
                                Text("\(Int(goal.progress * 100))%")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(TBColor.textPrimary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            ProgressView(value: goal.progress)
                                .tint(goal.accent)
                            HStack {
                                Text(goal.badges.first ?? "Focus")
                                    .font(TBTypography.caption())
                                    .foregroundStyle(TBColor.textSecondary)
                                Spacer()
                                Text(goal.badges.last ?? "Next step")
                                    .font(TBTypography.caption())
                                    .foregroundStyle(TBColor.textSecondary)
                            }
                        }

                        HStack(spacing: 8) {
                            ForEach(goal.badges, id: \.self) { badge in
                                tag(badge, tint: TBColor.surfaceElevated)
                            }
                        }

                        Button {
                            toggle(goal)
                        } label: {
                            HStack {
                                Text(expandedGoalIDs.contains(goal.id) ? "Hide details" : "Show details")
                                    .font(TBTypography.caption(.semibold))
                                Spacer()
                                Image(systemName: expandedGoalIDs.contains(goal.id) ? "chevron.up" : "chevron.down")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(TBColor.textSecondary)
                        }
                        .buttonStyle(.plain)

                        if expandedGoalIDs.contains(goal.id) {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(goal.details, id: \.self) { detail in
                                    HStack(alignment: .top, spacing: 8) {
                                        Circle()
                                            .fill(goal.accent)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 5)
                                        Text(detail)
                                            .font(TBTypography.caption())
                                            .foregroundStyle(TBColor.textSecondary)
                                    }
                                }
                            }
                            .padding(.top, 2)
                        }
                    }
                }
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [TBColor.background, TBColor.surface.opacity(0.42), TBColor.background],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func addGoal() {
        let goal = GoalItem(
            title: draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "New local goal" : draftTitle,
            phase: draftPhase,
            summary: draftSummary.isEmpty ? "Added locally in the MVP." : draftSummary,
            progress: 0.14,
            status: "Active",
            statusTint: TBColor.primaryAccent,
            category: "Build",
            accent: TBColor.primaryAccent,
            dueDate: "TBD",
            badges: ["New", "Local"],
            details: ["Goal added from the lightweight sheet.", "Refine this later if the product needs it."]
        )
        goals.insert(goal, at: 0)
        draftTitle = ""
        draftSummary = ""
        draftPhase = "Short-Term"
        showingNewGoal = false
    }

    private func toggle(_ goal: GoalItem) {
        if expandedGoalIDs.contains(goal.id) {
            expandedGoalIDs.remove(goal.id)
        } else {
            expandedGoalIDs.insert(goal.id)
        }
    }

    private func growBadge(initial: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(initial)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(TBColor.primaryAccent)
                .frame(width: 34, height: 34)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(TBColor.primaryAccent.opacity(0.12)))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TBTypography.body(.semibold))
                    .foregroundStyle(TBColor.textPrimary)
                Text(subtitle)
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(TBColor.surfaceElevated)
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(TBColor.border, lineWidth: 1))
        )
    }

    private func tag(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(TBTypography.caption(.semibold))
            .foregroundStyle(tint)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(tint.opacity(0.12))
                    .overlay(Capsule(style: .continuous).stroke(tint.opacity(0.25), lineWidth: 1))
            )
    }
}

private struct NewGoalSheet: View {
    @Binding var title: String
    @Binding var summary: String
    @Binding var phase: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    TextField("Launch the MVP", text: $title)
                    TextField("Short summary", text: $summary)
                }

                Section("Phase") {
                    Picker("Phase", selection: $phase) {
                        Text("Short-Term").tag("Short-Term")
                        Text("Intermediate").tag("Intermediate")
                        Text("Long-Term").tag("Long-Term")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(TBColor.background)
            .navigationTitle("New Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#if DEBUG
struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView().preferredColorScheme(.dark)
    }
}
#endif

