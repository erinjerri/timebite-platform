import SwiftUI
import SwiftData
import UserNotifications

@main
struct TimeBiteApp: App {
    @UIApplicationDelegateAdaptor(TimeBiteAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [
            Goal.self,
            Milestone.self,
            GoalProgressEntry.self,
            AgentSession.self,
            AIWorkSummary.self,
            GoalImpact.self,
            DailyAIReflection.self,
            FinancialGoal.self,
            CapitalAllocation.self,
            DebtAccount.self
        ])
    }
}

final class TimeBiteAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FinanceNotificationScheduler.configureCategories()
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        FinanceNotificationScheduler.recordPaidAction(from: response)
    }
}
