import Foundation
import SwiftData

@Model
final class Goal {
    @Attribute(.unique) var id: UUID
    var title: String
    var goalDescription: String
    var category: String
    var lifeArea: String = "Work"
    var goalType: String
    var startDate: Date
    var dueDate: Date
    var deadlineIncludesTime: Bool = false
    /// Canonical time-based percentage returned by GoalSvc/RollupSvc.
    /// Client forms render this value read-only.
    var progress: Double
    var status: String
    var considerations: String
    var blockers: String
    var resources: String
    var dependenciesResources: String = ""
    var successCriteria: String
    var nextAction: String
    var quarter: String
    var targetMinutes: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        category: String = "",
        lifeArea: String = "Work",
        goalType: String = "",
        startDate: Date = .now,
        dueDate: Date = .now,
        deadlineIncludesTime: Bool = false,
        progress: Double = 0,
        status: String = "Not Started",
        considerations: String = "",
        blockers: String = "",
        resources: String = "",
        dependenciesResources: String = "",
        successCriteria: String = "",
        nextAction: String = "",
        quarter: String = Date.currentQuarterIdentifier,
        targetMinutes: Int = 0,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.goalDescription = description
        self.category = category
        self.lifeArea = lifeArea
        self.goalType = goalType
        self.startDate = startDate
        self.dueDate = dueDate
        self.deadlineIncludesTime = deadlineIncludesTime
        self.progress = progress
        self.status = status
        self.considerations = considerations
        self.blockers = blockers
        self.resources = resources
        self.dependenciesResources = dependenciesResources
        self.successCriteria = successCriteria
        self.nextAction = nextAction
        self.quarter = quarter
        self.targetMinutes = targetMinutes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Date {
    static var currentQuarterIdentifier: String {
        Date().quarterIdentifier
    }

    var quarterIdentifier: String {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        let month = components.month ?? 1
        let quarter = ((month - 1) / 3) + 1
        return "\(components.year ?? 2026)-Q\(quarter)"
    }
}

enum GoalKind: String, CaseIterable, Identifiable {
    case work = "Work"
    case personal = "Personal"
    case health = "Health"
    case debt = "Debt Payoff"
    case savings = "Savings"
    case investing = "Investing"
    case other = "Other"

    var id: String { rawValue }
    var title: String { rawValue }

    var symbolName: String {
        switch self {
        case .work: "briefcase.fill"
        case .personal: "person.fill"
        case .health: "heart.fill"
        case .debt: "creditcard.fill"
        case .savings: "banknote.fill"
        case .investing: "chart.line.uptrend.xyaxis"
        case .other: "ellipsis.circle.fill"
        }
    }

    var isFinanceRelated: Bool {
        self == .debt || self == .savings || self == .investing
    }

    init(storedValue: String) {
        let normalized = storedValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch normalized {
        case "work", "career", "build", "growth": self = .work
        case "personal": self = .personal
        case "health", "fitness", "fitness/health": self = .health
        case "debt", "debt payoff": self = .debt
        case "savings", "saving", "emergency savings": self = .savings
        case "investing", "investment", "investments": self = .investing
        default: self = .other
        }
    }
}
