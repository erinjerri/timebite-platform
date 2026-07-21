import SwiftUI

enum FinanceUnlockStage: Int, CaseIterable, Identifiable, Sendable {
    case checking = 2
    case savings = 3
    case investments = 4

    var id: Int { rawValue }

    var headline: LocalizedStringKey {
        switch self {
        case .checking: "Make your plan automatic"
        case .savings: "Complete your financial picture"
        case .investments: "See your long-term progress"
        }
    }

    var description: LocalizedStringKey {
        switch self {
        case .checking:
            "Connect one checking account to automatically track spending, calculate your daily available cash, and keep your budget up to date."
        case .savings:
            "Track your emergency fund and savings goals automatically."
        case .investments:
            "Track your investment accounts, retirement progress, and net worth alongside your life goals."
        }
    }

    var primaryActionTitle: LocalizedStringKey {
        switch self {
        case .checking: "Connect Checking Account"
        case .savings: "Connect Savings"
        case .investments: "Connect Investments"
        }
    }

    var symbolName: String {
        switch self {
        case .checking: "creditcard.and.123"
        case .savings: "banknote.fill"
        case .investments: "chart.line.uptrend.xyaxis"
        }
    }

    var accessibilityIllustrationLabel: LocalizedStringKey {
        switch self {
        case .checking: "Checking account"
        case .savings: "Savings account"
        case .investments: "Investment growth"
        }
    }

    var footer: LocalizedStringKey? {
        guard self == .checking else { return nil }
        return "Your bank credentials are securely handled by Plaid. TimeBite never stores your login."
    }
}
