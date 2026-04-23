import Foundation

@MainActor
final class TrackViewModel: ObservableObject {
    @Published var selectedPeriod: TrackPeriod = .daily
    @Published var dailyEntries: [HabitEntry]
    @Published var weeklyMinutes: [Int]
    @Published var heatmapIntensity: [[Double]]
    @Published var newHabitName: String = ""
    @Published var newHabitCategory: CategoryType = .focus
    @Published var showAddSheet: Bool = false

    init(
        selectedPeriod: TrackPeriod = .daily,
        dailyEntries: [HabitEntry],
        weeklyMinutes: [Int],
        heatmapIntensity: [[Double]]
    ) {
        self.selectedPeriod = selectedPeriod
        self.dailyEntries = dailyEntries
        self.weeklyMinutes = weeklyMinutes
        self.heatmapIntensity = heatmapIntensity
    }

    static func mock() -> TrackViewModel {
        TrackViewModel(
            dailyEntries: MockHabitData.dailyEntries,
            weeklyMinutes: MockHabitData.weeklyFocusMinutes,
            heatmapIntensity: MockHabitData.weeklyHeatmapIntensity
        )
    }

    func addHabit() {
        guard !newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        dailyEntries.insert(
            HabitEntry(
                title: newHabitName,
                durationMinutes: 15,
                completed: false,
                category: newHabitCategory,
                note: "New habit added locally"
            ),
            at: 0
        )
        newHabitName = ""
        newHabitCategory = .focus
        showAddSheet = false
    }
}

enum TrackPeriod: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"

    var id: String { rawValue }
}

