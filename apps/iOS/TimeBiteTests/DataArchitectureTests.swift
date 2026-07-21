import SwiftData
import XCTest
@testable import TimeBite

final class DataArchitectureTests: XCTestCase {
    @MainActor
    func testOfflineMutationIsDurablyStoredWithStableIdentifier() throws {
        let schema = Schema([PendingSyncMutation.self])
        let container = try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        let entityID = UUID()
        let payload = try JSONEncoder().encode(
            JSONValue.object(["title": .string("Offline goal"), "status": .string("active")])
        )

        context.insert(PendingSyncMutation(
            entityType: "goals",
            operation: "upsert",
            entityID: entityID,
            payload: payload,
            baseUpdatedAt: nil
        ))
        try context.save()

        let stored = try XCTUnwrap(context.fetch(FetchDescriptor<PendingSyncMutation>()).first)
        XCTAssertEqual(stored.entityID, entityID)
        XCTAssertEqual(stored.entityType, "goals")
        XCTAssertEqual(stored.operation, "upsert")
        XCTAssertEqual(stored.attemptCount, 0)
        XCTAssertFalse(stored.requiresReview)
    }

    func testFinancialCacheUsesIntegerMinorUnits() {
        let transaction = CachedTransaction(
            id: UUID(),
            accountID: UUID(),
            name: "Coffee",
            amountMinorUnits: 425,
            currency: "USD",
            authorizedDate: nil,
            updatedAt: .now
        )
        XCTAssertEqual(transaction.amountMinorUnits, 425)
    }
}
