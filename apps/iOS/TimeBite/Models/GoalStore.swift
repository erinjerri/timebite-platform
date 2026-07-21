import Foundation
import SwiftData

@MainActor
final class GoalStore {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    @discardableResult
    func createGoal(
        title: String,
        description: String = "",
        category: String = "",
        lifeArea: String = "Work",
        goalType: String = "",
        startDate: Date = .now,
        dueDate: Date,
        deadlineIncludesTime: Bool = false,
        status: String = "Not Started",
        considerations: String = "",
        blockers: String = "",
        resources: String = "",
        dependenciesResources: String = "",
        successCriteria: String = "",
        nextAction: String = ""
    ) throws -> Goal {
        let goal = Goal(
            title: title,
            description: description,
            category: category,
            lifeArea: lifeArea,
            goalType: goalType,
            startDate: startDate,
            dueDate: dueDate,
            deadlineIncludesTime: deadlineIncludesTime,
            progress: 0,
            status: status,
            considerations: considerations,
            blockers: blockers,
            resources: resources,
            dependenciesResources: dependenciesResources,
            successCriteria: successCriteria,
            nextAction: nextAction
        )
        modelContext.insert(goal)
        try save()
        return goal
    }

    func fetchGoals() throws -> [Goal] {
        let descriptor = FetchDescriptor<Goal>(
            sortBy: [SortDescriptor(\.dueDate, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchGoal(id: UUID) throws -> Goal? {
        var descriptor = FetchDescriptor<Goal>(
            predicate: #Predicate { goal in
                goal.id == id
            }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func updateGoal(
        _ goal: Goal,
        title: String? = nil,
        description: String? = nil,
        category: String? = nil,
        lifeArea: String? = nil,
        goalType: String? = nil,
        startDate: Date? = nil,
        dueDate: Date? = nil,
        deadlineIncludesTime: Bool? = nil,
        status: String? = nil,
        considerations: String? = nil,
        blockers: String? = nil,
        resources: String? = nil,
        dependenciesResources: String? = nil,
        successCriteria: String? = nil,
        nextAction: String? = nil
    ) throws {
        if let title {
            goal.title = title
        }
        if let description {
            goal.goalDescription = description
        }
        if let category {
            goal.category = category
        }
        if let lifeArea {
            goal.lifeArea = lifeArea
        }
        if let goalType {
            goal.goalType = goalType
        }
        if let startDate {
            goal.startDate = startDate
        }
        if let dueDate {
            goal.dueDate = dueDate
        }
        if let deadlineIncludesTime {
            goal.deadlineIncludesTime = deadlineIncludesTime
        }
        if let status {
            goal.status = status
        }
        if let considerations {
            goal.considerations = considerations
        }
        if let blockers {
            goal.blockers = blockers
        }
        if let resources {
            goal.resources = resources
        }
        if let dependenciesResources {
            goal.dependenciesResources = dependenciesResources
        }
        if let successCriteria {
            goal.successCriteria = successCriteria
        }
        if let nextAction {
            goal.nextAction = nextAction
        }
        goal.updatedAt = .now
        try save()
    }

    func deleteGoal(_ goal: Goal) throws {
        let goalId = goal.id
        try deleteMilestones(goalId: goalId)
        try deleteProgressEntries(goalId: goalId)
        modelContext.delete(goal)
        try save()
    }

    @discardableResult
    func createMilestone(
        goalId: UUID,
        title: String,
        dueDate: Date,
        status: String = "Not Started",
        notes: String = ""
    ) throws -> Milestone {
        let milestone = Milestone(
            goalId: goalId,
            title: title,
            dueDate: dueDate,
            status: status,
            notes: notes
        )
        modelContext.insert(milestone)
        try save()
        return milestone
    }

    func fetchMilestones(goalId: UUID) throws -> [Milestone] {
        let descriptor = FetchDescriptor<Milestone>(
            predicate: #Predicate { milestone in
                milestone.goalId == goalId
            },
            sortBy: [SortDescriptor(\.dueDate, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    func updateMilestone(
        _ milestone: Milestone,
        title: String? = nil,
        dueDate: Date? = nil,
        status: String? = nil,
        notes: String? = nil
    ) throws {
        if let title {
            milestone.title = title
        }
        if let dueDate {
            milestone.dueDate = dueDate
        }
        if let status {
            milestone.status = status
        }
        if let notes {
            milestone.notes = notes
        }
        try save()
    }

    func deleteMilestone(_ milestone: Milestone) throws {
        modelContext.delete(milestone)
        try save()
    }

    @discardableResult
    func createProgressEntry(
        goalId: UUID,
        date: Date = .now,
        progressValue: Double,
        note: String = ""
    ) throws -> GoalProgressEntry {
        let entry = GoalProgressEntry(
            goalId: goalId,
            date: date,
            progressValue: progressValue,
            note: note
        )
        modelContext.insert(entry)
        try save()
        return entry
    }

    func fetchProgressEntries(goalId: UUID) throws -> [GoalProgressEntry] {
        let descriptor = FetchDescriptor<GoalProgressEntry>(
            predicate: #Predicate { entry in
                entry.goalId == goalId
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    func updateProgressEntry(
        _ entry: GoalProgressEntry,
        date: Date? = nil,
        progressValue: Double? = nil,
        note: String? = nil
    ) throws {
        if let date {
            entry.date = date
        }
        if let progressValue {
            entry.progressValue = progressValue
        }
        if let note {
            entry.note = note
        }
        try save()
    }

    func deleteProgressEntry(_ entry: GoalProgressEntry) throws {
        modelContext.delete(entry)
        try save()
    }

    private func deleteMilestones(goalId: UUID) throws {
        let milestones = try fetchMilestones(goalId: goalId)
        milestones.forEach(modelContext.delete)
    }

    private func deleteProgressEntries(goalId: UUID) throws {
        let entries = try fetchProgressEntries(goalId: goalId)
        entries.forEach(modelContext.delete)
    }

    private func save() throws {
        guard modelContext.hasChanges else { return }
        try modelContext.save()
    }
}
