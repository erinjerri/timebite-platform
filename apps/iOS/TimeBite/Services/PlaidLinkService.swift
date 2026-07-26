import Foundation
import LinkKit
import SwiftData
import SwiftUI

struct PlaidTransactionDTO: Codable, Identifiable {
    let transactionID: String
    let accountID: String
    let name: String
    let merchantName: String?
    let amount: Decimal
    let date: String
    let pending: Bool
    let isoCurrencyCode: String?
    let personalFinanceCategory: PersonalFinanceCategoryDTO?

    var id: String { transactionID }

    struct PersonalFinanceCategoryDTO: Codable {
        let primary: String
        let detailed: String?
    }

    enum CodingKeys: String, CodingKey {
        case transactionID = "transaction_id"
        case accountID = "account_id"
        case name
        case merchantName = "merchant_name"
        case amount
        case date
        case pending
        case isoCurrencyCode = "iso_currency_code"
        case personalFinanceCategory = "personal_finance_category"
    }
}

@MainActor
final class PlaidLinkService: ObservableObject {
    @Published private(set) var linkSession: PlaidLinkSession?
    @Published var isPresentingLink = false

    var onLinked: (([PlaidTransactionDTO]) -> Void)?
    var onExit: ((String?) -> Void)?

    private let session: URLSession
    private let baseURL: URL
    private let userIDProvider: () -> String?

    init(
        session: URLSession = .shared,
        baseURL: URL? = nil,
        userIDProvider: @escaping () -> String? = {
            UserDefaults.standard.string(forKey: "timebite.authenticatedUserID")
        }
    ) {
        self.session = session
        self.baseURL = baseURL ?? Self.configuredBaseURL
        self.userIDProvider = userIDProvider
    }

    func createLinkToken() async throws -> String {
        let userID = try authenticatedUserID()
        let response: LinkTokenResponse = try await request(
            path: "plaid/link-token",
            method: "POST",
            body: ["user_id": userID]
        )
        return response.linkToken
    }

    func presentLink(token: String) throws {
        let configuration = LinkTokenConfiguration(
            token: token,
            onSuccess: { [weak self] success in
                Task { @MainActor in
                    await self?.completeLink(publicToken: success.publicToken)
                }
            },
            onExit: { [weak self] exit in
                Task { @MainActor in
                    guard let self else { return }
                    self.isPresentingLink = false
                    self.onExit?(exit.error?.displayMessage ?? exit.error?.errorMessage)
                }
            },
            onEvent: nil,
            onLoad: nil
        )
        linkSession = try Plaid.createPlaidLinkSession(configuration: configuration)
        isPresentingLink = true
    }

    func exchangePublicToken(_ publicToken: String) async throws {
        let _: EmptyResponse = try await request(
            path: "plaid/exchange-token",
            method: "POST",
            body: ["public_token": publicToken]
        )
    }

    func syncTransactions() async throws -> [PlaidTransactionDTO] {
        let response: TransactionSyncResponse = try await request(
            path: "plaid/transactions/sync",
            method: "GET",
            body: Optional<[String: String]>.none
        )
        return response.added + response.modified
    }

    func upsert(_ transactions: [PlaidTransactionDTO], in modelContext: ModelContext) throws {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        let existingTransactions = try modelContext.fetch(FetchDescriptor<PlaidTransaction>())
        let transactionIndex = Dictionary(
            uniqueKeysWithValues: existingTransactions.map { ($0.plaidTransactionID, $0) }
        )
        let existingAccounts = try modelContext.fetch(FetchDescriptor<PlaidAccount>())
        var accountIDs = Set(existingAccounts.map(\.plaidAccountID))

        for dto in transactions {
            let transaction = transactionIndex[dto.transactionID] ?? PlaidTransaction(
                plaidTransactionID: dto.transactionID,
                plaidAccountID: dto.accountID,
                transactionName: dto.name,
                amount: dto.amount,
                date: formatter.date(from: dto.date) ?? .now,
                categoryPrimary: dto.personalFinanceCategory?.primary ?? "GENERAL_MERCHANDISE"
            )
            transaction.plaidAccountID = dto.accountID
            transaction.merchantName = dto.merchantName ?? ""
            transaction.transactionName = dto.name
            transaction.amount = dto.amount
            transaction.date = formatter.date(from: dto.date) ?? transaction.date
            transaction.categoryPrimary = dto.personalFinanceCategory?.primary ?? "GENERAL_MERCHANDISE"
            transaction.categoryDetailed = dto.personalFinanceCategory?.detailed ?? ""
            transaction.isPending = dto.pending
            transaction.isoCurrencyCode = dto.isoCurrencyCode ?? "USD"
            transaction.updatedAt = .now

            if transactionIndex[dto.transactionID] == nil {
                modelContext.insert(transaction)
            }
            if accountIDs.insert(dto.accountID).inserted {
                modelContext.insert(
                    PlaidAccount(
                        plaidAccountID: dto.accountID,
                        name: "Connected account",
                        lastSyncedAt: .now
                    )
                )
            }
        }
        try modelContext.save()
    }

    @ViewBuilder
    func linkSheet() -> some View {
        if let linkSession {
            linkSession.sheet()
        } else {
            ProgressView()
        }
    }

    private func completeLink(publicToken: String) async {
        do {
            try await exchangePublicToken(publicToken)
            let transactions = try await syncTransactions()
            isPresentingLink = false
            onLinked?(transactions)
        } catch {
            isPresentingLink = false
            onExit?(error.localizedDescription)
        }
    }

    private func authenticatedUserID() throws -> String {
        guard let userID = userIDProvider()?.trimmingCharacters(in: .whitespacesAndNewlines),
              !userID.isEmpty else {
            throw PlaidLinkError.missingAuthenticatedUser
        }
        return userID
    }

    private func request<Response: Decodable, Body: Encodable>(
        path: String,
        method: String,
        body: Body?
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(try authenticatedUserID(), forHTTPHeaderField: "X-TimeBite-User-ID")
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw PlaidLinkError.serverRejectedRequest
        }
        if Response.self == EmptyResponse.self, data.isEmpty {
            return EmptyResponse() as! Response
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }

    private struct LinkTokenResponse: Decodable {
        let linkToken: String
        enum CodingKeys: String, CodingKey { case linkToken = "link_token" }
    }

    private struct TransactionSyncResponse: Decodable {
        let added: [PlaidTransactionDTO]
        let modified: [PlaidTransactionDTO]
    }

    private struct EmptyResponse: Codable {}

    private static var configuredBaseURL: URL {
        if let rawValue = Bundle.main.object(forInfoDictionaryKey: "TIMEBITE_API_BASE_URL") as? String,
           let url = URL(string: rawValue) {
            return url
        }
        return URL(string: "http://127.0.0.1:8000")!
    }
}

enum PlaidLinkError: LocalizedError {
    case missingAuthenticatedUser
    case serverRejectedRequest

    var errorDescription: String? {
        switch self {
        case .missingAuthenticatedUser:
            "Sign in before connecting a bank account."
        case .serverRejectedRequest:
            "TimeBite could not complete the secure bank connection."
        }
    }
}
