import Foundation

struct SavingsRecommendation: Identifiable, Hashable {
    enum Category: String, CaseIterable {
        case cutSpending = "Cut spending"
        case moveAndConsolidate = "Move & consolidate"
        case increaseIncome = "Increase income"
        case automate = "Automate"
    }

    let id: String
    let title: String
    let rationale: String
    let estimatedImpact: Decimal
    let impactCadence: String
    let category: Category
}

struct SavingsRecommendationEngine {
    let goal: Goal
    let financialGoal: FinancialGoal?
    let transactions: [PlaidTransaction]
    let accounts: [PlaidAccount]
    let now: Date
    let defaultHorizonMonths: Int

    init(
        goal: Goal,
        financialGoal: FinancialGoal? = nil,
        transactions: [PlaidTransaction],
        accounts: [PlaidAccount] = [],
        now: Date = .now,
        defaultHorizonMonths: Int = 60
    ) {
        self.goal = goal
        self.financialGoal = financialGoal
        self.transactions = transactions
        self.accounts = accounts
        self.now = now
        self.defaultHorizonMonths = defaultHorizonMonths
    }

    var targetAmount: Decimal {
        financialGoal?.targetAmount ?? inferredTargetAmount ?? 0
    }

    var currentAmount: Decimal {
        financialGoal?.currentAmount ?? 0
    }

    var monthsRemaining: Int {
        guard let dueDate = financialGoal?.dueDate, dueDate > now else {
            return defaultHorizonMonths
        }
        return max(
            1,
            Calendar.current.dateComponents([.month], from: now, to: dueDate).month ?? 1
        )
    }

    var requiredMonthlySavings: Decimal {
        guard targetAmount > currentAmount else { return 0 }
        return (targetAmount - currentAmount) / Decimal(monthsRemaining)
    }

    var currentMonthlySavings: Decimal {
        let recent = transactions.filter { $0.date >= monthStart && !$0.isPending }
        let income = recent
            .filter { $0.amount < 0 }
            .reduce(Decimal.zero) { $0 + abs($1.amount) }
        let outflow = recent
            .filter { $0.amount > 0 }
            .reduce(Decimal.zero) { $0 + $1.amount }
        return max(0, income - outflow)
    }

    var recommendations: [SavingsRecommendation] {
        var results: [SavingsRecommendation] = []
        let gap = max(0, requiredMonthlySavings - currentMonthlySavings)

        if gap > 0 {
            results.append(
                SavingsRecommendation(
                    id: "monthly-gap",
                    title: "Close the \(gap.currency)/mo savings gap",
                    rationale: "Your \(requiredMonthlySavings.currency) monthly target is \(gap.currency) above this month's scanned savings pace.",
                    estimatedImpact: gap,
                    impactCadence: "per month",
                    category: .automate
                )
            )
        }

        results.append(contentsOf: categoryRecommendations)
        results.append(contentsOf: subscriptionRecommendations)
        results.append(contentsOf: cashBalanceRecommendations)

        return Array(
            Dictionary(grouping: results, by: \.id)
                .compactMap { $0.value.max(by: { $0.estimatedImpact < $1.estimatedImpact }) }
                .sorted { $0.estimatedImpact > $1.estimatedImpact }
                .prefix(10)
        )
    }

    private var categoryRecommendations: [SavingsRecommendation] {
        let thresholds: [String: Decimal] = [
            "FOOD_AND_DRINK": 600,
            "ENTERTAINMENT": 300,
            "GENERAL_MERCHANDISE": 500
        ]
        let displayNames = [
            "FOOD_AND_DRINK": "food and dining",
            "ENTERTAINMENT": "entertainment",
            "GENERAL_MERCHANDISE": "general shopping"
        ]
        let grouped = Dictionary(grouping: recentOutflows, by: \.categoryPrimary)

        return grouped.compactMap { category, items in
            guard let threshold = thresholds[category] else { return nil }
            let spend = items.reduce(Decimal.zero) { $0 + $1.amount }
            let reducible = spend - threshold
            guard reducible >= 25 else { return nil }
            let name = displayNames[category] ?? readable(category)
            return SavingsRecommendation(
                id: "category-\(category)",
                title: "Trim \(name) by \(reducible.currency)/mo",
                rationale: "Plaid scanned \(spend.currency) in \(name) over the last 30 days, \(reducible.currency) above the planning threshold.",
                estimatedImpact: reducible,
                impactCadence: "per month",
                category: .cutSpending
            )
        }
    }

    private var subscriptionRecommendations: [SavingsRecommendation] {
        let candidates = transactions
            .filter { $0.amount > 0 && !$0.isPending && $0.date >= lookbackStart }
            .filter {
                $0.categoryDetailed.contains("SUBSCRIPTION")
                    || $0.categoryPrimary == "ENTERTAINMENT"
            }
        let grouped = Dictionary(grouping: candidates) {
            ($0.merchantName.isEmpty ? $0.transactionName : $0.merchantName).lowercased()
        }

        return grouped.compactMap { merchant, items in
            guard items.count >= 2 else { return nil }
            let sorted = items.sorted { $0.date < $1.date }
            let hasMonthlyCadence = zip(sorted, sorted.dropFirst()).contains {
                let days = Calendar.current.dateComponents(
                    [.day], from: $0.date, to: $1.date
                ).day ?? 0
                return (20...40).contains(days)
            }
            guard hasMonthlyCadence else { return nil }
            let average = items.reduce(Decimal.zero) { $0 + $1.amount } / Decimal(items.count)
            let displayMerchant = sorted.last?.merchantName.nonEmpty
                ?? sorted.last?.transactionName
                ?? merchant
            return SavingsRecommendation(
                id: "subscription-\(merchant)",
                title: "Review \(displayMerchant) (\(average.currency)/mo)",
                rationale: "A similar charge from \(displayMerchant) appeared on a monthly cadence in the scanned transactions.",
                estimatedImpact: average,
                impactCadence: "per month",
                category: .cutSpending
            )
        }
    }

    private var cashBalanceRecommendations: [SavingsRecommendation] {
        let monthlyExpenses = recentOutflows.reduce(Decimal.zero) { $0 + $1.amount }
        let reserve = monthlyExpenses * 3
        return accounts.compactMap { account in
            guard account.subtype?.lowercased() == "checking",
                  let balance = account.currentBalance,
                  balance > reserve,
                  balance - reserve >= 100 else { return nil }
            let excess = balance - reserve
            return SavingsRecommendation(
                id: "cash-\(account.plaidAccountID)",
                title: "Review \(excess.currency) of excess checking cash",
                rationale: "\(account.name) is \(excess.currency) above a three-month scanned-expense reserve; compare its yield with a high-yield savings account.",
                estimatedImpact: excess,
                impactCadence: "one time",
                category: .moveAndConsolidate
            )
        }
    }

    private var recentOutflows: [PlaidTransaction] {
        transactions.filter {
            $0.amount > 0 && !$0.isPending && $0.date >= thirtyDaysAgo
        }
    }

    private var inferredTargetAmount: Decimal? {
        let text = "\(goal.title) \(goal.goalDescription)"
        let pattern = #"\$?\s*([0-9][0-9,]*(?:\.[0-9]+)?)\s*([kKmM])?"#
        guard let expression = try? NSRegularExpression(pattern: pattern),
              let match = expression.firstMatch(
                in: text,
                range: NSRange(text.startIndex..., in: text)
              ),
              let amountRange = Range(match.range(at: 1), in: text) else {
            return nil
        }
        let raw = text[amountRange].replacingOccurrences(of: ",", with: "")
        guard var amount = Decimal(string: raw) else { return nil }
        if match.range(at: 2).location != NSNotFound,
           let suffixRange = Range(match.range(at: 2), in: text) {
            switch text[suffixRange].lowercased() {
            case "k": amount *= 1_000
            case "m": amount *= 1_000_000
            default: break
            }
        }
        return amount >= 100 ? amount : nil
    }

    private var thirtyDaysAgo: Date {
        Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now
    }

    private var lookbackStart: Date {
        Calendar.current.date(byAdding: .month, value: -6, to: now) ?? now
    }

    private var monthStart: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: now)) ?? now
    }

    private func readable(_ category: String) -> String {
        category.replacingOccurrences(of: "_", with: " ").lowercased()
    }
}

extension Decimal {
    var currency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: self as NSDecimalNumber) ?? "$0"
    }
}

private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}
