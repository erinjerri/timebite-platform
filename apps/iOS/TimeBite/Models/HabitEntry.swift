import SwiftUI

struct HabitEntry: Identifiable, Hashable {
    let id: UUID
    var title: String
    var minutes: Int
    var completed: Bool
    var category: String
    var note: String

    var accent: Color {
        completed ? TBColor.primaryAccent : TBColor.blue
    }

    init(
        id: UUID = UUID(),
        title: String,
        minutes: Int,
        completed: Bool,
        category: String,
        note: String
    ) {
        self.id = id
        self.title = title
        self.minutes = minutes
        self.completed = completed
        self.category = category
        self.note = note
    }
}

extension HabitEntry {
    static let mock: [HabitEntry] = [
        .init(title: "Deep work sprint", minutes: 85, completed: true, category: "Build", note: "Polish the main shell."),
        .init(title: "Walk and reset", minutes: 25, completed: true, category: "Health", note: "Keep energy smooth."),
        .init(title: "Inbox triage", minutes: 18, completed: true, category: "Admin", note: "Clear the quiet noise."),
        .init(title: "Reading block", minutes: 30, completed: false, category: "Growth", note: "Set up the next idea."),
        .init(title: "Sketch new ideas", minutes: 20, completed: false, category: "Creative", note: "Low-pressure, open-ended.")
    ]
}
