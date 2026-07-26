import Foundation
import SwiftData

@Model
final class PlaidAccount {
    @Attribute(.unique) var plaidAccountID: String
    var name: String
    var mask: String?
    var type: String
    var subtype: String?
    var currentBalance: Decimal?
    var availableBalance: Decimal?
    var isoCurrencyCode: String?
    var lastSyncedAt: Date

    init(
        plaidAccountID: String,
        name: String,
        mask: String? = nil,
        type: String = "depository",
        subtype: String? = nil,
        currentBalance: Decimal? = nil,
        availableBalance: Decimal? = nil,
        isoCurrencyCode: String? = "USD",
        lastSyncedAt: Date = .now
    ) {
        self.plaidAccountID = plaidAccountID
        self.name = name
        self.mask = mask
        self.type = type
        self.subtype = subtype
        self.currentBalance = currentBalance
        self.availableBalance = availableBalance
        self.isoCurrencyCode = isoCurrencyCode
        self.lastSyncedAt = lastSyncedAt
    }
}
