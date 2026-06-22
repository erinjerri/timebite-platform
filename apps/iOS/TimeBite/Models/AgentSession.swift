import Foundation
import SwiftData

@Model
final class AgentSession {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date
    var toolName: String
    var repository: String
    var taskName: String
    var promptCount: Int
    var completionStatus: String
    var estimatedTokens: Int
    var estimatedCost: Double
    var interventionCount: Int
    var notes: String

    init(
        id: UUID = UUID(),
        startTime: Date = .now,
        endTime: Date = .now,
        toolName: String,
        repository: String = "",
        taskName: String,
        promptCount: Int = 0,
        completionStatus: String = "Completed",
        estimatedTokens: Int = 0,
        estimatedCost: Double = 0,
        interventionCount: Int = 0,
        notes: String = ""
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.toolName = toolName
        self.repository = repository
        self.taskName = taskName
        self.promptCount = promptCount
        self.completionStatus = completionStatus
        self.estimatedTokens = estimatedTokens
        self.estimatedCost = estimatedCost
        self.interventionCount = interventionCount
        self.notes = notes
    }

    var runtime: TimeInterval {
        max(endTime.timeIntervalSince(startTime), 0)
    }

    var isComplete: Bool {
        completionStatus.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "completed"
    }
}
