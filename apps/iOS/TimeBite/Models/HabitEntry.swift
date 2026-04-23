import SwiftUI

struct HabitEntry: Identifiable, Hashable {
    let id: UUID
    var title: String
    var minutes: Int
    var completed: Bool
    var category: String
    var accent: Color
    var note: String

    init(
        id: UUID = UUID(),
        title: String,
        minutes: Int,
        completed: Bool,
        category: String,
        accent: Color,
        note: String
    ) {
        self.id = id
        self.title = title
        self.minutes = minutes
        self.completed = completed
        self.category = category
        self.accent = accent
        self.note = note
    }
}

extension HabitEntry {
    static let mock: [HabitEntry] = [
        .init(title: "Deep work sprint", minutes: 85, completed: true, category: "Build", accent: TBColor.primaryAccent, note: "Polish the main shell."),
        .init(title: "Walk and reset", minutes: 25, completed: true, category: "Health", accent: TBColor.gold, note: "Keep energy smooth."),
        .init(title: "Inbox triage", minutes: 18, completed: true, category: "Admin", accent: TBColor.secondaryAccent, note: "Clear the quiet noise."),
        .init(title: "Reading block", minutes: 30, completed: false, category: "Growth", accent: Color(red: 0.39, green: 0.77, blue: 0.98), note: "Set up the next idea."),
        .init(title: "Sketch new ideas", minutes: 20, completed: false, category: "Creative", accent: Color(red: 0.92, green: 0.47, blue: 0.82), note: "Low-pressure, open-ended.")
    ]
}

