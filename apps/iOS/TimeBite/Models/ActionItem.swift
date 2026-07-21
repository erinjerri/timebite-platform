import SwiftUI

struct ActionItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var targetMinutes: Int
    var elapsedMinutes: Int
    var scheduledStart: Date
    /// Canonical progress returned by TaskSvc. The client never derives this
    /// value from elapsed and estimated duration.
    var serverPercentComplete: Double
    var streakDays: Int
    var category: String
    var labelID: UUID?
    var accent: Color
    var note: String

    init(
        id: UUID = UUID(),
        title: String,
        targetMinutes: Int,
        elapsedMinutes: Int,
        scheduledStart: Date = .now,
        serverPercentComplete: Double,
        streakDays: Int,
        category: String,
        labelID: UUID? = nil,
        accent: Color,
        note: String
    ) {
        self.id = id
        self.title = title
        self.targetMinutes = targetMinutes
        self.elapsedMinutes = elapsedMinutes
        self.scheduledStart = scheduledStart
        self.serverPercentComplete = serverPercentComplete
        self.streakDays = streakDays
        self.category = category
        self.labelID = labelID
        self.accent = accent
        self.note = note
    }

    var progress: Double {
        min(max(serverPercentComplete, 0), 1)
    }
}

struct WorkLabel: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var colorIndex: Int

    init(id: UUID = UUID(), name: String, colorIndex: Int) {
        self.id = id
        self.name = name
        self.colorIndex = colorIndex
    }

    var displayName: String {
        name.hasPrefix("#") ? name : "#\(name)"
    }

    var color: Color {
        WorkLabel.palette[colorIndex % WorkLabel.palette.count]
    }

    static let palette: [Color] = [
        TBColor.primaryAccent,
        Color(red: 0.39, green: 0.77, blue: 0.98),
        Color(red: 0.92, green: 0.47, blue: 0.82),
        TBColor.gold,
        Color(red: 0.98, green: 0.52, blue: 0.38),
        Color(red: 0.70, green: 0.53, blue: 0.98)
    ]

#if DEBUG
    static let samples: [WorkLabel] = [
        .init(id: UUID(uuidString: "071E74DA-EAA1-4DF7-9E03-000000000001")!, name: "product", colorIndex: 0),
        .init(id: UUID(uuidString: "071E74DA-EAA1-4DF7-9E03-000000000002")!, name: "growth", colorIndex: 1),
        .init(id: UUID(uuidString: "071E74DA-EAA1-4DF7-9E03-000000000003")!, name: "mobile app", colorIndex: 2),
        .init(id: UUID(uuidString: "071E74DA-EAA1-4DF7-9E03-000000000004")!, name: "bugs", colorIndex: 3)
    ]
#endif
}

struct ActionQueueItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var estimatedDurationMinutes: Int
    var elapsedMinutes: Int
    var scheduledStart: Date
    /// Canonical progress returned by TaskSvc.
    var serverPercentComplete: Double
    var colorIndex: Int
    var labelID: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        estimatedDurationMinutes: Int,
        elapsedMinutes: Int = 0,
        scheduledStart: Date = .now,
        serverPercentComplete: Double = 0,
        colorIndex: Int,
        labelID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.elapsedMinutes = elapsedMinutes
        self.scheduledStart = scheduledStart
        self.serverPercentComplete = serverPercentComplete
        self.colorIndex = colorIndex
        self.labelID = labelID
    }

    var progress: Double { min(max(serverPercentComplete, 0), 1) }
    var isComplete: Bool { progress >= 1 }
    var color: Color { WorkLabel.palette[colorIndex % WorkLabel.palette.count] }

#if DEBUG
    static let samples: [ActionQueueItem] = [
        .init(title: "Prototype Code", estimatedDurationMinutes: 80, scheduledStart: .today(hour: 10), serverPercentComplete: 0.22, colorIndex: 1, labelID: WorkLabel.samples[2].id),
        .init(title: "Ship Code", estimatedDurationMinutes: 65, scheduledStart: .today(hour: 11, minute: 30), colorIndex: 2, labelID: WorkLabel.samples[0].id),
        .init(title: "Write Docs", estimatedDurationMinutes: 55, scheduledStart: .today(hour: 13, minute: 30), colorIndex: 3, labelID: WorkLabel.samples[0].id),
        .init(title: "User Testing", estimatedDurationMinutes: 90, scheduledStart: .today(hour: 15), colorIndex: 4, labelID: WorkLabel.samples[1].id),
        .init(title: "Finance Check", estimatedDurationMinutes: 25, scheduledStart: .today(hour: 16, minute: 45), colorIndex: 3, labelID: WorkLabel.samples[1].id),
        .init(title: "Evening Reflection", estimatedDurationMinutes: 15, scheduledStart: .today(hour: 20), colorIndex: 5, labelID: WorkLabel.samples[3].id)
    ]
#endif

    static var sixSlotPlaceholders: [ActionQueueItem] {
        [
            .init(title: "Faith check-in", estimatedDurationMinutes: 10, scheduledStart: .today(hour: 8), colorIndex: 5),
            .init(title: "Fitness reset", estimatedDurationMinutes: 30, scheduledStart: .today(hour: 9), colorIndex: 3),
            .init(title: "Build sprint", estimatedDurationMinutes: 60, scheduledStart: .today(hour: 10), colorIndex: 0),
            .init(title: "Finance review", estimatedDurationMinutes: 20, scheduledStart: .today(hour: 13), colorIndex: 1),
            .init(title: "Read", estimatedDurationMinutes: 25, scheduledStart: .today(hour: 16), colorIndex: 2),
            .init(title: "Sketch ideas", estimatedDurationMinutes: 20, scheduledStart: .today(hour: 18), colorIndex: 4)
        ]
    }
}

struct LabelTimeRollup: Identifiable, Hashable {
    let label: WorkLabel
    let minutes: Int
    let serverPercentOfDay: Double

    var id: UUID { label.id }

#if DEBUG
    static let serverSamples: [LabelTimeRollup] = [
        .init(label: WorkLabel.samples[0], minutes: 94, serverPercentOfDay: 0.82),
        .init(label: WorkLabel.samples[1], minutes: 52, serverPercentOfDay: 0.46),
        .init(label: WorkLabel.samples[2], minutes: 78, serverPercentOfDay: 0.68),
        .init(label: WorkLabel.samples[3], minutes: 21, serverPercentOfDay: 0.18)
    ]
#endif
}

extension ActionItem {
#if DEBUG
    static let mock = ActionItem(
        title: "Ship the TimeBite MVP shell",
        targetMinutes: 45,
        elapsedMinutes: 18,
        scheduledStart: .today(hour: 9),
        serverPercentComplete: 0.4,
        streakDays: 12,
        category: "Build",
        labelID: WorkLabel.samples[0].id,
        accent: TBColor.primaryAccent,
        note: "One focused session to polish the core loop."
    )
#endif

    static let empty = ActionItem(
        title: "No action selected",
        targetMinutes: 25,
        elapsedMinutes: 0,
        serverPercentComplete: 0,
        streakDays: 0,
        category: "",
        accent: TBColor.primaryAccent,
        note: "Create an action to begin a focus session."
    )
}

private extension Date {
    static func today(hour: Int, minute: Int = 0) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: .now) ?? .now
    }
}
