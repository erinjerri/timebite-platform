import SwiftUI

struct ActionItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var targetMinutes: Int
    var elapsedMinutes: Int
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

    static let samples: [WorkLabel] = [
        .init(id: UUID(uuidString: "071E74DA-EAA1-4DF7-9E03-000000000001")!, name: "timebite-platform", colorIndex: 0),
        .init(id: UUID(uuidString: "071E74DA-EAA1-4DF7-9E03-000000000002")!, name: "timebite-core", colorIndex: 1),
        .init(id: UUID(uuidString: "071E74DA-EAA1-4DF7-9E03-000000000003")!, name: "timebite-vision", colorIndex: 2),
        .init(id: UUID(uuidString: "071E74DA-EAA1-4DF7-9E03-000000000004")!, name: "app-review", colorIndex: 3)
    ]
}

struct ActionQueueItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var estimatedDurationMinutes: Int
    var elapsedMinutes: Int
    /// Canonical progress returned by TaskSvc.
    var serverPercentComplete: Double
    var colorIndex: Int
    var labelID: UUID?
    var epic: String
    var status: String
    var dueText: String
    var repoName: String

    init(
        id: UUID = UUID(),
        title: String,
        estimatedDurationMinutes: Int,
        elapsedMinutes: Int = 0,
        serverPercentComplete: Double = 0,
        colorIndex: Int,
        labelID: UUID? = nil,
        epic: String,
        status: String = "Not Started",
        dueText: String,
        repoName: String
    ) {
        self.id = id
        self.title = title
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.elapsedMinutes = elapsedMinutes
        self.serverPercentComplete = serverPercentComplete
        self.colorIndex = colorIndex
        self.labelID = labelID
        self.epic = epic
        self.status = status
        self.dueText = dueText
        self.repoName = repoName
    }

    var progress: Double { min(max(serverPercentComplete, 0), 1) }
    var isComplete: Bool { progress >= 1 }
    var color: Color { WorkLabel.palette[colorIndex % WorkLabel.palette.count] }

    static let samples: [ActionQueueItem] = [
        .init(title: "Refactor iOS to consume timebite-core", estimatedDurationMinutes: 180, colorIndex: 1, labelID: WorkLabel.samples[0].id, epic: "visionOS Companion Setup", dueText: "Jul 23", repoName: "timebite-platform"),
        .init(title: "Create timebite-vision app repo", estimatedDurationMinutes: 60, colorIndex: 2, labelID: WorkLabel.samples[2].id, epic: "visionOS Companion Setup", dueText: "Jul 23", repoName: "timebite-vision"),
        .init(title: "Add timebite-core to visionOS", estimatedDurationMinutes: 60, colorIndex: 3, labelID: WorkLabel.samples[2].id, epic: "visionOS Companion Setup", dueText: "Jul 23", repoName: "timebite-vision"),
        .init(title: "Implement auth handoff", estimatedDurationMinutes: 240, colorIndex: 4, labelID: WorkLabel.samples[1].id, epic: "visionOS Companion Setup", dueText: "Jul 24", repoName: "shared"),
        .init(title: "Verify Plaid visionOS support", estimatedDurationMinutes: 60, colorIndex: 5, labelID: WorkLabel.samples[1].id, epic: "visionOS Companion Setup", dueText: "Jul 23", repoName: "timebite-core"),
        .init(title: "Port P6 ring + task rail", estimatedDurationMinutes: 360, colorIndex: 0, labelID: WorkLabel.samples[2].id, epic: "visionOS Companion Setup", dueText: "Jul 24", repoName: "timebite-vision"),
        .init(title: "Set up visionOS 26+ CI", estimatedDurationMinutes: 120, colorIndex: 1, labelID: WorkLabel.samples[2].id, epic: "visionOS Companion Setup", dueText: "Jul 24", repoName: "timebite-vision"),
        .init(title: "Decide App Store record strategy", estimatedDurationMinutes: 60, colorIndex: 2, labelID: WorkLabel.samples[3].id, epic: "visionOS Companion Setup", dueText: "Jul 24", repoName: "App Store Connect"),
        .init(title: "Start visionOS TestFlight soak", estimatedDurationMinutes: 60, colorIndex: 3, labelID: WorkLabel.samples[2].id, epic: "visionOS Companion Setup", dueText: "Jul 23", repoName: "timebite-vision"),
        .init(title: "Finalize demo account + Review Notes", estimatedDurationMinutes: 120, colorIndex: 4, labelID: WorkLabel.samples[3].id, epic: "App Review Consistency", dueText: "Jul 25", repoName: "shared"),
        .init(title: "Reconcile privacy labels", estimatedDurationMinutes: 120, colorIndex: 5, labelID: WorkLabel.samples[3].id, epic: "App Review Consistency", dueText: "Jul 26", repoName: "shared"),
        .init(title: "Align Coming Soon gates", estimatedDurationMinutes: 120, colorIndex: 0, labelID: WorkLabel.samples[3].id, epic: "App Review Consistency", dueText: "Jul 26", repoName: "shared"),
        .init(title: "Verify screenshots + metadata", estimatedDurationMinutes: 180, colorIndex: 1, labelID: WorkLabel.samples[3].id, epic: "App Review Consistency", dueText: "Jul 27", repoName: "shared"),
        .init(title: "Verify visionOS 26 SDK archive", estimatedDurationMinutes: 60, colorIndex: 2, labelID: WorkLabel.samples[3].id, epic: "App Review Consistency", dueText: "Jul 25", repoName: "timebite-vision")
    ]
}

struct LabelTimeRollup: Identifiable, Hashable {
    let label: WorkLabel
    let minutes: Int
    let serverPercentOfDay: Double

    var id: UUID { label.id }

    static let serverSamples: [LabelTimeRollup] = [
        .init(label: WorkLabel.samples[0], minutes: 94, serverPercentOfDay: 0.82),
        .init(label: WorkLabel.samples[1], minutes: 52, serverPercentOfDay: 0.46),
        .init(label: WorkLabel.samples[2], minutes: 78, serverPercentOfDay: 0.68),
        .init(label: WorkLabel.samples[3], minutes: 21, serverPercentOfDay: 0.18)
    ]
}

extension ActionItem {
    static let mock = ActionItem(
        title: "Extract shared services into timebite-core",
        targetMinutes: 240,
        elapsedMinutes: 0,
        serverPercentComplete: 0,
        streakDays: 12,
        category: "visionOS Companion Setup",
        labelID: WorkLabel.samples[1].id,
        accent: TBColor.primaryAccent,
        note: "TestFlight Jul 25 • App submission Jul 30 • timebite-core"
    )
}
