import SwiftUI

struct GoalItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var phase: String
    var summary: String
    var progress: Double
    var status: String
    var statusTint: Color
    var category: String
    var accent: Color
    var dueDate: String
    var badges: [String]
    var details: [String]

    init(
        id: UUID = UUID(),
        title: String,
        phase: String,
        summary: String,
        progress: Double,
        status: String,
        statusTint: Color,
        category: String,
        accent: Color,
        dueDate: String,
        badges: [String],
        details: [String]
    ) {
        self.id = id
        self.title = title
        self.phase = phase
        self.summary = summary
        self.progress = progress
        self.status = status
        self.statusTint = statusTint
        self.category = category
        self.accent = accent
        self.dueDate = dueDate
        self.badges = badges
        self.details = details
    }
}

extension GoalItem {
    static let mock: [GoalItem] = [
        .init(
            title: "Launch TimeBite iPhone MVP",
            phase: "Short-Term",
            summary: "Deliver the polished 4-tab loop with local mock data and a portfolio-grade shell.",
            progress: 0.76,
            status: "Active",
            statusTint: TBColor.primaryAccent,
            category: "Build",
            accent: TBColor.primaryAccent,
            dueDate: "May 24, 2026",
            badges: ["MVP", "iPhone-first", "Local data"],
            details: ["Keep the surface calm and tactile.", "Bias the app toward the next action.", "Use the mock data to tell a believable story."]
        ),
        .init(
            title: "Grow consistent execution",
            phase: "Intermediate",
            summary: "Make one action, one log, and one reflection feel natural every day.",
            progress: 0.58,
            status: "On Track",
            statusTint: Color(red: 0.39, green: 0.77, blue: 0.98),
            category: "Growth",
            accent: Color(red: 0.39, green: 0.77, blue: 0.98),
            dueDate: "Jun 30, 2026",
            badges: ["Streak", "Reflection", "Focus"],
            details: ["Keep the loop small.", "Show progress immediately.", "Avoid cluttering the flow."]
        ),
        .init(
            title: "Protect recovery and deep work",
            phase: "Long-Term",
            summary: "Balance intense focus with visible recovery so the app feels sustainable.",
            progress: 0.34,
            status: "At Risk",
            statusTint: TBColor.gold,
            category: "Health",
            accent: TBColor.gold,
            dueDate: "Q3 2026",
            badges: ["Balance", "Energy", "Recovery"],
            details: ["Keep the tone premium and grounded.", "Use charts sparingly.", "Make the ring the star when it matters."]
        )
    ]
}

