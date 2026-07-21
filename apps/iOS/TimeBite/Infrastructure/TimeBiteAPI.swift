import AuthenticationServices
import CryptoKit
import Foundation
import Security

enum APIEnvironment {
    static var baseURL: URL {
        if let configured = Bundle.main.object(forInfoDictionaryKey: "TIMEBITE_API_BASE_URL") as? String,
           !configured.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           !configured.hasPrefix("$("),
           let url = URL(string: configured),
           url.scheme == "https" || isDebugLocalURL(url) {
            return url
        }
#if DEBUG || targetEnvironment(simulator)
        return URL(string: "http://127.0.0.1:8000")!
#else
        fatalError("TIMEBITE_API_BASE_URL must be an HTTPS URL for Release builds")
#endif
    }

    private static func isDebugLocalURL(_ url: URL) -> Bool {
#if DEBUG || targetEnvironment(simulator)
        return url.host == "127.0.0.1" || url.host == "localhost"
#else
        return false
#endif
    }
}

struct APITokenPair: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

enum TimeBiteAPIError: LocalizedError {
    case invalidResponse
    case unauthorized
    case server(code: String, message: String)
    case missingPlaidSDK

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "The server returned an invalid response."
        case .unauthorized: "Your session has expired. Please sign in again."
        case let .server(_, message): message
        case .missingPlaidSDK: "Bank connection is unavailable in this build."
        }
    }
}

struct APIErrorEnvelope: Decodable {
    struct Detail: Decodable {
        let code: String
        let message: String
    }
    let error: Detail
}

final class KeychainCredentialStore: @unchecked Sendable {
    private let service = "com.timebite.app.api"
    private let account = "token-pair"

    func load() throws -> APITokenPair? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw TimeBiteAPIError.unauthorized
        }
        return try JSONDecoder().decode(APITokenPair.self, from: data)
    }

    func save(_ pair: APITokenPair) throws {
        let data = try JSONEncoder().encode(pair)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var insertion = query
            attributes.forEach { insertion[$0.key] = $0.value }
            guard SecItemAdd(insertion as CFDictionary, nil) == errSecSuccess else {
                throw TimeBiteAPIError.unauthorized
            }
        } else if status != errSecSuccess {
            throw TimeBiteAPIError.unauthorized
        }
    }

    func clear() {
        SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ] as CFDictionary)
    }
}

actor CredentialVault {
    private let keychain: KeychainCredentialStore
    private var pair: APITokenPair?

    init(keychain: KeychainCredentialStore = KeychainCredentialStore()) {
        self.keychain = keychain
        self.pair = try? keychain.load()
    }

    func current() -> APITokenPair? { pair }

    func replace(with pair: APITokenPair) throws {
        try keychain.save(pair)
        self.pair = pair
    }

    func clear() {
        keychain.clear()
        pair = nil
    }
}

actor TimeBiteAPIClient {
    private let baseURL: URL
    private let session: URLSession
    private let vault: CredentialVault
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var refreshTask: Task<APITokenPair, Error>?

    init(
        baseURL: URL = APIEnvironment.baseURL,
        session: URLSession = .shared,
        vault: CredentialVault = CredentialVault()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.vault = vault
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func hasCredentials() async -> Bool { await vault.current() != nil }

    func signIn(identityToken: String, rawNonce: String) async throws {
        struct Body: Encodable { let identity_token: String; let raw_nonce: String }
        let pair: APITokenPair = try await send(
            "/v1/auth/apple",
            method: "POST",
            body: Body(identity_token: identityToken, raw_nonce: rawNonce),
            authenticated: false
        )
        try await vault.replace(with: pair)
    }

    func logout() async {
        struct Body: Encodable { let refresh_token: String }
        if let pair = await vault.current() {
            let _: EmptyResponse? = try? await send(
                "/v1/auth/logout", method: "POST", body: Body(refresh_token: pair.refreshToken), authenticated: true
            )
        }
        await vault.clear()
    }

    func deleteAccount() async throws {
        let _: EmptyResponse = try await send(
            "/v1/account", method: "DELETE", body: Optional<String>.none, authenticated: true
        )
        await vault.clear()
    }

    func request<Response: Decodable, Body: Encodable>(
        _ path: String,
        method: String = "GET",
        body: Body? = Optional<String>.none
    ) async throws -> Response {
        try await send(path, method: method, body: body, authenticated: true)
    }

    private func send<Response: Decodable, Body: Encodable>(
        _ path: String,
        method: String,
        body: Body?,
        authenticated: Bool,
        isRetry: Bool = false
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Request-ID")
        if let body { request.httpBody = try encoder.encode(body) }
        if authenticated, let pair = await vault.current() {
            request.setValue("Bearer \(pair.accessToken)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw TimeBiteAPIError.invalidResponse }
        if http.statusCode == 401, authenticated, !isRetry {
            _ = try await refreshCredentials()
            return try await send(path, method: method, body: body, authenticated: true, isRetry: true)
        }
        guard (200..<300).contains(http.statusCode) else {
            if let envelope = try? decoder.decode(APIErrorEnvelope.self, from: data) {
                throw TimeBiteAPIError.server(code: envelope.error.code, message: envelope.error.message)
            }
            throw TimeBiteAPIError.invalidResponse
        }
        if Response.self == EmptyResponse.self {
            return EmptyResponse() as! Response
        }
        return try decoder.decode(Response.self, from: data)
    }

    private func refreshCredentials() async throws -> APITokenPair {
        if let refreshTask { return try await refreshTask.value }
        guard let current = await vault.current() else { throw TimeBiteAPIError.unauthorized }
        struct Body: Encodable { let refresh_token: String }
        let task = Task {
            let pair: APITokenPair = try await send(
                "/v1/auth/refresh",
                method: "POST",
                body: Body(refresh_token: current.refreshToken),
                authenticated: false
            )
            try await vault.replace(with: pair)
            return pair
        }
        refreshTask = task
        defer { refreshTask = nil }
        do { return try await task.value }
        catch {
            await vault.clear()
            throw error
        }
    }
}

struct EmptyResponse: Codable { init() {} }

@MainActor
final class AuthenticationStore: ObservableObject {
    enum State { case restoring, signedOut, signingIn, signedIn, error(String) }

    @Published private(set) var state: State = .restoring
    private(set) var rawNonce: String?
    let client: TimeBiteAPIClient

    init(client: TimeBiteAPIClient = TimeBiteAPIClient()) {
        self.client = client
        Task { state = await client.hasCredentials() ? .signedIn : .signedOut }
    }

    func prepare(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = Self.randomNonce()
        rawNonce = nonce
        request.requestedScopes = [.email, .fullName]
        request.nonce = SHA256.hash(data: Data(nonce.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    func complete(_ result: Result<ASAuthorization, Error>) async {
        state = .signingIn
        do {
            guard case let .success(authorization) = result,
                  let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let token = String(data: tokenData, encoding: .utf8),
                  let rawNonce else { throw TimeBiteAPIError.unauthorized }
            try await client.signIn(identityToken: token, rawNonce: rawNonce)
            self.rawNonce = nil
            state = .signedIn
        } catch {
            rawNonce = nil
            state = .error(error.localizedDescription)
        }
    }

    func signInWithBetaCode(_ code: String) {
        let cleanCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanCode == "123456" else {
            state = .error("That beta code did not match. Use 123456 for this local simulator build.")
            return
        }
        state = .signedIn
    }

    func signOut() async {
        await client.logout()
        state = .signedOut
    }

    func deleteAccount() async throws {
        try await client.deleteAccount()
        state = .signedOut
    }

    private static func randomNonce(length: Int = 32) -> String {
        let alphabet = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var generator = SystemRandomNumberGenerator()
        return String((0..<length).map { _ in alphabet.randomElement(using: &generator)! })
    }
}

protocol GoalRepository {
    func upsert(_ goal: GoalWriteDTO) async throws -> ServerEntity
    func delete(id: UUID) async throws
}
protocol ActionRepository {
    func upsert(_ action: ActionWriteDTO) async throws -> ServerEntity
    func delete(id: UUID) async throws
}
protocol SessionRepository {
    func start(_ session: SessionStartDTO) async throws -> ServerEntity
    func pause(id: UUID, occurredAt: Date) async throws -> ServerEntity
    func complete(id: UUID, occurredAt: Date) async throws -> ServerEntity
}
protocol FinanceRepository {
    func accounts() async throws -> [RemoteFinancialAccount]
    func transactions() async throws -> [RemoteTransaction]
}
protocol PlaidRepository {
    func linkToken(itemID: UUID?) async throws -> String
    func exchange(publicToken: String) async throws
    func disconnect(itemID: UUID) async throws
}

struct ServerEntity: Decodable, Identifiable {
    let id: UUID
    let updatedAt: Date
    enum CodingKeys: String, CodingKey { case id; case updatedAt = "updated_at" }
}

struct GoalWriteDTO: Encodable {
    let id: UUID
    let title: String
    let details: String
    let status: String
    let targetDate: Date?
    let baseUpdatedAt: Date?
    let clientUpdatedAt: Date
    enum CodingKeys: String, CodingKey {
        case id, title, details, status
        case targetDate = "target_date"
        case baseUpdatedAt = "base_updated_at"
        case clientUpdatedAt = "client_updated_at"
    }
}

struct ActionWriteDTO: Encodable {
    let id: UUID
    let goalID: UUID?
    let title: String
    let status: String
    let scheduledAt: Date?
    let estimatedMinutes: Int
    let baseUpdatedAt: Date?
    let clientUpdatedAt: Date
    enum CodingKeys: String, CodingKey {
        case id, title, status
        case goalID = "goal_id"
        case scheduledAt = "scheduled_at"
        case estimatedMinutes = "estimated_minutes"
        case baseUpdatedAt = "base_updated_at"
        case clientUpdatedAt = "client_updated_at"
    }
}

struct SessionStartDTO: Encodable {
    let id: UUID
    let actionID: UUID?
    let startedAt: Date
    enum CodingKeys: String, CodingKey { case id; case actionID = "action_id"; case startedAt = "started_at" }
}

private struct SessionTransitionDTO: Encodable {
    let occurredAt: Date
    enum CodingKeys: String, CodingKey { case occurredAt = "occurred_at" }
}

struct RemoteGoalRepository: GoalRepository {
    let client: TimeBiteAPIClient
    func upsert(_ goal: GoalWriteDTO) async throws -> ServerEntity {
        try await client.request("/v1/goals/\(goal.id.uuidString)", method: "PUT", body: goal)
    }
    func delete(id: UUID) async throws {
        let _: EmptyResponse = try await client.request("/v1/goals/\(id.uuidString)", method: "DELETE")
    }
}

struct RemoteActionRepository: ActionRepository {
    let client: TimeBiteAPIClient
    func upsert(_ action: ActionWriteDTO) async throws -> ServerEntity {
        try await client.request("/v1/actions/\(action.id.uuidString)", method: "PUT", body: action)
    }
    func delete(id: UUID) async throws {
        let _: EmptyResponse = try await client.request("/v1/actions/\(id.uuidString)", method: "DELETE")
    }
}

struct RemoteSessionRepository: SessionRepository {
    let client: TimeBiteAPIClient
    func start(_ session: SessionStartDTO) async throws -> ServerEntity {
        try await client.request("/v1/sessions/start", method: "POST", body: session)
    }
    func pause(id: UUID, occurredAt: Date = .now) async throws -> ServerEntity {
        try await client.request(
            "/v1/sessions/\(id.uuidString)/pause", method: "POST", body: SessionTransitionDTO(occurredAt: occurredAt)
        )
    }
    func complete(id: UUID, occurredAt: Date = .now) async throws -> ServerEntity {
        try await client.request(
            "/v1/sessions/\(id.uuidString)/complete", method: "POST", body: SessionTransitionDTO(occurredAt: occurredAt)
        )
    }
}

struct RemoteFinancialAccount: Codable, Identifiable {
    let id: UUID
    let plaidItemID: UUID
    let name: String
    let mask: String?
    let type: String?
    let subtype: String?
    let currency: String
    let currentBalanceMinorUnits: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, mask, type, subtype, currency
        case plaidItemID = "plaid_item_id"
        case currentBalanceMinorUnits = "current_balance_minor_units"
    }
}

struct RemoteTransaction: Codable, Identifiable {
    let id: UUID
    let name: String
    let amountMinorUnits: Int
    let currency: String

    enum CodingKeys: String, CodingKey {
        case id, name, currency
        case amountMinorUnits = "amount_minor_units"
    }
}

struct RemoteFinanceRepository: FinanceRepository, PlaidRepository {
    let client: TimeBiteAPIClient

    func accounts() async throws -> [RemoteFinancialAccount] {
        try await client.request("/v1/finance/accounts")
    }

    func transactions() async throws -> [RemoteTransaction] {
        try await client.request("/v1/finance/transactions")
    }

    func linkToken(itemID: UUID? = nil) async throws -> String {
        struct Response: Decodable { let link_token: String }
        let path = itemID.map { "/v1/plaid/items/\($0.uuidString)/update-link-token" } ?? "/v1/plaid/link-token"
        let response: Response = try await client.request(path, method: "POST")
        return response.link_token
    }

    func exchange(publicToken: String) async throws {
        struct Body: Encodable { let public_token: String }
        struct Response: Decodable { let id: UUID; let status: String }
        let _: Response = try await client.request(
            "/v1/plaid/exchange", method: "POST", body: Body(public_token: publicToken)
        )
    }

    func disconnect(itemID: UUID) async throws {
        let _: EmptyResponse = try await client.request("/v1/plaid/items/\(itemID.uuidString)", method: "DELETE")
    }
}
