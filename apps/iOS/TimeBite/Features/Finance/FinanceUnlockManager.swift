import Foundation

/// A snapshot of signals the unlock engine can evaluate without knowing where
/// those signals are stored. The Finance AI agent can eventually provide this.
struct FinanceUnlockContext: Equatable, Sendable {
    var financeTabOpenCount: Int = 0
    var hasDebtOrSavingsGoal = false
    var hasSavingsGoal = false
    var isCheckingConnected = false
    var isSavingsConnected = false
    var areInvestmentWidgetsEnabled = false
    var isInvestmentAccountConnected = false
}

struct FinanceUnlockRules: Equatable, Sendable {
    struct Checking: Equatable, Sendable {
        var minimumFinanceTabOpens: Int
        var requiresDebtOrSavingsGoal: Bool

        init(minimumFinanceTabOpens: Int = 4, requiresDebtOrSavingsGoal: Bool = true) {
            self.minimumFinanceTabOpens = minimumFinanceTabOpens
            self.requiresDebtOrSavingsGoal = requiresDebtOrSavingsGoal
        }
    }

    struct Savings: Equatable, Sendable {
        var requiresCheckingConnection: Bool
        var requiresSavingsGoal: Bool

        init(requiresCheckingConnection: Bool = true, requiresSavingsGoal: Bool = true) {
            self.requiresCheckingConnection = requiresCheckingConnection
            self.requiresSavingsGoal = requiresSavingsGoal
        }
    }

    struct Investments: Equatable, Sendable {
        var requiresSavingsConnection: Bool
        var requiresInvestmentWidgets: Bool

        init(requiresSavingsConnection: Bool = true, requiresInvestmentWidgets: Bool = true) {
            self.requiresSavingsConnection = requiresSavingsConnection
            self.requiresInvestmentWidgets = requiresInvestmentWidgets
        }
    }

    var checking: Checking
    var savings: Savings
    var investments: Investments

    init(
        checking: Checking = Checking(),
        savings: Savings = Savings(),
        investments: Investments = Investments()
    ) {
        self.checking = checking
        self.savings = savings
        self.investments = investments
    }
}

protocol FinanceUnlockEvaluating {
    func nextUnlock(for context: FinanceUnlockContext) -> FinanceUnlockStage?
}

struct FinanceUnlockManager: FinanceUnlockEvaluating, Sendable {
    var rules: FinanceUnlockRules

    init(rules: FinanceUnlockRules = FinanceUnlockRules()) {
        self.rules = rules
    }

    func nextUnlock(for context: FinanceUnlockContext) -> FinanceUnlockStage? {
        if shouldUnlockChecking(in: context) { return .checking }
        if shouldUnlockSavings(in: context) { return .savings }
        if shouldUnlockInvestments(in: context) { return .investments }
        return nil
    }

    private func shouldUnlockChecking(in context: FinanceUnlockContext) -> Bool {
        !context.isCheckingConnected
            && context.financeTabOpenCount >= rules.checking.minimumFinanceTabOpens
            && (!rules.checking.requiresDebtOrSavingsGoal || context.hasDebtOrSavingsGoal)
    }

    private func shouldUnlockSavings(in context: FinanceUnlockContext) -> Bool {
        !context.isSavingsConnected
            && (!rules.savings.requiresCheckingConnection || context.isCheckingConnected)
            && (!rules.savings.requiresSavingsGoal || context.hasSavingsGoal)
    }

    private func shouldUnlockInvestments(in context: FinanceUnlockContext) -> Bool {
        !context.isInvestmentAccountConnected
            && (!rules.investments.requiresSavingsConnection || context.isSavingsConnected)
            && (!rules.investments.requiresInvestmentWidgets || context.areInvestmentWidgetsEnabled)
    }
}
