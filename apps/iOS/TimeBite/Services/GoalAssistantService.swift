import Foundation

protocol GoalAssistantService {
    func recommendations(
        for goal: Goal,
        transactions: [PlaidTransaction]
    ) async throws -> [SavingsRecommendation]
}

struct HeuristicGoalAssistant: GoalAssistantService {
    let financialGoal: FinancialGoal?
    let accounts: [PlaidAccount]

    init(financialGoal: FinancialGoal? = nil, accounts: [PlaidAccount] = []) {
        self.financialGoal = financialGoal
        self.accounts = accounts
    }

    func recommendations(
        for goal: Goal,
        transactions: [PlaidTransaction]
    ) async throws -> [SavingsRecommendation] {
        SavingsRecommendationEngine(
            goal: goal,
            financialGoal: financialGoal,
            transactions: transactions,
            accounts: accounts
        ).recommendations
    }
}

// LLMGoalAssistant: calls backend/services/assistant/orchestrator.py once implemented.
