import SwiftData
import SwiftUI

struct TrackView: View {
    @Query(sort: \Goal.dueDate, order: .forward) private var goals: [Goal]
    @Query(sort: \GoalProgressEntry.date, order: .forward) private var progressEntries: [GoalProgressEntry]
    @State private var selectedPeriod: TrackPeriod = .daily
    @State private var habits: [HabitEntry] = HabitEntry.mock
    @State private var showingAddHabit = false
    @State private var draftTitle = ""
    @State private var draftCategory = "Focus"

    private let weekMinutes = [58, 71, 66, 94, 82, 49, 61]
    /// Pre-aggregated by RollupSvc. The client renders these values without
    /// recomputing time totals or percentages.
    private let labelRollups = LabelTimeRollup.serverSamples

    private var completionCalendarModel: CompletionCalendarModel {
        CompletionCalendarModel(goal: goals.first, progressEntries: progressEntries)
    }

    private var weekTotalMinutes: Int {
        weekMinutes.reduce(0, +)
    }

    private var isMomentumMilestoneWeek: Bool {
        weekMinutes.allSatisfy { $0 >= 60 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
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
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(TBColor.textPrimary)
                    }
                    .accessibilityLabel("Add habit")
                }
            }
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
            HabitDurationList(habits: habits)
        }
    }

    private var labelRollupCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    sectionHeader(title: "Time by Work Label", subtitle: "Today · server aggregated")
                    Spacer()
                    Text(labelRollups.map(\.minutes).reduce(0, +).formattedMinutes)
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textPrimary)
                }

                ForEach(labelRollups) { rollup in
                    let tint = trackTint(for: rollup.label)
                    VStack(alignment: .leading, spacing: 7) {
                        HStack {
                            sharpLabel(rollup.label, tint: tint)
                            Spacer()
                            Text(rollup.minutes.formattedMinutes)
                                .font(TBTypography.caption(.semibold))
                                .foregroundStyle(TBColor.textSecondary)
                        }

                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(tint.opacity(0.12))
                                Rectangle()
                                    .fill(tint)
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
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(TBColor.primaryAccent)
                                .frame(height: max(CGFloat(value) * 1.5, 28))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(TBColor.primaryAccent.opacity(0.18), lineWidth: 1)
                                )
                            Text(weekday(index))
                                .font(TBTypography.caption(.semibold))
                                .foregroundStyle(TBColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 190)

                HStack {
                    if isMomentumMilestoneWeek {
                        MilestoneMomentumPill(text: "Momentum is up")
                    } else {
                        labelPill("Momentum is up", tint: TBColor.primaryAccent)
                    }
                    Spacer()
                    Text("\(weekTotalMinutes.formattedMinutes) total")
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

    private func sharpLabel(_ label: WorkLabel, tint: Color) -> some View {
        Text(label.displayName)
            .font(TBTypography.caption(.semibold))
            .foregroundStyle(tint)
            .padding(.vertical, 6)
            .padding(.horizontal, 9)
            .background(tint.opacity(0.12))
            .overlay(Rectangle().stroke(tint.opacity(0.34), lineWidth: 1))
    }

    private func trackTint(for label: WorkLabel) -> Color {
        label.colorIndex.isMultiple(of: 2) ? TBColor.primaryAccent : TBColor.blue
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

private struct HabitDurationList: View {
    let habits: [HabitEntry]

    private var maxMinutes: Int {
        max(habits.map(\.minutes).max() ?? 1, 1)
    }

    var body: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 14) {
                TrackSectionHeader(title: "Daily tasks", subtitle: "Duration-weighted view")

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(habits) { habit in
                        HabitDurationRow(
                            habit: habit,
                            fraction: Double(habit.minutes) / Double(maxMinutes)
                        )
                    }
                }
            }
        }
    }
}

private struct HabitDurationRow: View {
    let habit: HabitEntry
    let fraction: Double

    var body: some View {
        GeometryReader { proxy in
            let labelReserve = min(max(proxy.size.width * 0.46, 138), 210)
            let barSpace = max(proxy.size.width - labelReserve - 10, 80)
            let normalizedFraction = CGFloat(min(max(fraction, 0), 1))
            let segmentWidth = max(barSpace * normalizedFraction, 18)

            HStack(alignment: .center, spacing: 10) {
                Capsule(style: .continuous)
                    .fill(habit.accent.opacity(0.82))
                    .frame(width: segmentWidth, height: 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(habit.accent.opacity(0.12))
                            .frame(width: barSpace, height: 6),
                        alignment: .leading
                    )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(habit.title)
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(TBColor.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.74)
                        Text(habit.minutes.formattedMinutes)
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(habit.accent)
                            .lineLimit(1)
                    }

                    Text(habit.category)
                        .font(TBTypography.caption())
                        .foregroundStyle(TBColor.textSecondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: 32)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(habit.title), \(habit.minutes.formattedMinutes), \(habit.category), \(habit.completed ? "logged" : "upcoming")")
    }
}

private struct MilestoneMomentumPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(TBTypography.caption(.semibold))
            .foregroundStyle(TBColor.textPrimary)
            .padding(.vertical, 7)
            .padding(.horizontal, 12)
            .background {
                Capsule(style: .continuous)
                    .fill(Color.black.opacity(0.92))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [TBColor.primaryAccent, TBColor.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: TBColor.primaryAccent.opacity(0.42), radius: 12)
                    .shadow(color: TBColor.blue.opacity(0.30), radius: 18)
            }
    }
}

private struct TrackSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
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

private extension Int {
    var formattedMinutes: String {
        guard self >= 60 else {
            return "\(self)m"
        }

        let hours = self / 60
        let minutes = self % 60

        guard minutes > 0 else {
            return "\(hours)h"
        }

        return "\(hours)h \(minutes)m"
    }
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
