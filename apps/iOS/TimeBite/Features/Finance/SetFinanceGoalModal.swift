import SwiftData
import SwiftUI

struct SetFinanceGoalModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var syncCoordinator: SyncCoordinator

    let nextTier: Int
    var onSaved: (FinancialGoal) -> Void = { _ in }

    @State private var template = FinanceGoalTemplate.emergencyFund
    @State private var title = FinanceGoalTemplate.emergencyFund.suggestedTitle
    @State private var targetAmount = ""
    @State private var currentAmount = ""
    @State private var monthlyContribution = ""
    @State private var hasDeadline = false
    @State private var dueDate = Calendar.current.date(byAdding: .month, value: 6, to: .now) ?? .now
    @State private var priority = FinancialPriorityLevel.high
    @State private var notes = ""
    @State private var showValidation = false
    @State private var saveError: String?

    private var parsedTargetAmount: Decimal? {
        Decimal(string: targetAmount.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (parsedTargetAmount ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    introduction
                    typeSelector
                    amountFields
                    timingAndPriority
                    notesField

                    if showValidation && !isValid {
                        validationMessage("Add a name and a target greater than zero.")
                    }

                    if let saveError {
                        validationMessage(saveError)
                    }

                    saveButton
                }
                .padding(20)
                .padding(.bottom, 24)
            }
            .background(TBColor.background.ignoresSafeArea())
            .navigationTitle("Financial Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(TBColor.textSecondary)
                }
            }
        }
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What are you building toward?")
                .font(TBTypography.title(.title2, weight: .bold))
                .foregroundStyle(TBColor.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("Start with one clear target. TimeBite will use it to shape your monthly plan and next-dollar recommendations.")
                .font(TBTypography.body())
                .foregroundStyle(TBColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var typeSelector: some View {
        financeField("Goal Type") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 136), spacing: 10)], spacing: 10) {
                ForEach(FinanceGoalTemplate.allCases) { option in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            let previousSuggestion = template.suggestedTitle
                            template = option
                            if title.isEmpty || title == previousSuggestion {
                                title = option.suggestedTitle
                            }
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: option.symbolName)
                                .font(.system(size: 18, weight: .semibold))
                                .accessibilityHidden(true)

                            Text(option.title)
                                .font(TBTypography.caption(.semibold))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .foregroundStyle(template == option ? TBColor.financeModalButtonText : TBColor.textPrimary)
                        .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
                        .padding(.horizontal, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(template == option ? TBColor.primaryAccent : TBColor.surfaceElevated)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(template == option ? TBColor.primaryAccent : TBColor.border, lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(template == option ? .isSelected : [])
                }
            }
        }
    }

    private var amountFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            financeField("Goal Name") {
                financeTextField("Emergency Fund", text: $title)
            }

            financeField("Target Amount", isRequired: true) {
                currencyField("0", text: $targetAmount)
            }

            HStack(alignment: .top, spacing: 12) {
                financeField("Already Saved") {
                    currencyField("0", text: $currentAmount)
                }

                financeField("Monthly Target") {
                    currencyField("0", text: $monthlyContribution)
                }
            }
        }
    }

    private var timingAndPriority: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Set a target date", isOn: $hasDeadline.animation(.spring(response: 0.28, dampingFraction: 0.86)))
                .font(TBTypography.body(.semibold))
                .foregroundStyle(TBColor.textPrimary)
                .tint(TBColor.primaryAccent)

            if hasDeadline {
                DatePicker("Target Date", selection: $dueDate, in: Date.now..., displayedComponents: .date)
                    .font(TBTypography.body(.semibold))
                    .foregroundStyle(TBColor.textPrimary)
                    .tint(TBColor.primaryAccent)
                    .padding(14)
                    .background(inputBackground)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            financeField("Priority") {
                Picker("Priority", selection: $priority) {
                    ForEach(FinancialPriorityLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(.menu)
                .tint(TBColor.primaryAccent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .background(inputBackground)
            }
        }
    }

    private var notesField: some View {
        financeField("Why this matters") {
            TextEditor(text: $notes)
                .font(TBTypography.body())
                .foregroundStyle(TBColor.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 96)
                .padding(10)
                .background(inputBackground)
        }
    }

    private var saveButton: some View {
        Button(action: save) {
            Label("Create Financial Goal", systemImage: "target")
                .font(TBTypography.body(.semibold))
                .foregroundStyle(TBColor.financeModalButtonText)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(TBColor.primaryAccent)
                )
        }
        .buttonStyle(.plain)
    }

    private func financeField<Content: View>(
        _ label: String,
        isRequired: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(label)
                if isRequired { Text("*").foregroundStyle(TBColor.primaryAccent) }
            }
            .font(TBTypography.caption(.semibold))
            .foregroundStyle(TBColor.textSecondary)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func financeTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(TBTypography.body(.semibold))
            .foregroundStyle(TBColor.textPrimary)
            .textInputAutocapitalization(.words)
            .padding(14)
            .background(inputBackground)
    }

    private func currencyField(_ placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 6) {
            Text("$")
                .foregroundStyle(TBColor.textSecondary)
            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .foregroundStyle(TBColor.textPrimary)
        }
        .font(TBTypography.body(.semibold))
        .padding(14)
        .background(inputBackground)
    }

    private var inputBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(TBColor.surfaceElevated)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(TBColor.border, lineWidth: 1)
            }
    }

    private func validationMessage(_ text: String) -> some View {
        Label(text, systemImage: "exclamationmark.circle.fill")
            .font(TBTypography.caption(.semibold))
            .foregroundStyle(TBColor.gold)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel("Error: \(text)")
    }

    private func save() {
        showValidation = true
        saveError = nil
        guard isValid, let target = parsedTargetAmount else { return }

        let current = max(Decimal(string: currentAmount) ?? 0, 0)
        let monthly = max(Decimal(string: monthlyContribution) ?? 0, 0)
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        let goal = FinancialGoal(
            title: cleanTitle,
            category: template.category,
            targetAmount: target,
            currentAmount: min(current, target),
            dueDate: hasDeadline ? dueDate : nil,
            monthlyMinimum: monthly,
            recommendedMonthly: monthly,
            priorityLevel: priority,
            consequenceOfDelay: cleanNotes.isEmpty ? "Delaying this goal may push back \(cleanTitle)." : cleanNotes,
            notes: cleanNotes,
            icon: template.symbolName,
            colorHex: template.colorHex,
            tier: nextTier
        )

        do {
            modelContext.insert(goal)
            try modelContext.save()
            try syncCoordinator.enqueueFinancialGoal(goal, baseUpdatedAt: nil)
            onSaved(goal)
            dismiss()
        } catch {
            modelContext.delete(goal)
            saveError = "TimeBite couldn’t save this goal. Please try again."
        }
    }
}

private enum FinanceGoalTemplate: String, CaseIterable, Identifiable {
    case emergencyFund
    case debtPayoff
    case essentialExpenses
    case healthcare
    case relocation
    case investing
    case business
    case lifestyle

    var id: String { rawValue }

    var title: String {
        switch self {
        case .emergencyFund: "Emergency Fund"
        case .debtPayoff: "Debt Payoff"
        case .essentialExpenses: "Essential Expenses"
        case .healthcare: "Health"
        case .relocation: "Relocation"
        case .investing: "Investing"
        case .business: "Business"
        case .lifestyle: "Lifestyle"
        }
    }

    var suggestedTitle: String { title }

    var category: FinancialGoalCategory {
        switch self {
        case .emergencyFund: .emergencySavings
        case .debtPayoff: .debt
        case .essentialExpenses: .essentialLiving
        case .healthcare: .healthcare
        case .relocation: .relocation
        case .investing: .investing
        case .business: .business
        case .lifestyle: .lifestyle
        }
    }

    var symbolName: String {
        switch self {
        case .emergencyFund: "shield.fill"
        case .debtPayoff: "creditcard.fill"
        case .essentialExpenses: "house.fill"
        case .healthcare: "cross.case.fill"
        case .relocation: "building.2.fill"
        case .investing: "chart.line.uptrend.xyaxis"
        case .business: "briefcase.fill"
        case .lifestyle: "sparkles"
        }
    }

    var colorHex: String {
        switch self {
        case .emergencyFund, .essentialExpenses: "5EEAD4"
        case .debtPayoff, .investing: "B565F2"
        case .healthcare, .relocation: "38BDF8"
        case .business, .lifestyle: "F6BA42"
        }
    }
}

#if DEBUG
struct SetFinanceGoalModal_Previews: PreviewProvider {
    static var previews: some View {
        SetFinanceGoalModal(nextTier: 1)
            .modelContainer(for: [FinancialGoal.self, CapitalAllocation.self, DebtAccount.self], inMemory: true)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 16 Pro")
    }
}
#endif
