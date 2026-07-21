import Foundation
import Combine
import Network
import SwiftData
import SwiftUI

@Model
final class PendingSyncMutation {
    @Attribute(.unique) var id: UUID
    var entityType: String
    var operation: String
    var entityID: UUID
    var payload: Data
    var baseUpdatedAt: Date?
    var clientUpdatedAt: Date
    var attemptCount: Int
    var nextAttemptAt: Date
    var requiresReview: Bool

    init(
        id: UUID = UUID(),
        entityType: String,
        operation: String,
        entityID: UUID,
        payload: Data,
        baseUpdatedAt: Date?,
        clientUpdatedAt: Date = .now
    ) {
        self.id = id
        self.entityType = entityType
        self.operation = operation
        self.entityID = entityID
        self.payload = payload
        self.baseUpdatedAt = baseUpdatedAt
        self.clientUpdatedAt = clientUpdatedAt
        attemptCount = 0
        nextAttemptAt = .now
        requiresReview = false
    }
}

@Model
final class SyncCheckpoint {
    @Attribute(.unique) var id: String
    var cursor: Int
    var didImportLegacyRecords: Bool
    var lastSuccessfulSync: Date?

    init(id: String = "primary", cursor: Int = 0, didImportLegacyRecords: Bool = false) {
        self.id = id
        self.cursor = cursor
        self.didImportLegacyRecords = didImportLegacyRecords
    }
}

@Model
final class CachedActionRecord {
    @Attribute(.unique) var id: UUID
    var goalID: UUID?
    var title: String
    var status: String
    var scheduledAt: Date?
    var estimatedMinutes: Int
    var updatedAt: Date

    init(id: UUID, goalID: UUID?, title: String, status: String, scheduledAt: Date?, estimatedMinutes: Int, updatedAt: Date) {
        self.id = id
        self.goalID = goalID
        self.title = title
        self.status = status
        self.scheduledAt = scheduledAt
        self.estimatedMinutes = estimatedMinutes
        self.updatedAt = updatedAt
    }
}

@Model
final class CachedSessionRecord {
    @Attribute(.unique) var id: UUID
    var actionID: UUID?
    var status: String
    var startedAt: Date
    var updatedAt: Date

    init(id: UUID, actionID: UUID?, status: String, startedAt: Date, updatedAt: Date) {
        self.id = id
        self.actionID = actionID
        self.status = status
        self.startedAt = startedAt
        self.updatedAt = updatedAt
    }
}

@Model
final class CachedFinancialAccount {
    @Attribute(.unique) var id: UUID
    var plaidItemID: UUID
    var name: String
    var mask: String?
    var currency: String
    var currentBalanceMinorUnits: Int?
    var updatedAt: Date

    init(id: UUID, plaidItemID: UUID, name: String, mask: String?, currency: String, currentBalanceMinorUnits: Int?, updatedAt: Date) {
        self.id = id
        self.plaidItemID = plaidItemID
        self.name = name
        self.mask = mask
        self.currency = currency
        self.currentBalanceMinorUnits = currentBalanceMinorUnits
        self.updatedAt = updatedAt
    }
}

@Model
final class CachedTransaction {
    @Attribute(.unique) var id: UUID
    var accountID: UUID
    var name: String
    var amountMinorUnits: Int
    var currency: String
    var authorizedDate: Date?
    var updatedAt: Date

    init(id: UUID, accountID: UUID, name: String, amountMinorUnits: Int, currency: String, authorizedDate: Date?, updatedAt: Date) {
        self.id = id
        self.accountID = accountID
        self.name = name
        self.amountMinorUnits = amountMinorUnits
        self.currency = currency
        self.authorizedDate = authorizedDate
        self.updatedAt = updatedAt
    }
}

struct SyncMutationPayload: Encodable {
    let mutationID: UUID
    let entityType: String
    let operation: String
    let entityID: UUID
    let baseUpdatedAt: Date?
    let clientUpdatedAt: Date
    let payload: JSONValue

    enum CodingKeys: String, CodingKey {
        case mutationID = "mutation_id"
        case entityType = "entity_type"
        case operation
        case entityID = "entity_id"
        case baseUpdatedAt = "base_updated_at"
        case clientUpdatedAt = "client_updated_at"
        case payload
    }
}

struct IncrementalSyncRequest: Encodable {
    let cursor: Int
    let mutations: [SyncMutationPayload]
}

struct IncrementalSyncResponse: Decodable {
    struct MutationResult: Decodable {
        let mutationID: UUID
        let status: String
        enum CodingKeys: String, CodingKey { case mutationID = "mutation_id"; case status }
    }
    struct Change: Decodable {
        let sequence: Int
        let entityType: String
        let entityID: UUID
        let operation: String
        let payload: JSONValue?
        enum CodingKeys: String, CodingKey {
            case sequence
            case entityType = "entity_type"
            case entityID = "entity_id"
            case operation, payload
        }
    }
    let mutationResults: [MutationResult]
    let changes: [Change]
    let cursor: Int
    enum CodingKeys: String, CodingKey {
        case mutationResults = "mutation_results"
        case changes, cursor
    }
}

enum JSONValue: Codable {
    case string(String), integer(Int), number(Double), bool(Bool), object([String: JSONValue]), array([JSONValue]), null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() { self = .null }
        else if let value = try? container.decode(Bool.self) { self = .bool(value) }
        else if let value = try? container.decode(Int.self) { self = .integer(value) }
        else if let value = try? container.decode(Double.self) { self = .number(value) }
        else if let value = try? container.decode(String.self) { self = .string(value) }
        else if let value = try? container.decode([String: JSONValue].self) { self = .object(value) }
        else { self = .array(try container.decode([JSONValue].self)) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(value): try container.encode(value)
        case let .integer(value): try container.encode(value)
        case let .number(value): try container.encode(value)
        case let .bool(value): try container.encode(value)
        case let .object(value): try container.encode(value)
        case let .array(value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }
}

@MainActor
final class SyncCoordinator: ObservableObject {
    enum State: Equatable {
        case idle, loading, syncing, offline, stale, disconnected, error(String)
    }

    @Published private(set) var state: State = .idle
    private let client: TimeBiteAPIClient
    private let context: ModelContext
    private let monitor = NWPathMonitor()
    private var isOnline = true

    init(client: TimeBiteAPIClient, context: ModelContext) {
        self.client = client
        self.context = context
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOnline = path.status == .satisfied
                self?.state = path.status == .satisfied ? .idle : .offline
                if path.status == .satisfied { await self?.synchronize() }
            }
        }
        monitor.start(queue: DispatchQueue(label: "com.timebite.network-monitor"))
    }

    func importLegacyRecordsOnce() throws {
        let checkpoint = try checkpoint()
        guard !checkpoint.didImportLegacyRecords else { return }
        let goals = try context.fetch(FetchDescriptor<Goal>())
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        for goal in goals {
            let payload: [String: JSONValue] = [
                "title": .string(goal.title),
                "details": .string(goal.goalDescription),
                "status": .string(goal.status),
                "target_date": .string(ISO8601DateFormatter().string(from: goal.dueDate))
            ]
            context.insert(PendingSyncMutation(
                entityType: "goals",
                operation: "upsert",
                entityID: goal.id,
                payload: try encoder.encode(JSONValue.object(payload)),
                baseUpdatedAt: nil,
                clientUpdatedAt: goal.updatedAt
            ))
        }
        checkpoint.didImportLegacyRecords = true
        try context.save()
    }

    func enqueue(
        entityType: String,
        operation: String = "upsert",
        entityID: UUID,
        payload: JSONValue,
        baseUpdatedAt: Date?
    ) throws {
        let encoder = JSONEncoder()
        context.insert(PendingSyncMutation(
            entityType: entityType,
            operation: operation,
            entityID: entityID,
            payload: try encoder.encode(payload),
            baseUpdatedAt: baseUpdatedAt
        ))
        try context.save()
        Task { await synchronize() }
    }

    func enqueueGoal(_ goal: Goal, baseUpdatedAt: Date?) throws {
        try enqueue(
            entityType: "goals",
            entityID: goal.id,
            payload: .object([
                "title": .string(goal.title),
                "details": .string(goal.goalDescription),
                "status": .string(goal.status),
                "target_date": .string(ISO8601DateFormatter().string(from: goal.dueDate))
            ]),
            baseUpdatedAt: baseUpdatedAt
        )
    }

    func enqueueFinancialGoal(_ goal: FinancialGoal, baseUpdatedAt: Date?) throws {
        try enqueue(
            entityType: "financial_goals",
            entityID: goal.id,
            payload: .object([
                "name": .string(goal.title),
                "target_minor_units": .integer(Self.minorUnits(goal.targetAmount)),
                "current_minor_units": .integer(Self.minorUnits(goal.currentAmount)),
                "currency": .string("USD")
            ]),
            baseUpdatedAt: baseUpdatedAt
        )
    }

    private static func minorUnits(_ amount: Decimal) -> Int {
        var scaled = amount * 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &scaled, 0, .bankers)
        return NSDecimalNumber(decimal: rounded).intValue
    }

    func synchronize() async {
        guard isOnline else { state = .offline; return }
        guard await client.hasCredentials() else { state = .disconnected; return }
        state = .syncing
        do {
            try importLegacyRecordsOnce()
            let checkpoint = try checkpoint()
            let now = Date.now
            let pending = try context.fetch(
                FetchDescriptor<PendingSyncMutation>(predicate: #Predicate { !$0.requiresReview && $0.nextAttemptAt <= now })
            )
            let decoder = JSONDecoder()
            let mutations = try pending.map { item in
                SyncMutationPayload(
                    mutationID: item.id,
                    entityType: item.entityType,
                    operation: item.operation,
                    entityID: item.entityID,
                    baseUpdatedAt: item.baseUpdatedAt,
                    clientUpdatedAt: item.clientUpdatedAt,
                    payload: try decoder.decode(JSONValue.self, from: item.payload)
                )
            }
            let response: IncrementalSyncResponse = try await client.request(
                "/v1/sync", method: "POST", body: IncrementalSyncRequest(cursor: checkpoint.cursor, mutations: mutations)
            )
            for result in response.mutationResults {
                guard let item = pending.first(where: { $0.id == result.mutationID }) else { continue }
                if result.status == "conflict" { item.requiresReview = true }
                else { context.delete(item) }
            }
            try apply(response.changes)
            checkpoint.cursor = response.cursor
            checkpoint.lastSuccessfulSync = .now
            try context.save()
            state = pending.contains(where: { $0.requiresReview }) ? .stale : .idle
        } catch {
            state = .error(error.localizedDescription)
            scheduleRetry()
        }
    }

    private func checkpoint() throws -> SyncCheckpoint {
        var descriptor = FetchDescriptor<SyncCheckpoint>(predicate: #Predicate { $0.id == "primary" })
        descriptor.fetchLimit = 1
        if let existing = try context.fetch(descriptor).first { return existing }
        let created = SyncCheckpoint()
        context.insert(created)
        return created
    }

    private func apply(_ changes: [IncrementalSyncResponse.Change]) throws {
        for change in changes {
            switch change.entityType {
            case "goals": try applyGoal(change)
            case "actions": try applyAction(change)
            case "sessions": try applySession(change)
            default: continue
            }
        }
    }

    private func applyGoal(_ change: IncrementalSyncResponse.Change) throws {
        let entityID = change.entityID
        var descriptor = FetchDescriptor<Goal>(predicate: #Predicate { $0.id == entityID })
        descriptor.fetchLimit = 1
        let existing = try context.fetch(descriptor).first
        if change.operation == "delete" {
            if let existing { context.delete(existing) }
            return
        }
        guard case let .object(payload)? = change.payload,
              let title = payload.string("title") else { return }
        let updatedAt = payload.date("updated_at") ?? .now
        let goal = existing ?? Goal(id: entityID, title: title, createdAt: payload.date("created_at") ?? updatedAt)
        if existing == nil { context.insert(goal) }
        goal.title = title
        goal.goalDescription = payload.string("details") ?? ""
        goal.status = payload.string("status") ?? goal.status
        goal.dueDate = payload.date("target_date") ?? goal.dueDate
        goal.updatedAt = updatedAt
    }

    private func applyAction(_ change: IncrementalSyncResponse.Change) throws {
        let entityID = change.entityID
        var descriptor = FetchDescriptor<CachedActionRecord>(predicate: #Predicate { $0.id == entityID })
        descriptor.fetchLimit = 1
        let existing = try context.fetch(descriptor).first
        if change.operation == "delete" {
            if let existing { context.delete(existing) }
            return
        }
        guard case let .object(payload)? = change.payload,
              let title = payload.string("title") else { return }
        let updatedAt = payload.date("updated_at") ?? .now
        let record = existing ?? CachedActionRecord(
            id: entityID,
            goalID: payload.uuid("goal_id"),
            title: title,
            status: payload.string("status") ?? "pending",
            scheduledAt: payload.date("scheduled_at"),
            estimatedMinutes: payload.integer("estimated_minutes") ?? 0,
            updatedAt: updatedAt
        )
        if existing == nil { context.insert(record) }
        record.goalID = payload.uuid("goal_id")
        record.title = title
        record.status = payload.string("status") ?? record.status
        record.scheduledAt = payload.date("scheduled_at")
        record.estimatedMinutes = payload.integer("estimated_minutes") ?? record.estimatedMinutes
        record.updatedAt = updatedAt
    }

    private func applySession(_ change: IncrementalSyncResponse.Change) throws {
        let entityID = change.entityID
        var descriptor = FetchDescriptor<CachedSessionRecord>(predicate: #Predicate { $0.id == entityID })
        descriptor.fetchLimit = 1
        let existing = try context.fetch(descriptor).first
        if change.operation == "delete" {
            if let existing { context.delete(existing) }
            return
        }
        guard case let .object(payload)? = change.payload else { return }
        let updatedAt = payload.date("updated_at") ?? .now
        let record = existing ?? CachedSessionRecord(
            id: entityID,
            actionID: payload.uuid("action_id"),
            status: payload.string("status") ?? "running",
            startedAt: payload.date("started_at") ?? updatedAt,
            updatedAt: updatedAt
        )
        if existing == nil { context.insert(record) }
        record.actionID = payload.uuid("action_id")
        record.status = payload.string("status") ?? record.status
        record.startedAt = payload.date("started_at") ?? record.startedAt
        record.updatedAt = updatedAt
    }

    private func scheduleRetry() {
        guard let pending = try? context.fetch(FetchDescriptor<PendingSyncMutation>()) else { return }
        for item in pending where !item.requiresReview {
            item.attemptCount += 1
            let delay = min(pow(2, Double(item.attemptCount)) * 5, 3600)
            item.nextAttemptAt = Date().addingTimeInterval(delay)
        }
        try? context.save()
    }
}

private extension Dictionary where Key == String, Value == JSONValue {
    func string(_ key: String) -> String? {
        guard case let .string(value)? = self[key] else { return nil }
        return value
    }

    func integer(_ key: String) -> Int? {
        guard case let .integer(value)? = self[key] else { return nil }
        return value
    }

    func uuid(_ key: String) -> UUID? {
        string(key).flatMap(UUID.init(uuidString:))
    }

    func date(_ key: String) -> Date? {
        guard let value = string(key) else { return nil }
        return ISO8601DateFormatter.timeBiteFractional.date(from: value)
            ?? ISO8601DateFormatter.timeBiteStandard.date(from: value)
    }
}

private extension ISO8601DateFormatter {
    static let timeBiteFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let timeBiteStandard = ISO8601DateFormatter()
}

struct SyncBootstrapView<Content: View>: View {
    @Environment(\.modelContext) private var modelContext
    @State private var coordinator: SyncCoordinator?
    let client: TimeBiteAPIClient
    let content: () -> Content

    var body: some View {
        Group {
            if let coordinator {
                content().environmentObject(coordinator)
            } else {
                ProgressView("Loading your offline data…")
            }
        }
        .task {
            guard coordinator == nil else { return }
            let created = SyncCoordinator(client: client, context: modelContext)
            coordinator = created
            await created.synchronize()
        }
    }
}
