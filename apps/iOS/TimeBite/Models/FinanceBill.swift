import Foundation
import SwiftData

@Model
final class FinancialGoal {
    @Attribute(.unique) var id: UUID
    var title: String
    var category: String
    var targetAmount: Decimal
    var currentAmount: Decimal
    var dueDate: Date?
    var monthlyMinimum: Decimal
    var recommendedMonthly: Decimal
    var priorityLevel: String
    var consequenceOfDelay: String
    var dependencyGoalIDs: [UUID]
    var notes: String
    var icon: String
    var colorHex: String
    var tier: Int
    var isConciergeEnabled: Bool
    var conciergeAmount: Decimal
    var createdAt: Date
    var updatedAt: Date
    var xpEarned: Int

    @Relationship(deleteRule: .cascade, inverse: \CapitalAllocation.goal)
    var allocations: [CapitalAllocation]

    init(
        id: UUID = UUID(),
        title: String,
        category: FinancialGoalCategory,
        targetAmount: Decimal,
        currentAmount: Decimal = 0,
        dueDate: Date? = nil,
        monthlyMinimum: Decimal,
        recommendedMonthly: Decimal,
        priorityLevel: FinancialPriorityLevel,
        consequenceOfDelay: String,
        dependencyGoalIDs: [UUID] = [],
        notes: String = "",
        icon: String,
        colorHex: String,
        tier: Int,
        isConciergeEnabled: Bool = false,
        conciergeAmount: Decimal = 0,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        xpEarned: Int = 0,
        allocations: [CapitalAllocation] = []
    ) {
        self.id = id
        self.title = title
        self.category = category.rawValue
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.dueDate = dueDate
        self.monthlyMinimum = monthlyMinimum
        self.recommendedMonthly = recommendedMonthly
        self.priorityLevel = priorityLevel.rawValue
        self.consequenceOfDelay = consequenceOfDelay
        self.dependencyGoalIDs = dependencyGoalIDs
        self.notes = notes
        self.icon = icon
        self.colorHex = colorHex
        self.tier = tier
        self.isConciergeEnabled = isConciergeEnabled
        self.conciergeAmount = conciergeAmount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.xpEarned = xpEarned
        self.allocations = allocations
    }
}

@Model
final class CapitalAllocation {
    @Attribute(.unique) var id: UUID
    var amount: Decimal
    var source: String
    var allocatedAt: Date
    var monthKey: String
    var note: String
    var xpAwarded: Int
    var goal: FinancialGoal?

    init(
        id: UUID = UUID(),
        amount: Decimal,
        source: String,
        allocatedAt: Date = .now,
        monthKey: String = Date().financeMonthKey,
        note: String = "",
        xpAwarded: Int = 0,
        goal: FinancialGoal? = nil
    ) {
        self.id = id
        self.amount = amount
        self.source = source
        self.allocatedAt = allocatedAt
        self.monthKey = monthKey
        self.note = note
        self.xpAwarded = xpAwarded
        self.goal = goal
    }
}

@Model
final class DebtAccount {
    @Attribute(.unique) var id: UUID
    var name: String
    var balance: Decimal
    var creditLimit: Decimal
    var annualPercentageRate: Double
    var minimumPayment: Decimal
    var payoffOrder: Int

    init(
        id: UUID = UUID(),
        name: String,
        balance: Decimal,
        creditLimit: Decimal,
        annualPercentageRate: Double,
        minimumPayment: Decimal,
        payoffOrder: Int
    ) {
        self.id = id
        self.name = name
        self.balance = balance
        self.creditLimit = creditLimit
        self.annualPercentageRate = annualPercentageRate
        self.minimumPayment = minimumPayment
        self.payoffOrder = payoffOrder
    }
}

enum FinancialGoalCategory: String, Codable, CaseIterable {
    case essentialLiving = "Essential Living"
    case healthcare = "Healthcare"
    case fertility = "Fertility"
    case debt = "Debt"
    case emergencySavings = "Emergency Savings"
    case relocation = "Relocation"
    case business = "Business"
    case investing = "Investing"
    case lifestyle = "Lifestyle"
}

enum FinancialPriorityLevel: String, Codable, CaseIterable {
    case critical = "Critical"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

extension Date {
    var financeMonthKey: String {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return "\(components.year ?? 0)-\(components.month ?? 0)"
    }
}
