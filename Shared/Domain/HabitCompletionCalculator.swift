import Foundation

enum HabitCompletionCalculator {
    static func isComplete(log: HabitLog, habit: Habit) -> Bool {
        log.completedMinutes >= habit.targetMinutes
    }
}
