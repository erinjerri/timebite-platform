import SwiftData
import SwiftUI

struct DashView: View {
    @Query(sort: \Goal.dueDate, order: .forward) private var goals: [Goal]
    @Query(sort: \GoalProgressEntry.date, order: .forward) private var progressEntries: [GoalProgressEntry]
    @State private var selectedGoalID: UUID?

    private var selectedGoal: Goal? {
        if let selectedGoalID, let goal = goals.first(where: { $0.id == selectedGoalID }) {
            return goal
        }
        return goals.first
    }

    private var calendarModel: CompletionCalendarModel {
        CompletionCalendarModel(goal: selectedGoal, progressEntries: progressEntries)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    goalPicker
                    CompletionCalendarView(model: calendarModel)
                }
                .padding(20)
            }
            .background(background)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                selectedGoalID = selectedGoalID ?? goals.first?.id
            }
            .onChange(of: goals.map(\.id)) { _, ids in
                guard let selectedGoalID, ids.contains(selectedGoalID) else {
                    self.selectedGoalID = ids.first
                    return
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Monthly ritual")
                .font(TBTypography.title(.title2, weight: .semibold))
                .foregroundStyle(TBColor.textPrimary)
            Text("A calm view of completion, reflection, and consistency.")
                .font(TBTypography.body())
                .foregroundStyle(TBColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 2)
    }

    @ViewBuilder
    private var goalPicker: some View {
        if goals.count > 1 {
            Picker("Goal", selection: Binding(
                get: { selectedGoalID ?? goals.first?.id },
                set: { selectedGoalID = $0 }
            )) {
                ForEach(goals) { goal in
                    Text(goal.title).tag(Optional(goal.id))
                }
            }
            .pickerStyle(.menu)
            .tint(TBColor.primaryAccent)
            .padding(.horizontal, 2)
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.13, green: 0.11, blue: 0.09),
                TBColor.background,
                Color(red: 0.08, green: 0.08, blue: 0.07)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct CompletionCalendarView: View {
    let model: CompletionCalendarModel
    @State private var visibleMonth: Date
    @State private var selectedDate: Date?
    @State private var slideDirection: Int = 1
    @Environment(\.calendar) private var calendar

    init(model: CompletionCalendarModel) {
        self.model = model
        let month = model.calendar.startOfMonth(for: Date())
        _visibleMonth = State(initialValue: month)
        _selectedDate = State(initialValue: model.calendar.startOfDay(for: Date()))
    }

    private var gridDays: [CompletionCalendarDay] {
        model.days(for: visibleMonth)
    }

    private var selectedDay: CompletionCalendarDay? {
        guard let selectedDate else { return nil }
        return gridDays.first { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            calendarHeader
            weekdayHeader
            dayGrid
            CompletionLegend()
            CompletionSummary(model: model, visibleMonth: visibleMonth, selectedDay: selectedDay)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(TBColor.surface.opacity(0.92))
                .shadow(color: .black.opacity(0.20), radius: 24, x: 0, y: 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var calendarHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.goalTitle)
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.textSecondary)
                Text(model.monthTitle(for: visibleMonth))
                    .font(TBTypography.title(.title2, weight: .semibold))
                    .foregroundStyle(TBColor.textPrimary)
            }

            Spacer()

            monthButton(systemName: "chevron.left") {
                moveMonth(by: -1)
            }
            monthButton(systemName: "chevron.right") {
                moveMonth(by: 1)
            }
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 8) {
            ForEach(model.weekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.textSecondary)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
            }
        }
    }

    private var dayGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 10) {
            ForEach(gridDays) { day in
                CompletionDayCell(
                    day: day,
                    isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: day.date) } ?? false
                ) {
                    selectedDate = day.date
                }
            }
        }
        .id(visibleMonth)
        .transition(.asymmetric(
            insertion: .move(edge: slideDirection >= 0 ? .trailing : .leading).combined(with: .opacity),
            removal: .move(edge: slideDirection >= 0 ? .leading : .trailing).combined(with: .opacity)
        ))
        .animation(.snappy(duration: 0.32), value: visibleMonth)
    }

    private func monthButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(TBColor.textPrimary)
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(TBColor.surfaceElevated)
                        .overlay(Circle().stroke(TBColor.border, lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(systemName == "chevron.left" ? "Previous month" : "Next month")
    }

    private func moveMonth(by value: Int) {
        slideDirection = value
        visibleMonth = calendar.date(byAdding: .month, value: value, to: visibleMonth) ?? visibleMonth
        selectedDate = nil
    }
}

struct CompletionDayCell: View {
    let day: CompletionCalendarDay
    let isSelected: Bool
    let action: () -> Void
    @State private var didAnimateSymbol = false
    @Environment(\.sizeCategory) private var sizeCategory

    private var cellSize: CGFloat {
        sizeCategory.isAccessibilityCategory ? 48 : 40
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(fillColor)
                    .overlay(Circle().stroke(strokeColor, lineWidth: isSelected ? 1.5 : 1))
                    .shadow(color: isSelected ? .black.opacity(0.22) : .clear, radius: 10, x: 0, y: 6)

                symbol
            }
            .frame(width: cellSize, height: cellSize)
            .opacity(day.isInDisplayedMonth ? 1 : 0.26)
            .scaleEffect(isSelected ? 1.05 : 1)
            .padding(.vertical, 2)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(day.accessibilityLabel)
        .onAppear {
            guard day.state == .completed else { return }
            didAnimateSymbol = false
            withAnimation(.spring(response: 0.42, dampingFraction: 0.68).delay(0.05)) {
                didAnimateSymbol = true
            }
        }
    }

    @ViewBuilder
    private var symbol: some View {
        switch day.state {
        case .empty:
            Text("\(day.dayNumber)")
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textSecondary)
        case .completed:
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.white)
                .scaleEffect(didAnimateSymbol ? 1 : 0.72)
        case .partial:
            Image(systemName: "circle.lefthalf.filled")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(TBColor.gold)
        case .missed:
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color(red: 0.98, green: 0.55, blue: 0.46))
        }
    }

    private var fillColor: Color {
        switch day.state {
        case .empty:
            return TBColor.surfaceElevated.opacity(0.72)
        case .completed:
            return TBColor.primaryAccent.opacity(0.82)
        case .partial:
            return TBColor.gold.opacity(0.18)
        case .missed:
            return Color(red: 0.98, green: 0.55, blue: 0.46).opacity(0.15)
        }
    }

    private var strokeColor: Color {
        if isSelected {
            return Color.white.opacity(0.30)
        }

        switch day.state {
        case .empty:
            return Color.white.opacity(0.10)
        case .completed:
            return TBColor.primaryAccent.opacity(0.38)
        case .partial:
            return TBColor.gold.opacity(0.34)
        case .missed:
            return Color(red: 0.98, green: 0.55, blue: 0.46).opacity(0.32)
        }
    }
}

struct CompletionLegend: View {
    var body: some View {
        HStack(spacing: 14) {
            legendItem(label: "Empty", symbol: "○", tint: TBColor.textSecondary)
            legendItem(label: "Completed", symbol: "✓", tint: TBColor.primaryAccent)
            legendItem(label: "Partial", symbol: "◐", tint: TBColor.gold)
            legendItem(label: "Missed", symbol: "✕", tint: Color(red: 0.98, green: 0.55, blue: 0.46))
        }
        .font(TBTypography.caption(.semibold))
        .foregroundStyle(TBColor.textSecondary)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func legendItem(label: String, symbol: String, tint: Color) -> some View {
        HStack(spacing: 5) {
            Text(symbol)
                .foregroundStyle(tint)
            Text(label)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .accessibilityElement(children: .combine)
    }
}

struct CompletionSummary: View {
    let model: CompletionCalendarModel
    let visibleMonth: Date
    let selectedDay: CompletionCalendarDay?

    private var summary: CompletionCalendarSummary {
        model.summary(for: visibleMonth)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                metric("Current streak", value: "\(summary.currentStreak)")
                metric("Longest streak", value: "\(summary.longestStreak)")
                metric("Completion", value: "\(summary.completionPercent)%")
                metric("Monthly completions", value: "\(summary.monthlyCompletions)")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Today's reflection")
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.textSecondary)
                Text(summary.todayReflectionPreview)
                    .font(TBTypography.body())
                    .foregroundStyle(TBColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(TBColor.surfaceElevated.opacity(0.70))
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Weekly progress")
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.textSecondary)
                HStack(spacing: 8) {
                    ForEach(summary.weeklyProgress) { day in
                        weeklyDot(day)
                    }
                }
            }
        }
    }

    private func metric(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(TBTypography.title(.title3, weight: .semibold))
                .foregroundStyle(TBColor.textPrimary)
                .minimumScaleFactor(0.75)
            Text(title)
                .font(TBTypography.caption())
                .foregroundStyle(TBColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(TBColor.surfaceElevated.opacity(0.70))
        )
    }

    private func weeklyDot(_ day: CompletionCalendarDay) -> some View {
        VStack(spacing: 6) {
            Circle()
                .fill(day.state.summaryTint)
                .frame(width: 14, height: 14)
                .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1))
            Text(model.shortWeekday(for: day.date))
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel(day.accessibilityLabel)
    }
}

struct CompletionCalendarModel {
    var goal: Goal?
    var records: [CompletionCalendarRecord]
    var calendar: Calendar

    init(
        goal: Goal?,
        records: [CompletionCalendarRecord],
        calendar: Calendar = .current
    ) {
        self.goal = goal
        self.records = records
        self.calendar = calendar
    }

    init(
        goal: Goal?,
        progressEntries: [GoalProgressEntry],
        calendar: Calendar = .current
    ) {
        self.goal = goal
        self.calendar = calendar

        guard let goal else {
            self.records = []
            return
        }

        self.records = goal.completionHistory(from: progressEntries, calendar: calendar)
    }

    var goalTitle: String {
        goal?.title ?? "No goal selected"
    }

    var weekdaySymbols: [String] {
        calendar.veryShortStandaloneWeekdaySymbols.shiftedToFirstWeekday(calendar.firstWeekday)
    }

    func days(for month: Date) -> [CompletionCalendarDay] {
        let monthStart = calendar.startOfMonth(for: month)
        let range = calendar.range(of: .day, in: .month, for: monthStart) ?? 1..<31
        let daysInMonth = range.count
        let leadingDays = leadingPlaceholderCount(for: monthStart)
        let visibleCount = leadingDays + daysInMonth
        let totalCells = visibleCount <= 35 ? 35 : 42
        let gridStart = calendar.date(byAdding: .day, value: -leadingDays, to: monthStart) ?? monthStart

        return (0..<totalCells).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: gridStart) else { return nil }
            return CompletionCalendarDay(
                date: calendar.startOfDay(for: date),
                state: state(for: date, displayedMonth: monthStart),
                isInDisplayedMonth: calendar.isDate(date, equalTo: monthStart, toGranularity: .month),
                calendar: calendar
            )
        }
    }

    func summary(for month: Date) -> CompletionCalendarSummary {
        let monthDays = days(for: month).filter(\.isInDisplayedMonth)
        let completed = monthDays.filter { $0.state == .completed }.count
        let partial = monthDays.filter { $0.state == .partial }.count
        let missed = monthDays.filter { $0.state == .missed }.count
        let denominator = max(completed + partial + missed, 1)
        let percent = Int((Double(completed) / Double(denominator) * 100).rounded())
        let today = calendar.startOfDay(for: Date())
        let weeklyProgress = weekDays(containing: today).map {
            CompletionCalendarDay(
                date: $0,
                state: state(for: $0, displayedMonth: month),
                isInDisplayedMonth: true,
                calendar: calendar
            )
        }

        return CompletionCalendarSummary(
            currentStreak: currentStreak(endingAt: today),
            longestStreak: longestStreak(),
            completionPercent: percent,
            monthlyCompletions: completed,
            todayReflectionPreview: reflectionPreview(for: today),
            weeklyProgress: weeklyProgress
        )
    }

    func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    func shortWeekday(for date: Date) -> String {
        let index = calendar.component(.weekday, from: date) - 1
        return calendar.veryShortStandaloneWeekdaySymbols[index]
    }

    private func state(for date: Date, displayedMonth: Date) -> CompletionState {
        let day = calendar.startOfDay(for: date)
        if let record = records.first(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
            return record.state
        }

        guard calendar.isDate(day, equalTo: displayedMonth, toGranularity: .month) else {
            return .empty
        }

        if let goal, day >= calendar.startOfDay(for: goal.startDate), day < calendar.startOfDay(for: Date()) {
            return .missed
        }

        return .empty
    }

    private func reflectionPreview(for date: Date) -> String {
        guard let note = records
            .filter({ calendar.isDate($0.date, inSameDayAs: date) })
            .compactMap(\.reflectionPreview)
            .first(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
        else {
            return "No reflection yet. One sentence is enough."
        }
        return note
    }

    private func currentStreak(endingAt date: Date) -> Int {
        var cursor = calendar.startOfDay(for: date)
        var count = 0

        while true {
            let state = stateForStreak(on: cursor)
            if state == .completed {
                count += 1
                cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
            } else if calendar.isDateInToday(cursor) {
                cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
            } else {
                break
            }
        }

        return count
    }

    private func longestStreak() -> Int {
        let completedDays = Set(records.filter { $0.state == .completed }.map { calendar.startOfDay(for: $0.date) }).sorted()
        guard !completedDays.isEmpty else { return 0 }

        var best = 1
        var current = 1

        for index in completedDays.indices.dropFirst() {
            let previous = completedDays[completedDays.index(before: index)]
            let day = completedDays[index]
            let expected = calendar.date(byAdding: .day, value: 1, to: previous) ?? previous
            if calendar.isDate(day, inSameDayAs: expected) {
                current += 1
            } else {
                current = 1
            }
            best = max(best, current)
        }

        return best
    }

    private func stateForStreak(on date: Date) -> CompletionState {
        records.first { calendar.isDate($0.date, inSameDayAs: date) }?.state ?? .empty
    }

    private func weekDays(containing date: Date) -> [Date] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return [date]
        }

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: interval.start).map {
                calendar.startOfDay(for: $0)
            }
        }
    }

    private func leadingPlaceholderCount(for monthStart: Date) -> Int {
        let weekday = calendar.component(.weekday, from: monthStart)
        return (weekday - calendar.firstWeekday + 7) % 7
    }
}

extension Goal {
    func completionHistory(
        from progressEntries: [GoalProgressEntry],
        calendar: Calendar = .current
    ) -> [CompletionCalendarRecord] {
        progressEntries
            .filter { $0.goalId == id }
            .map { CompletionCalendarRecord(progressEntry: $0, calendar: calendar) }
    }
}

struct CompletionCalendarRecord: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let state: CompletionState
    let reflectionPreview: String?

    init(id: UUID = UUID(), date: Date, state: CompletionState, reflectionPreview: String? = nil) {
        self.id = id
        self.date = date
        self.state = state
        self.reflectionPreview = reflectionPreview
    }

    init(progressEntry: GoalProgressEntry, calendar: Calendar) {
        self.id = progressEntry.id
        self.date = calendar.startOfDay(for: progressEntry.date)
        self.state = CompletionState(progressValue: progressEntry.progressValue)
        self.reflectionPreview = progressEntry.note
    }
}

struct CompletionCalendarDay: Identifiable, Hashable {
    let id: Date
    let date: Date
    let state: CompletionState
    let isInDisplayedMonth: Bool
    let dayNumber: Int
    let accessibilityLabel: String

    init(date: Date, state: CompletionState, isInDisplayedMonth: Bool, calendar: Calendar) {
        self.id = date
        self.date = date
        self.state = state
        self.isInDisplayedMonth = isInDisplayedMonth
        self.dayNumber = calendar.component(.day, from: date)

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateStyle = .full
        self.accessibilityLabel = "\(formatter.string(from: date)), \(state.accessibilityLabel)"
    }
}

struct CompletionCalendarSummary {
    let currentStreak: Int
    let longestStreak: Int
    let completionPercent: Int
    let monthlyCompletions: Int
    let todayReflectionPreview: String
    let weeklyProgress: [CompletionCalendarDay]
}

enum CompletionState: Hashable {
    case empty
    case completed
    case partial
    case missed

    init(progressValue: Double) {
        if progressValue >= 1 {
            self = .completed
        } else if progressValue > 0 {
            self = .partial
        } else {
            self = .missed
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .empty:
            return "empty"
        case .completed:
            return "completed"
        case .partial:
            return "partially completed"
        case .missed:
            return "missed"
        }
    }

    var summaryTint: Color {
        switch self {
        case .empty:
            return TBColor.surfaceElevated
        case .completed:
            return TBColor.primaryAccent
        case .partial:
            return TBColor.gold
        case .missed:
            return Color(red: 0.98, green: 0.55, blue: 0.46)
        }
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components).map(startOfDay) ?? startOfDay(for: date)
    }
}

private extension Array where Element == String {
    func shiftedToFirstWeekday(_ firstWeekday: Int) -> [String] {
        guard !isEmpty else { return [] }
        let offset = Swift.max(firstWeekday - 1, 0)
        return Array(dropFirst(offset) + prefix(offset))
    }
}

#if DEBUG
struct DashView_Previews: PreviewProvider {
    static var previews: some View {
        DashView()
            .modelContainer(GoalPreviewData.modelContainer)
            .preferredColorScheme(.dark)

        CompletionCalendarView(model: .preview)
            .padding()
            .background(TBColor.background)
            .preferredColorScheme(.dark)
            .previewDisplayName("Completion Calendar")
    }
}

extension CompletionCalendarModel {
    static var preview: CompletionCalendarModel {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let records: [CompletionCalendarRecord] = (-18...0).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { return nil }
            let state: CompletionState
            switch offset % 5 {
            case 0:
                state = .partial
            case 1:
                state = .missed
            default:
                state = .completed
            }
            return CompletionCalendarRecord(
                date: date,
                state: state,
                reflectionPreview: calendar.isDateInToday(date) ? "Felt calmer after one focused session." : nil
            )
        }

        return CompletionCalendarModel(goal: nil, records: records, calendar: calendar)
    }
}
#endif
