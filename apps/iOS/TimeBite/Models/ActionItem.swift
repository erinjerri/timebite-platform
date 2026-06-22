import SwiftUI

struct ActionItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var targetMinutes: Int
    var elapsedMinutes: Int
    var streakDays: Int
    var category: String
    var accent: Color
    var note: String

    init(
        id: UUID = UUID(),
        title: String,
        targetMinutes: Int,
        elapsedMinutes: Int,
        streakDays: Int,
        category: String,
        accent: Color,
        note: String
    ) {
        self.id = id
        self.title = title
        self.targetMinutes = targetMinutes
        self.elapsedMinutes = elapsedMinutes
        self.streakDays = streakDays
        self.category = category
        self.accent = accent
        self.note = note
    }

    var progress: Double {
        guard targetMinutes > 0 else { return 0 }
        return min(Double(elapsedMinutes) / Double(targetMinutes), 1)
    }
}

extension ActionItem {
    static let mock = ActionItem(
        title: "Ship the TimeBite MVP shell",
        targetMinutes: 45,
        elapsedMinutes: 18,
        streakDays: 12,
        category: "Build",
        accent: TBColor.primaryAccent,
        note: "One focused session to polish the core loop."
    )
}

