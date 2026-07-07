import Foundation
import UserNotifications

enum FinanceNotificationScheduler {
    static let paymentCategoryIdentifier = "FINANCE_PAYMENT_REMINDER"
    static let paidActionIdentifier = "FINANCE_PAYMENT_PAID"
    static let laterActionIdentifier = "FINANCE_PAYMENT_LATER"
    static let pendingPaidEventsKey = "FinancePendingPaidEvents"

    static func configureCategories() {
        let paid = UNNotificationAction(
            identifier: paidActionIdentifier,
            title: "Paid",
            options: [.authenticationRequired]
        )
        let later = UNNotificationAction(
            identifier: laterActionIdentifier,
            title: "Later",
            options: []
        )

        let paymentCategory = UNNotificationCategory(
            identifier: paymentCategoryIdentifier,
            actions: [paid, later],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([paymentCategory])
    }

    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    static func scheduleMonthlyReviewReminder() {
        let content = UNMutableNotificationContent()
        content.title = "TimeBite Finance OS"
        content.body = "Did you complete your living, health, fertility, debt, emergency, NYC, and business minimums?"
        content.sound = .default

        var components = DateComponents()
        components.day = 28
        components.hour = 10
        components.minute = 0

        let request = UNNotificationRequest(
            identifier: "finance-monthly-review",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        )

        UNUserNotificationCenter.current().add(request)
    }

    static func scheduleGoalReminder(for goal: FinancialGoal) {
        let content = UNMutableNotificationContent()
        content.title = "TimeBite Finance OS"
        content.body = "Did you fund \(goal.title) this month?"
        content.sound = .default
        content.categoryIdentifier = paymentCategoryIdentifier
        content.userInfo = ["goalID": goal.id.uuidString]

        var components = DateComponents()
        components.day = 25
        components.hour = 9
        components.minute = 0

        let request = UNNotificationRequest(
            identifier: "finance-goal-\(goal.id.uuidString)",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        )

        UNUserNotificationCenter.current().add(request)
    }

    static func scheduleNextDollarReminder() {
        let content = UNMutableNotificationContent()
        content.title = "TimeBite Finance OS"
        content.body = "Would you like to allocate your next dollar?"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "finance-next-dollar",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 14 * 24 * 60 * 60, repeats: true)
        )

        UNUserNotificationCenter.current().add(request)
    }

    static func recordPaidAction(from response: UNNotificationResponse) {
        guard
            response.actionIdentifier == paidActionIdentifier,
            let goalID = response.notification.request.content.userInfo["goalID"] as? String
        else {
            return
        }

        var events = pendingPaidEvents()
        events.append(PendingPaidEvent(goalID: goalID, paidAt: Date()))

        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: pendingPaidEventsKey)
        }
    }

    static func consumePendingPaidEvents() -> [PendingPaidEvent] {
        let events = pendingPaidEvents()
        UserDefaults.standard.removeObject(forKey: pendingPaidEventsKey)
        return events
    }

    private static func pendingPaidEvents() -> [PendingPaidEvent] {
        guard
            let data = UserDefaults.standard.data(forKey: pendingPaidEventsKey),
            let events = try? JSONDecoder().decode([PendingPaidEvent].self, from: data)
        else {
            return []
        }

        return events
    }
}

struct PendingPaidEvent: Codable {
    let goalID: String
    let paidAt: Date
}
