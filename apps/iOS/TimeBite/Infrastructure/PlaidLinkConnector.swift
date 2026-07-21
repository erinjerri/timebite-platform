import Foundation

#if canImport(LinkKit)
import LinkKit
import UIKit
#endif

@MainActor
protocol PlaidLinkOpening {
    func open(linkToken: String) async throws -> String
}

@MainActor
enum PlaidLinkOpenerFactory {
    static func make() -> any PlaidLinkOpening {
#if canImport(LinkKit)
        return LinkKitOpener {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            return scenes.flatMap(\.windows).first(where: \.isKeyWindow)?.rootViewController
        }
#else
        return UnavailablePlaidLinkOpener()
#endif
    }
}

struct UnavailablePlaidLinkOpener: PlaidLinkOpening {
    func open(linkToken: String) async throws -> String { throw TimeBiteAPIError.missingPlaidSDK }
}

struct PlaidFinanceAccountConnector: FinanceAccountConnecting {
    let repository: any PlaidRepository
    let opener: any PlaidLinkOpening

    @MainActor
    func connectAccount(for stage: FinanceUnlockStage) async throws {
        let token = try await repository.linkToken(itemID: nil)
        let publicToken = try await opener.open(linkToken: token)
        try await repository.exchange(publicToken: publicToken)
    }
}

#if canImport(LinkKit)
@MainActor
final class LinkKitOpener: PlaidLinkOpening {
    private let presenter: () -> UIViewController?
    private var linkSession: PlaidLinkSession?

    init(presenter: @escaping () -> UIViewController?) {
        self.presenter = presenter
    }

    func open(linkToken: String) async throws -> String {
        guard let viewController = presenter() else { throw TimeBiteAPIError.invalidResponse }
        return try await withCheckedThrowingContinuation { continuation in
            let configuration = LinkTokenConfiguration(
                token: linkToken,
                onSuccess: { [weak self] success in
                    self?.linkSession = nil
                    continuation.resume(returning: success.publicToken)
                },
                onExit: { [weak self] exit in
                    self?.linkSession = nil
                    if let error = exit.error { continuation.resume(throwing: error) }
                    else { continuation.resume(throwing: CancellationError()) }
                },
                onEvent: nil,
                onLoad: nil
            )
            do {
                let session = try Plaid.createPlaidLinkSession(configuration: configuration)
                linkSession = session
                session.open(using: .viewController(viewController))
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
#endif
