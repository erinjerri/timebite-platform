import SwiftData
import SwiftUI

struct FinanceDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authentication: AuthenticationStore
    @Query(sort: \FinancialGoal.tier) private var goals: [FinancialGoal]
    @Query(sort: \DebtAccount.payoffOrder) private var debtAccounts: [DebtAccount]
    @Query private var lifeGoals: [Goal]

    @AppStorage("finance.unlock.tabOpenCount") private var financeTabOpenCount = 0
    @State private var isCheckingConnected = false
    @State private var isSavingsConnected = false
    @State private var isInvestmentAccountConnected = false

    @State private var incomeAmount = "2000"
    @State private var incomeSource = "Consulting"
    @State private var showingMonthlyReview = false
    @State private var showingSetFinanceGoal = false
    @State private var completedReviewGoalIDs: Set<UUID> = []
    @State private var celebratingGoalID: UUID?
    @State private var unlockStage: FinanceUnlockStage?

    private let unlockManager = FinanceUnlockManager()

    private var engine: CapitalAllocationEngine {
        CapitalAllocationEngine(goals: goals, debts: debtAccounts)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    financeGoalLauncher
                    header
                    nextDollarCard
                    incomeAllocator
                    scoreGrid
                    roadmap
                    debtRecoveryCard
                    monthlyReviewLauncher
                }
                .padding(16)
                .padding(.bottom, 92)
            }
            .background(TBColor.background.ignoresSafeArea())
            .navigationTitle("Finance OS")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingSetFinanceGoal, onDismiss: evaluateFinanceUnlock) {
                SetFinanceGoalModal(
                    nextTier: (goals.map(\.tier).max() ?? -1) + 1,
                    onSaved: FinanceNotificationScheduler.scheduleGoalReminder
                )
                .preferredColorScheme(.dark)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingMonthlyReview) {
                monthlyReviewSheet
                    .presentationDetents([.large])
                    .preferredColorScheme(.dark)
            }
            .sheet(item: $unlockStage) { stage in
                FinanceUnlockModal(
                    stage: stage,
                    connector: PlaidFinanceAccountConnector(
                        repository: RemoteFinanceRepository(client: authentication.client),
                        opener: PlaidLinkOpenerFactory.make()
                    ),
                    onConnected: markConnected,
                    onDismiss: { unlockStage = nil }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
            }
            .overlay {
                if let goal = goals.first(where: { $0.id == celebratingGoalID }) {
                    celebrationOverlay(for: goal)
                }
            }
            .task {
                await refreshServerAccountState()
                FinanceNotificationScheduler.configureCategories()
                FinanceNotificationScheduler.requestAuthorization()
                FinanceNotificationScheduler.scheduleMonthlyReviewReminder()
                FinanceNotificationScheduler.scheduleNextDollarReminder()
                goals.forEach(FinanceNotificationScheduler.scheduleGoalReminder)
            }
            .onAppear {
                financeTabOpenCount += 1
                evaluateFinanceUnlock()
            }
            .onChange(of: goals.count) { _, _ in
                evaluateFinanceUnlock()
            }
            .onChange(of: debtAccounts.count) { _, _ in
                evaluateFinanceUnlock()
            }
        }
    }

    private func evaluateFinanceUnlock() {
        guard unlockStage == nil, !showingMonthlyReview, !showingSetFinanceGoal else { return }

        let context = FinanceUnlockContext(
            financeTabOpenCount: financeTabOpenCount,
            hasDebtOrSavingsGoal: !debtAccounts.isEmpty || hasSavingsGoal || hasLifeDebtOrSavingsGoal,
            hasSavingsGoal: hasSavingsGoal,
            isCheckingConnected: isCheckingConnected,
            isSavingsConnected: isSavingsConnected,
            areInvestmentWidgetsEnabled: hasInvestmentWidget,
            isInvestmentAccountConnected: isInvestmentAccountConnected
        )

        unlockStage = unlockManager.nextUnlock(for: context)
    }

    private var hasSavingsGoal: Bool {
        goals.contains {
            $0.category == FinancialGoalCategory.emergencySavings.rawValue
                || $0.category == FinancialGoalCategory.relocation.rawValue
        } || lifeGoals.contains { GoalKind(storedValue: $0.category) == .savings }
    }

    private var hasLifeDebtOrSavingsGoal: Bool {
        lifeGoals.contains {
            let kind = GoalKind(storedValue: $0.category)
            return kind == .debt || kind == .savings
        }
    }

    private var hasInvestmentWidget: Bool {
        goals.contains { $0.category == FinancialGoalCategory.investing.rawValue }
    }

    private func markConnected(_ stage: FinanceUnlockStage) {
        switch stage {
        case .checking:
            isCheckingConnected = true
        case .savings:
            isSavingsConnected = true
        case .investments:
            isInvestmentAccountConnected = true
        }
        Task { await refreshServerAccountState() }
    }

    @MainActor
    private func refreshServerAccountState() async {
        let repository = RemoteFinanceRepository(client: authentication.client)
        guard let accounts = try? await repository.accounts() else { return }
        isCheckingConnected = accounts.contains { $0.subtype == "checking" }
        isSavingsConnected = accounts.contains { $0.subtype == "savings" }
        isInvestmentAccountConnected = accounts.contains { $0.type == "investment" }
    }

    private var financeGoalLauncher: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "target")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(TBColor.primaryAccent)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(TBColor.primaryAccent.opacity(0.14)))
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Build your financial plan")
                            .font(TBTypography.title(.title2, weight: .bold))
                            .foregroundStyle(TBColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Start with a goal. Accounts can wait until automation is useful.")
                            .font(TBTypography.body())
                            .foregroundStyle(TBColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack(spacing: 8) {
                    financeGoalChip("Save", symbol: "banknote.fill")
                    financeGoalChip("Pay down debt", symbol: "creditcard.fill")
                    financeGoalChip("Invest", symbol: "chart.line.uptrend.xyaxis")
                }

                Button {
                    showingSetFinanceGoal = true
                } label: {
                    Label("Set a Financial Goal", systemImage: "plus")
                        .font(TBTypography.body(.semibold))
                        .foregroundStyle(TBColor.financeModalButtonText)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(TBColor.primaryAccent)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityHint("Opens financial goal setup")
            }
        }
    }

    private func financeGoalChip(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .font(TBTypography.caption(.semibold))
            .foregroundStyle(TBColor.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Capsule(style: .continuous).fill(TBColor.surfaceElevated))
            .accessibilityHidden(true)
    }

    private var header: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Life Capital Allocation Engine")
                    .font(TBTypography.title(.title2, weight: .bold))
                    .foregroundStyle(TBColor.textPrimary)
                Text("Answers what your next dollar should do, then turns the answer into action.")
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
            }
        }
    }

    private var nextDollarCard: some View {
        let recommendation = engine.nextDollarRecommendation

        return TBCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Your Next Dollar Should Go To")
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.textSecondary)

                HStack(alignment: .center, spacing: 12) {
                    Text(recommendation.goal?.icon ?? "dollarsign.circle.fill")
                        .font(.system(size: 34, weight: .bold))
                        .frame(width: 46, height: 46)
                        .background(Circle().fill(recommendation.tint.opacity(0.16)))

                    VStack(alignment: .leading, spacing: 5) {
                        Text(recommendation.goal?.title ?? "No active goal")
                            .font(TBTypography.title(.title2, weight: .bold))
                            .foregroundStyle(TBColor.textPrimary)
                        Text(recommendation.amount.currencyString)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(TBColor.primaryAccent)
                    }

                    Spacer()
                }

                VStack(alignment: .leading, spacing: 7) {
                    ForEach(recommendation.reasons, id: \.self) { reason in
                        Label(reason, systemImage: "checkmark.circle.fill")
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(TBColor.textSecondary)
                    }
                }
            }
        }
    }

    private var incomeAllocator: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader("Income Arrived", subtitle: "Allocate limited capital by urgency, deadline, and monthly minimums.")

                HStack(spacing: 10) {
                    TextField("Amount", text: $incomeAmount)
                        .keyboardType(.decimalPad)
                        .financeInputStyle()
                    TextField("Source", text: $incomeSource)
                        .financeInputStyle()
                }

                let plan = engine.allocationPlan(for: Decimal(string: incomeAmount) ?? 0)

                VStack(spacing: 8) {
                    ForEach(plan) { item in
                        HStack(spacing: 10) {
                            Text(item.goal.icon)
                                .frame(width: 26, height: 26)
                                .background(Circle().fill(item.tint.opacity(0.14)))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.goal.title)
                                    .font(TBTypography.caption(.semibold))
                                    .foregroundStyle(TBColor.textPrimary)
                                Text(item.reason)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(TBColor.textSecondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Text(item.amount.currencyString)
                                .font(TBTypography.caption(.semibold))
                                .foregroundStyle(TBColor.primaryAccent)
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(TBColor.surfaceElevated))
                    }
                }

                Button {
                    apply(plan)
                } label: {
                    Label("Apply Recommendation", systemImage: "arrow.down.circle.fill")
                        .font(TBTypography.body(.semibold))
                        .foregroundStyle(Color.black.opacity(0.86))
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(TBColor.primaryAccent))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var scoreGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
            metric("Health Score", value: "\(engine.financialHealthScore)", icon: "heart.fill", tint: TBColor.primaryAccent)
            metric("Goal Completion", value: "\(Int(engine.goalCompletionScore * 100))%", icon: "scope", tint: Color(red: 0.39, green: 0.77, blue: 0.98))
            metric("Funding Needed", value: engine.remainingFunding.currencyString, icon: "tray.full.fill", tint: TBColor.gold)
            metric("Monthly Done", value: "\(Int(engine.monthlyCompletion * 100))%", icon: "checkmark.seal.fill", tint: TBColor.secondaryAccent)
        }
    }

    private var roadmap: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Roadmap")
                .font(TBTypography.title(.title3, weight: .semibold))
                .foregroundStyle(TBColor.textPrimary)

            ForEach(goals) { goal in
                goalCard(goal)
            }
        }
    }

    private func goalCard(_ goal: FinancialGoal) -> some View {
        TBCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Text(goal.icon)
                        .font(.system(size: 24))
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(goal.tint.opacity(0.16)))

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Tier \(goal.tier) • \(goal.category)")
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(goal.tint)
                        Text(goal.title)
                            .font(TBTypography.body(.semibold))
                            .foregroundStyle(TBColor.textPrimary)
                        if let dueDate = goal.dueDate {
                            Text("Deadline \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(TBTypography.caption())
                                .foregroundStyle(TBColor.textSecondary)
                        }
                    }

                    Spacer()
                    priorityBadge(goal.priority)
                }

                if goal.title == "Egg Freezing" {
                    Toggle("Concierge service", isOn: bindingForConcierge(goal))
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.textPrimary)
                        .tint(TBColor.primaryAccent)
                }

                progressBar(goal.completionPercentage, tint: goal.tint)

                HStack {
                    smallStat("Funded", goal.currentAmount.currencyString)
                    smallStat("Remaining", goal.remainingAmount.currencyString)
                    smallStat("Monthly", goal.recommendedMonthly.currencyString)
                }

                Text(goal.consequenceOfDelay)
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
            }
        }
    }

    private var debtRecoveryCard: some View {
        TBCard {
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader("Financial Recovery", subtitle: "Hybrid Snowball + Avalanche payoff order.")

                ForEach(debtAccounts) { account in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(account.payoffOrder). \(account.name)")
                                .font(TBTypography.caption(.semibold))
                                .foregroundStyle(TBColor.textPrimary)
                            Text("\(String(format: "%.2f", account.annualPercentageRate))% APR")
                                .font(TBTypography.caption())
                                .foregroundStyle(TBColor.textSecondary)
                        }
                        Spacer()
                        Text(account.balance.currencyString)
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(TBColor.gold)
                    }
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                    smallStat("Utilization", "\(Int(engine.creditUtilization * 100))%")
                    smallStat("FICO Lift", "+\(engine.estimatedFICOImprovement)")
                    smallStat("Interest Saved", engine.interestSaved.currencyString)
                    smallStat("Payoff", engine.estimatedDebtPayoffDate.formatted(date: .abbreviated, time: .omitted))
                }
            }
        }
    }

    private var monthlyReviewLauncher: some View {
        Button {
            completedReviewGoalIDs = Set(goals.filter(\.monthlyMinimumMet).map(\.id))
            showingMonthlyReview = true
        } label: {
            Label("Run Monthly Review", systemImage: "calendar.badge.checkmark")
                .font(TBTypography.body(.semibold))
                .foregroundStyle(TBColor.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(TBColor.surfaceElevated))
        }
        .buttonStyle(.plain)
    }

    private var monthlyReviewSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Did you complete your monthly minimums?")
                        .font(TBTypography.title(.title2, weight: .bold))
                        .foregroundStyle(TBColor.textPrimary)

                    ForEach(goals.filter { $0.tier <= 6 }) { goal in
                        Button {
                            toggleReview(goal)
                        } label: {
                            HStack {
                                Image(systemName: completedReviewGoalIDs.contains(goal.id) ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(completedReviewGoalIDs.contains(goal.id) ? TBColor.primaryAccent : TBColor.textSecondary)
                                Text(goal.title)
                                    .font(TBTypography.body(.semibold))
                                    .foregroundStyle(TBColor.textPrimary)
                                Spacer()
                                Text(goal.monthlyMinimum.currencyString)
                                    .font(TBTypography.caption(.semibold))
                                    .foregroundStyle(TBColor.textSecondary)
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(TBColor.surfaceElevated))
                        }
                        .buttonStyle(.plain)
                    }

                    Button("Save Review") {
                        saveMonthlyReview()
                    }
                    .font(TBTypography.body(.semibold))
                    .foregroundStyle(Color.black.opacity(0.86))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(TBColor.primaryAccent))
                }
                .padding(20)
            }
            .background(TBColor.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showingMonthlyReview = false }
                        .foregroundStyle(TBColor.textSecondary)
                }
            }
        }
    }

    private func metric(_ title: String, value: String, icon: String, tint: Color) -> some View {
        TBCard {
            VStack(alignment: .leading, spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(tint.opacity(0.14)))
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(TBColor.textPrimary)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func sectionHeader(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(TBTypography.body(.semibold))
                .foregroundStyle(TBColor.textPrimary)
            Text(subtitle)
                .font(TBTypography.caption())
                .foregroundStyle(TBColor.textSecondary)
        }
    }

    private func progressBar(_ value: Double, tint: Color) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(TBColor.surfaceElevated)
                Capsule()
                    .fill(tint)
                    .frame(width: proxy.size.width * value)
            }
        }
        .frame(height: 10)
    }

    private func smallStat(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(TBColor.textSecondary)
            Text(value)
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textPrimary)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(TBColor.surfaceElevated))
    }

    private func priorityBadge(_ priority: FinancialPriorityLevel) -> some View {
        Text(priority.rawValue)
            .font(TBTypography.caption(.semibold))
            .foregroundStyle(priority.tint)
            .padding(.vertical, 6)
            .padding(.horizontal, 9)
            .background(Capsule().fill(priority.tint.opacity(0.14)))
    }

    private func celebrationOverlay(for goal: FinancialGoal) -> some View {
        VStack(spacing: 12) {
            Text(goal.icon)
                .font(.system(size: 50))
            Text("\(goal.title) funded")
                .font(TBTypography.title(.title2, weight: .bold))
                .foregroundStyle(TBColor.textPrimary)
            Text("+50 XP")
                .font(TBTypography.body(.semibold))
                .foregroundStyle(TBColor.gold)
        }
        .padding(28)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(TBColor.surfaceElevated))
        .shadow(color: .black.opacity(0.35), radius: 24)
        .transition(.scale.combined(with: .opacity))
    }

    private func bindingForConcierge(_ goal: FinancialGoal) -> Binding<Bool> {
        Binding(
            get: { goal.isConciergeEnabled },
            set: { newValue in
                goal.isConciergeEnabled = newValue
                goal.targetAmount = newValue ? 15250 : 10000
                goal.updatedAt = .now
                try? modelContext.save()
            }
        )
    }

    private func apply(_ plan: [AllocationRecommendation]) {
        for item in plan where item.amount > 0 {
            item.goal.currentAmount = min(item.goal.targetAmount, item.goal.currentAmount + item.amount)
            item.goal.updatedAt = .now
            let xp = item.goal.completionPercentage >= 1 ? 50 : 15
            item.goal.xpEarned += xp
            let allocation = CapitalAllocation(
                amount: item.amount,
                source: incomeSource.isEmpty ? "Income" : incomeSource,
                note: item.reason,
                xpAwarded: xp,
                goal: item.goal
            )
            item.goal.allocations.append(allocation)
            modelContext.insert(allocation)
            if item.goal.completionPercentage >= 1 {
                showCelebration(for: item.goal)
            }
        }
        try? modelContext.save()
    }

    private func toggleReview(_ goal: FinancialGoal) {
        if completedReviewGoalIDs.contains(goal.id) {
            completedReviewGoalIDs.remove(goal.id)
        } else {
            completedReviewGoalIDs.insert(goal.id)
        }
    }

    private func saveMonthlyReview() {
        for goal in goals.filter({ completedReviewGoalIDs.contains($0.id) && !$0.monthlyMinimumMet }) {
            let allocation = CapitalAllocation(
                amount: goal.monthlyMinimum,
                source: "Monthly Review",
                note: "Monthly minimum completed",
                xpAwarded: 20,
                goal: goal
            )
            goal.currentAmount = min(goal.targetAmount, goal.currentAmount + goal.monthlyMinimum)
            goal.xpEarned += 20
            goal.allocations.append(allocation)
            modelContext.insert(allocation)
        }
        try? modelContext.save()
        showingMonthlyReview = false
    }

    private func showCelebration(for goal: FinancialGoal) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.68)) {
            celebratingGoalID = goal.id
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeOut(duration: 0.22)) {
                celebratingGoalID = nil
            }
        }
    }

}

private struct CapitalAllocationEngine {
    let goals: [FinancialGoal]
    let debts: [DebtAccount]

    var nextDollarRecommendation: NextDollarRecommendation {
        guard let goal = goals.sorted(by: allocationSort).first(where: { $0.remainingAmount > 0 }) else {
            return NextDollarRecommendation(goal: nil, amount: 0, reasons: ["All active goals are funded"], tint: TBColor.primaryAccent)
        }

        return NextDollarRecommendation(
            goal: goal,
            amount: min(goal.remainingAmount, max(goal.monthlyMinimumShortfall, goal.recommendedMonthly)),
            reasons: reasons(for: goal),
            tint: goal.tint
        )
    }

    var remainingFunding: Decimal {
        goals.reduce(0) { $0 + $1.remainingAmount }
    }

    var goalCompletionScore: Double {
        guard !goals.isEmpty else { return 0 }
        return goals.reduce(0) { $0 + $1.completionPercentage } / Double(goals.count)
    }

    var monthlyCompletion: Double {
        let required = goals.filter { $0.monthlyMinimum > 0 && $0.tier <= 7 }
        guard !required.isEmpty else { return 0 }
        return Double(required.filter(\.monthlyMinimumMet).count) / Double(required.count)
    }

    var financialHealthScore: Int {
        min(100, 35 + Int(monthlyCompletion * 35) + Int(goalCompletionScore * 20) + min(totalXP / 100, 10))
    }

    var totalXP: Int {
        goals.reduce(0) { $0 + $1.xpEarned }
    }

    var creditUtilization: Double {
        let balance = debts.reduce(Decimal(0)) { $0 + $1.balance }
        let limit = debts.reduce(Decimal(0)) { $0 + $1.creditLimit }
        guard limit > 0 else { return 0 }
        return NSDecimalNumber(decimal: balance / limit).doubleValue
    }

    var estimatedFICOImprovement: Int {
        max(0, min(80, Int((creditUtilization - 0.3) * 120)))
    }

    var interestSaved: Decimal {
        let paidTowardDebt = goals.first { $0.category == FinancialGoalCategory.debt.rawValue }?.currentAmount ?? 0
        return paidTowardDebt * Decimal(0.22)
    }

    var estimatedDebtPayoffDate: Date {
        guard let debtGoal = goals.first(where: { $0.category == FinancialGoalCategory.debt.rawValue }) else { return .now }
        let payment = max(debtGoal.recommendedMonthly, 1)
        let months = Int(ceil(NSDecimalNumber(decimal: debtGoal.remainingAmount / payment).doubleValue))
        return Calendar.current.date(byAdding: .month, value: max(months, 1), to: .now) ?? .now
    }

    func allocationPlan(for income: Decimal) -> [AllocationRecommendation] {
        guard income > 0 else { return [] }

        var remaining = income
        var plan: [AllocationRecommendation] = []
        let sortedGoals = goals.sorted(by: allocationSort)

        for goal in sortedGoals where remaining > 0 && goal.remainingAmount > 0 {
            let needed = max(goal.monthlyMinimumShortfall, goal.recommendedMonthly)
            let amount = min(remaining, min(goal.remainingAmount, needed))
            guard amount > 0 else { continue }
            plan.append(AllocationRecommendation(goal: goal, amount: amount, reason: reasons(for: goal).first ?? "Highest active priority", tint: goal.tint))
            remaining -= amount
        }

        return plan
    }

    private func reasons(for goal: FinancialGoal) -> [String] {
        var reasons: [String] = []
        if goal.priority == .critical {
            reasons.append("Health or stability priority is Critical")
        }
        if goal.monthlyMinimumShortfall > 0 {
            reasons.append("Monthly minimum has not been met")
        }
        if let dueDate = goal.dueDate, Calendar.current.dateComponents([.day], from: .now, to: dueDate).day ?? 999 < 100 {
            reasons.append("Deadline is approaching")
        }
        if goal.tier <= 2 {
            reasons.append("Higher tier goals fund before everything else")
        }
        return reasons.isEmpty ? ["Next unfunded priority in the roadmap"] : reasons
    }

    private func allocationSort(_ lhs: FinancialGoal, _ rhs: FinancialGoal) -> Bool {
        if lhs.monthlyMinimumMet != rhs.monthlyMinimumMet {
            return !lhs.monthlyMinimumMet
        }
        if lhs.priority.weight != rhs.priority.weight {
            return lhs.priority.weight > rhs.priority.weight
        }
        if lhs.tier != rhs.tier {
            return lhs.tier < rhs.tier
        }
        return (lhs.dueDate ?? .distantFuture) < (rhs.dueDate ?? .distantFuture)
    }
}

private struct NextDollarRecommendation {
    let goal: FinancialGoal?
    let amount: Decimal
    let reasons: [String]
    let tint: Color
}

private struct AllocationRecommendation: Identifiable {
    let id = UUID()
    let goal: FinancialGoal
    let amount: Decimal
    let reason: String
    let tint: Color
}

private extension FinancialGoal {
    var remainingAmount: Decimal {
        max(0, targetAmount - currentAmount)
    }

    var completionPercentage: Double {
        guard targetAmount > 0 else { return 1 }
        return min(1, NSDecimalNumber(decimal: currentAmount / targetAmount).doubleValue)
    }

    var priority: FinancialPriorityLevel {
        FinancialPriorityLevel(rawValue: priorityLevel) ?? .medium
    }

    var tint: Color {
        Color(hexString: colorHex)
    }

    var monthlyMinimumFunded: Decimal {
        allocations
            .filter { $0.monthKey == Date().financeMonthKey }
            .reduce(0) { $0 + $1.amount }
    }

    var monthlyMinimumShortfall: Decimal {
        max(0, monthlyMinimum - monthlyMinimumFunded)
    }

    var monthlyMinimumMet: Bool {
        monthlyMinimumShortfall <= 0
    }
}

private extension FinancialPriorityLevel {
    var tint: Color {
        switch self {
        case .critical: return Color(red: 1, green: 0.55, blue: 0.55)
        case .high: return TBColor.gold
        case .medium: return Color(red: 0.39, green: 0.77, blue: 0.98)
        case .low: return TBColor.textSecondary
        }
    }

    var weight: Int {
        switch self {
        case .critical: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}

private extension Decimal {
    var currencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: self as NSDecimalNumber) ?? "$0"
    }
}

private extension View {
    func financeInputStyle() -> some View {
        self
            .font(TBTypography.body(.semibold))
            .foregroundStyle(TBColor.textPrimary)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(TBColor.surfaceElevated))
    }
}

private extension Color {
    init(hexString: String) {
        let scanner = Scanner(string: hexString)
        var value: UInt64 = 0
        scanner.scanHexInt64(&value)
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
