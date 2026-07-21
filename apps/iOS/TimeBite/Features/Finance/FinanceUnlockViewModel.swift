import Combine
import Foundation

@MainActor
protocol FinanceAccountConnecting {
    func connectAccount(for stage: FinanceUnlockStage) async throws
}

#if DEBUG
/// Preview-only connector. Runtime builds inject the Plaid-backed connector.
struct StubFinanceAccountConnector: FinanceAccountConnecting {
    var delay: Duration = .milliseconds(450)

    func connectAccount(for stage: FinanceUnlockStage) async throws {
        try await Task.sleep(for: delay)
    }
}
#endif

@MainActor
final class FinanceUnlockViewModel: ObservableObject {
    @Published private(set) var isConnecting = false
    @Published private(set) var errorMessage: String?

    let stage: FinanceUnlockStage

    private let connector: any FinanceAccountConnecting
    private let onConnected: (FinanceUnlockStage) -> Void
    private let onDismiss: () -> Void

    init(
        stage: FinanceUnlockStage,
        connector: any FinanceAccountConnecting,
        onConnected: @escaping (FinanceUnlockStage) -> Void = { _ in },
        onDismiss: @escaping () -> Void
    ) {
        self.stage = stage
        self.connector = connector
        self.onConnected = onConnected
        self.onDismiss = onDismiss
    }

    func connect() async {
        guard !isConnecting else { return }

        isConnecting = true
        errorMessage = nil

        do {
            try await connector.connectAccount(for: stage)
            isConnecting = false
            onConnected(stage)
            onDismiss()
        } catch is CancellationError {
            isConnecting = false
        } catch {
            isConnecting = false
            errorMessage = "We couldn’t start the connection. Please try again."
        }
    }

    func dismiss() {
        guard !isConnecting else { return }
        onDismiss()
    }
}
