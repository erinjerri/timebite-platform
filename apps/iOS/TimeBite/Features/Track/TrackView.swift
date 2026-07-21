import SwiftData
import SwiftUI

struct TrackView: View {
    @Query(sort: \Goal.dueDate, order: .forward) private var goals: [Goal]
    @Query(sort: \GoalProgressEntry.date, order: .forward) private var progressEntries: [GoalProgressEntry]
    @State private var selectedPeriod: TrackPeriod = .daily
    @State private var habits: [HabitEntry] = []
    @State private var showingAddHabit = false
    @State private var draftTitle = ""
    @State private var draftCategory = "Focus"

    private let weekMinutes = [58, 71, 66, 94, 82, 49, 61]
    private let weeklyAreas = ["Faith", "Fitness/Health", "Finance", "Fun", "Family", "Friends", "Work"]
    /// Pre-aggregated by RollupSvc. The client renders these values without
    /// recomputing time totals or percentages.
    private let labelRollups: [LabelTimeRollup] = []

    private var completionCalendarModel: CompletionCalendarModel {
        CompletionCalendarModel(goal: goals.first, progressEntries: progressEntries)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    segmentedControl

                    switch selectedPeriod {
                    case .daily:
                        dailyCard
                    case .weekly:
                        weeklyCard
                    case .monthly:
                        monthlyCard
                    }
                }
                .padding(16)
            }
            .background(background)
            .navigationTitle("Track")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddHabit) {
                AddHabitSheet(
                    title: $draftTitle,
                    category: $draftCategory,
                    onSave: addHabit,
                    onCancel: { showingAddHabit = false }
                )
                .preferredColorScheme(.dark)
            }
        }
    }

    private var header: some View {
        TBCard {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily rhythm")
                        .font(TBTypography.title(.title2, weight: .semibold))
                        .foregroundStyle(TBColor.textPrimary)
                    Text("Track the day, see the week, and glance at the month.")
                        .font(TBTypography.caption())
                        .foregroundStyle(TBColor.textSecondary)
                }

                Spacer()

                Button {
                    showingAddHabit = true
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
                .buttonStyle(.plain)
            }
        }
    }

    private var segmentedControl: some View {
        TBCard {
            HStack(spacing: 8) {
                ForEach(TrackPeriod.allCases) { period in
                    Button {
                        selectedPeriod = period
                    } label: {
                        Text(period.rawValue)
                            .font(TBTypography.caption(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .foregroundStyle(selectedPeriod == period ? TBColor.textPrimary : TBColor.textSecondary)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(selectedPeriod == period ? TBColor.primaryAccent.opacity(0.18) : TBColor.surfaceElevated)
                                    .overlay(Capsule(style: .continuous).stroke(selectedPeriod == period ? TBColor.primaryAccent.opacity(0.35) : TBColor.border, lineWidth: 1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var dailyCard: some View {
        VStack(spacing: 12) {
            labelRollupCard

            ForEach(habits.isEmpty ? HabitEntry.starter : habits) { habit in
                TBCard {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 6) {
                            Image(systemName: habit.completed ? "checkmark.circle.fill" : LifeAreaCatalog.icon(for: habit.category))
                                .foregroundStyle(habit.completed ? TBColor.primaryAccent : habit.accent)
                                .font(.system(size: 20, weight: .semibold))
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(habit.accent.opacity(0.12)))

                            RoundedRectangle(cornerRadius: 99, style: .continuous)
                                .fill(habit.completed ? TBColor.primaryAccent : TBColor.textSecondary.opacity(0.35))
                                .frame(width: 2, height: 34)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(habit.title)
                                    .font(TBTypography.body(.semibold))
                                    .foregroundStyle(TBColor.textPrimary)
                                Spacer()
                                Text(durationText(habit.minutes))
                                    .font(TBTypography.caption(.semibold))
                                    .foregroundStyle(habit.completed ? TBColor.primaryAccent : TBColor.textSecondary)
                            }

                            Text(habit.note)
                                .font(TBTypography.caption())
                                .foregroundStyle(TBColor.textSecondary)

                            HStack {
                                labelPill(habit.category, tint: habit.accent)
                                Spacer()
                                Text(habit.completed ? "Logged" : "Upcoming")
                                    .font(TBTypography.caption(.semibold))
                                    .foregroundStyle(TBColor.textSecondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private var labelRollupCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    sectionHeader(title: "Time by Work Label", subtitle: "Today · server aggregated")
                    Spacer()
                    Text(durationText(labelRollups.map(\.minutes).reduce(0, +)))
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textPrimary)
                }

                ForEach(labelRollups) { rollup in
                    VStack(alignment: .leading, spacing: 7) {
                        HStack {
                            sharpLabel(rollup.label)
                            Spacer()
                            Text(durationText(rollup.minutes))
                                .font(TBTypography.caption(.semibold))
                                .foregroundStyle(TBColor.textSecondary)
                        }

                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(rollup.label.color.opacity(0.12))
                                Rectangle()
                                    .fill(rollup.label.color)
                                    .frame(width: proxy.size.width * min(max(rollup.serverPercentOfDay, 0), 1))
                            }
                        }
                        .frame(height: 9)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(rollup.label.displayName), \(rollup.minutes) minutes")
                }

                Text("Work Labels are user-defined project tags. They are not Goal Life Areas.")
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
            }
        }
    }

    private var weeklyCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader(title: "Weekly focus", subtitle: "A believable seven-day bar view")

                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(Array(weekMinutes.enumerated()), id: \.offset) { index, value in
                        let area = weeklyAreas[index % weeklyAreas.count]
                        let tint = LifeAreaCatalog.color(for: area)
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(tint)
                                .frame(height: max(CGFloat(value) * 1.5, 28))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(tint.opacity(0.24), lineWidth: 1)
                                )
                            Image(systemName: LifeAreaCatalog.icon(for: area))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(tint)
                            Text(weekday(index))
                                .font(TBTypography.caption(.semibold))
                                .foregroundStyle(TBColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 190)

                HStack {
                    labelPill("Categories visible", tint: TBColor.primaryAccent)
                    Spacer()
                    Text(durationText(weekMinutes.reduce(0, +)))
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textSecondary)
                }
            }
        }
    }

    private var monthlyCard: some View {
        CompletionCalendarView(model: completionCalendarModel)
    }

    private var background: some View {
        LinearGradient(
            colors: [TBColor.background, TBColor.surface.opacity(0.45), TBColor.background],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func addHabit() {
        let habit = HabitEntry(
            title: draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "New local habit" : draftTitle,
            minutes: 15,
            completed: false,
            category: draftCategory,
            accent: LifeAreaCatalog.color(for: draftCategory),
            note: "Locally added from the MVP sheet."
        )
        habits.insert(habit, at: 0)
        draftTitle = ""
        draftCategory = "Focus"
        showingAddHabit = false
    }

    private func weekday(_ index: Int) -> String {
        ["M", "T", "W", "T", "F", "S", "S"][index]
    }

    private func durationText(_ totalMinutes: Int) -> String {
        let minutes = max(totalMinutes, 0)
        guard minutes >= 60 else { return "\(minutes) min" }
        let hours = minutes / 60
        let remainder = minutes % 60
        return remainder == 0 ? "\(hours) hr" : "\(hours) hr \(remainder) min"
    }

    private func labelPill(_ text: String, tint: Color) -> some View {
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

    private func sharpLabel(_ label: WorkLabel) -> some View {
        Text(label.displayName)
            .font(TBTypography.caption(.semibold))
            .foregroundStyle(label.color)
            .padding(.vertical, 6)
            .padding(.horizontal, 9)
            .background(label.color.opacity(0.12))
            .overlay(Rectangle().stroke(label.color.opacity(0.34), lineWidth: 1))
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(TBTypography.title(.headline, weight: .semibold))
                .foregroundStyle(TBColor.textPrimary)
            Text(subtitle)
                .font(TBTypography.caption())
                .foregroundStyle(TBColor.textSecondary)
        }
    }
}

private enum TrackPeriod: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"

    var id: String { rawValue }
}

private struct AddHabitSheet: View {
    @Binding var title: String
    @Binding var category: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit") {
                    TextField("Morning walk", text: $title)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        Text("Focus").tag("Focus")
                        Text("Health").tag("Health")
                        Text("Build").tag("Build")
                        Text("Creative").tag("Creative")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(TBColor.background)
            .navigationTitle("Add Habit")
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
struct TrackView_Previews: PreviewProvider {
    static var previews: some View {
        TrackView().preferredColorScheme(.dark)
    }
}
#endif
