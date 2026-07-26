import Foundation
import SwiftData

@Model
final class PlaidTransaction {
    @Attribute(.unique) var plaidTransactionID: String
    var plaidAccountID: String
    var merchantName: String
    var transactionName: String
    var amount: Decimal
    var date: Date
    var categoryPrimary: String
    var categoryDetailed: String
    var isPending: Bool
    var isoCurrencyCode: String
    var updatedAt: Date

    init(
        plaidTransactionID: String,
        plaidAccountID: String,
        merchantName: String = "",
        transactionName: String,
        amount: Decimal,
        date: Date,
        categoryPrimary: String,
        categoryDetailed: String = "",
        isPending: Bool = false,
        isoCurrencyCode: String = "USD",
        updatedAt: Date = .now
    ) {
        self.plaidTransactionID = plaidTransactionID
        self.plaidAccountID = plaidAccountID
        self.merchantName = merchantName
        self.transactionName = transactionName
        self.amount = amount
        self.date = date
        self.categoryPrimary = categoryPrimary
        self.categoryDetailed = categoryDetailed
        self.isPending = isPending
        self.isoCurrencyCode = isoCurrencyCode
        self.updatedAt = updatedAt
    }
}
