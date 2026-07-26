import Charts
import SwiftData
import SwiftUI

struct SavingsGoalSetupFlow: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var accounts: [PlaidAccount]

    let goal: Goal
    @State private var phase = Phase.considerations

    private enum Phase: Equatable {
        case considerations
        case plaid
        case dashboard
    }

    var body: some View {
        Group {
            switch phase {
            case .considerations:
                GoalConsiderationsModal(goal: goal) {
                    phase = accounts.isEmpty ? .plaid : .dashboard
                }
            case .plaid:
                PlaidConnectModal(
                    contextCopy: "Connect an account to see exactly where your money can come from",
                    onDismiss: { dismiss() },
                    onLinked: { phase = .dashboard },
                    dismissAfterLink: false
                )
            case .dashboard:
                SavingsSpendingDashboardView(goal: goal)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: phase)
    }
}

struct SavingsSpendingDashboardView: View {
    @Query(sort: \PlaidTransaction.date, order: .reverse)
    private var allTransactions: [PlaidTransaction]
    @Query private var financialGoals: [FinancialGoal]
    @Query private var accounts: [PlaidAccount]

    let goal: Goal
    private let assistantOverride: (any GoalAssistantService)?

    @State private var recommendations: [SavingsRecommendation] = []
    @State private var completedRecommendationIDs: Set<String> = []
    @State private var recommendationError: String?

    init(goal: Goal, assistant: (any GoalAssistantService)? = nil) {
        self.goal = goal
        self.assistantOverride = assistant
    }

    private var financialGoal: FinancialGoal? {
        financialGoals.first {
            $0.title.localizedCaseInsensitiveCompare(goal.title) == .orderedSame
        }
    }

    private var engine: SavingsRecommendationEngine {
        SavingsRecommendationEngine(
            goal: goal,
            financialGoal: financialGoal,
            transactions: allTransactions,
            accounts: accounts
        )
    }

    private var transactions: [PlaidTransaction] {
        let start = Calendar.current.date(byAdding: .day, value: -30, to: .now) ?? .now
        return allTransactions.filter { $0.date >= start && $0.amount > 0 && !$0.isPending }
    }

    private var categorySummaries: [CategorySummary] {
        let grouped = Dictionary(grouping: transactions, by: \.categoryPrimary)
        let total = transactions.reduce(Decimal.zero) { $0 + $1.amount }
        return grouped.map { category, items in
            let amount = items.reduce(Decimal.zero) { $0 + $1.amount }
            return CategorySummary(
                category: category,
                amount: amount,
                percentage: total > 0
                    ? NSDecimalNumber(decimal: amount / total).doubleValue
                    : 0
            )
        }
        .sorted { $0.amount > $1.amount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    goalHeader
                    spendingCard
                    summaryCard
                    recommendationsCard
                }
                .padding(16)
                .padding(.bottom, 32)
            }
            .background(TBColor.background.ignoresSafeArea())
            .navigationTitle("Savings Plan")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: allTransactions.map(\.updatedAt)) {
                await loadRecommendations()
            }
        }
    }

    private var goalHeader: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 16) {
                Text(goal.title)
                    .font(TBTypography.title(.title2, weight: .bold))
                    .foregroundStyle(TBColor.textPrimary)

                HStack {
                    Text(engine.targetAmount > 0 ? engine.targetAmount.currency : "Add a target amount")
                        .font(TBTypography.title(.title3, weight: .semibold))
                        .foregroundStyle(TBColor.primaryAccent)
                    Spacer()
                    Text(
                        financialGoal?.dueDate?.formatted(date: .abbreviated, time: .omitted)
                            ?? "\(goal.quarter) · \(engine.defaultHorizonMonths)-month model"
                    )
                        .font(TBTypography.caption())
                        .foregroundStyle(TBColor.textSecondary)
                }

                progressRow(
                    label: "Saved so far",
                    value: engine.currentAmount,
                    target: max(engine.targetAmount, 1)
                )
                progressRow(
                    label: "Monthly target",
                    value: engine.currentMonthlySavings,
                    target: max(engine.requiredMonthlySavings, 1)
                )
                progressRow(
                    label: "This month",
                    value: thisMonthSaved,
                    target: max(engine.requiredMonthlySavings, 1)
                )
            }
        }
    }

    private var spendingCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Spending by Category")
                    .font(TBTypography.title(.title3, weight: .semibold))
                    .foregroundStyle(TBColor.textPrimary)

                ZStack {
                    Chart(categorySummaries) { summary in
                        SectorMark(
                            angle: .value("Spending", NSDecimalNumber(decimal: summary.amount).doubleValue),
                            innerRadius: .ratio(0.68),
                            angularInset: 2
                        )
                        .foregroundStyle(SpendingCategoryPalette.color(for: summary.category))
                        .cornerRadius(4)
                    }
                    .frame(height: 220)

                    VStack(spacing: 2) {
                        Text(totalSpend.currency)
                            .font(TBTypography.title(.title2, weight: .bold))
                            .foregroundStyle(TBColor.textPrimary)
                        Text("last 30 days")
                            .font(TBTypography.caption())
                            .foregroundStyle(TBColor.textSecondary)
                    }
                }

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    alignment: .leading,
                    spacing: 12
                ) {
                    ForEach(categorySummaries) { summary in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(SpendingCategoryPalette.color(for: summary.category))
                                .frame(width: 8, height: 8)
                                .padding(.top, 4)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(SpendingCategoryPalette.label(for: summary.category))
                                    .font(TBTypography.caption(.semibold))
                                    .foregroundStyle(TBColor.textPrimary)
                                    .lineLimit(1)
                                Text("\(summary.amount.currency) · \(summary.percentage, format: .percent.precision(.fractionLength(0)))")
                                    .font(TBTypography.caption())
                                    .foregroundStyle(TBColor.textSecondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private var summaryCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("30-day summary")
                        .font(TBTypography.title(.title3, weight: .semibold))
                        .foregroundStyle(TBColor.textPrimary)
                    Spacer()
                    Label("Last 30 days", systemImage: "calendar")
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.primaryAccent)
                }
                summaryRow("Total transactions", value: "\(transactions.count)")
                summaryRow("Largest transaction", value: (transactions.map(\.amount).max() ?? 0).currency)
                summaryRow("Average transaction", value: averageTransaction.currency)
                summaryRow("Total spending", value: totalSpend.currency)
            }
        }
    }

    private var recommendationsCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Best next moves")
                    .font(TBTypography.title(.title3, weight: .semibold))
                    .foregroundStyle(TBColor.textPrimary)

                if recommendations.isEmpty {
                    Text(recommendationError ?? "Connect more accounts for more suggestions.")
                        .font(TBTypography.body())
                        .foregroundStyle(TBColor.textSecondary)
                } else {
                    ForEach(recommendations) { recommendation in
                        Button {
                            if completedRecommendationIDs.contains(recommendation.id) {
                                completedRecommendationIDs.remove(recommendation.id)
                            } else {
                                completedRecommendationIDs.insert(recommendation.id)
                            }
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: completedRecommendationIDs.contains(recommendation.id) ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(TBColor.primaryAccent)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(recommendation.title)
                                        .font(TBTypography.body(.semibold))
                                        .foregroundStyle(TBColor.textPrimary)
                                    Text(recommendation.rationale)
                                        .font(TBTypography.caption())
                                        .foregroundStyle(TBColor.textSecondary)
                                    HStack {
                                        Text(recommendation.category.rawValue)
                                        Spacer()
                                        Text("\(recommendation.estimatedImpact.currency) \(recommendation.impactCadence)")
                                    }
                                    .font(TBTypography.caption(.semibold))
                                    .foregroundStyle(TBColor.primaryAccent)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(.plain)
                    }

                    if recommendations.count < 3 {
                        Text("Connect more accounts for more suggestions.")
                            .font(TBTypography.caption())
                            .foregroundStyle(TBColor.textSecondary)
                    }
                }
            }
        }
    }

    private func progressRow(label: String, value: Decimal, target: Decimal) -> some View {
        let fraction = min(
            1,
            max(0, NSDecimalNumber(decimal: value / target).doubleValue)
        )
        return VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(label)
                Spacer()
                Text("\(value.currency) · \(max(0, target - value).currency) remaining")
            }
            .font(TBTypography.caption(.semibold))
            .foregroundStyle(TBColor.textSecondary)
            ProgressView(value: fraction)
                .tint(TBColor.primaryAccent)
        }
    }

    private func summaryRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(TBColor.textSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(TBColor.textPrimary)
        }
        .font(TBTypography.body(.semibold))
    }

    private var totalSpend: Decimal {
        transactions.reduce(Decimal.zero) { $0 + $1.amount }
    }

    private var averageTransaction: Decimal {
        transactions.isEmpty ? 0 : totalSpend / Decimal(transactions.count)
    }

    private var thisMonthSaved: Decimal {
        financialGoal?.allocations
            .filter { $0.monthKey == Date().financeMonthKey }
            .reduce(Decimal.zero) { $0 + $1.amount } ?? 0
    }

    @MainActor
    private func loadRecommendations() async {
        do {
            let assistant = assistantOverride
                ?? HeuristicGoalAssistant(financialGoal: financialGoal, accounts: accounts)
            recommendations = try await assistant.recommendations(
                for: goal,
                transactions: allTransactions
            )
            recommendationError = nil
        } catch {
            recommendationError = "Recommendations are temporarily unavailable."
        }
    }
}

private struct CategorySummary: Identifiable {
    let category: String
    let amount: Decimal
    let percentage: Double
    var id: String { category }
}

enum SpendingCategoryPalette {
    private static let colors: [Color] = [
        TBColor.primaryAccent,
        TBColor.secondaryAccent,
        TBColor.gold,
        Color(red: 0.39, green: 0.77, blue: 0.98),
        Color(red: 0.98, green: 0.52, blue: 0.38),
        Color(red: 0.92, green: 0.47, blue: 0.82)
    ]

    static func color(for category: String) -> Color {
        colors[abs(category.hashValue) % colors.count]
    }

    static func label(for category: String) -> String {
        category
            .replacingOccurrences(of: "_", with: " ")
            .lowercased()
            .capitalized
    }
}
