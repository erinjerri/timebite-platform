import Combine
import Foundation

extension Notification.Name {
    static let timeBiteTaskCompleted = Notification.Name("timeBiteTaskCompleted")
}

@MainActor
final class QuarterlyGoalViewModel: ObservableObject {
    @Published private(set) var quarter: String
    @Published private(set) var goals: [QuarterlyGoalRollup]
    @Published private(set) var lastCompletion: TaskCompletionCapture?
    @Published private(set) var isLoading = false

    private let session: URLSession
    private let baseURL: URL
    private let allowsMockFallback: Bool
    private var cancellables = Set<AnyCancellable>()

    init(
        quarter: String = Date.currentQuarterIdentifier,
        goals: [QuarterlyGoalRollup] = [],
        baseURL: URL = URL(string: "http://localhost:8000")!,
        session: URLSession = .shared,
        allowsMockFallback: Bool = false
    ) {
        self.quarter = quarter
        self.goals = goals
        self.baseURL = baseURL
        self.session = session
        self.allowsMockFallback = allowsMockFallback
        subscribeToTaskCompletionEvents()
    }

    var quarterDisplayTitle: String {
        let parts = quarter.split(separator: "-")
        guard parts.count == 2 else { return quarter }
        return "\(parts[1]) \(parts[0])"
    }

    func fetch() async {
        isLoading = true
        defer { isLoading = false }

        do {
            goals = try await fetchRollup(quarter: quarter).goals
        } catch {
            if allowsMockFallback && goals.isEmpty {
                goals = Self.mockGoals
            } else if goals.isEmpty {
                goals = []
            }
        }
    }

    func moveQuarter(by delta: Int) {
        quarter = shiftedQuarter(delta)
        Task { await fetch() }
    }

    private func fetchRollup(quarter: String) async throws -> QuarterlyGoalPayload {
        var components = URLComponents(url: baseURL.appending(path: "/goals/quarterly"), resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "quarter", value: quarter)]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(QuarterlyGoalPayload.self, from: data)
    }

    private func subscribeToTaskCompletionEvents() {
        NotificationCenter.default.publisher(for: .timeBiteTaskCompleted)
            .compactMap { TaskCompletionCapture(notification: $0) }
            .sink { [weak self] capture in
                Task { @MainActor in
                    self?.lastCompletion = capture
                    await self?.handle(capture)
                }
            }
            .store(in: &cancellables)
    }

    private func handle(_ capture: TaskCompletionCapture) async {
        await fetch()

        guard let index = goals.firstIndex(where: { $0.goalID == capture.goalID }) else { return }
        var updated = goals[index]
        updated.recentDeltaMinutes = capture.minutes
        goals[index] = updated
    }

    private func shiftedQuarter(_ delta: Int) -> String {
        let parts = quarter.split(separator: "-")
        guard
            parts.count == 2,
            let year = Int(parts[0]),
            let currentQuarter = Int(parts[1].replacingOccurrences(of: "Q", with: ""))
        else {
            return Date.currentQuarterIdentifier
        }

        let absoluteQuarter = year * 4 + (currentQuarter - 1) + delta
        let newYear = absoluteQuarter / 4
        let newQuarter = (absoluteQuarter % 4) + 1
        return "\(newYear)-Q\(newQuarter)"
    }
}

struct QuarterlyGoalPayload: Decodable {
    let quarter: String
    let goals: [QuarterlyGoalRollup]
}

struct QuarterlyGoalRollup: Decodable, Identifiable, Equatable {
    let goalID: String
    let title: String
    let pillar: String
    let targetMinutes: Int
    let loggedMinutes: Int
    let percentComplete: Double
    let taskCount: Int
    let completedTaskCount: Int
    var recentDeltaMinutes: Int?

    var id: String { goalID }

    enum CodingKeys: String, CodingKey {
        case goalID = "goal_id"
        case title
        case pillar
        case targetMinutes = "target_minutes"
        case loggedMinutes = "logged_minutes"
        case percentComplete = "percent_complete"
        case taskCount = "task_count"
        case completedTaskCount = "completed_task_count"
    }
}

struct TaskCompletionCapture: Equatable {
    let goalID: String
    let goalTitle: String
    let minutes: Int

    init(goalID: String, goalTitle: String, minutes: Int) {
        self.goalID = goalID
        self.goalTitle = goalTitle
        self.minutes = minutes
    }

    init?(notification: Notification) {
        guard
            let goalID = notification.userInfo?["goalID"] as? String,
            let goalTitle = notification.userInfo?["goalTitle"] as? String,
            let minutes = notification.userInfo?["minutes"] as? Int
        else {
            return nil
        }

        self.goalID = goalID
        self.goalTitle = goalTitle
        self.minutes = minutes
    }
}

extension QuarterlyGoalViewModel {
    static let mockGoals = [
        QuarterlyGoalRollup(
            goalID: "goal-timebite",
            title: "Ship TimeBite Quarterly Chart",
            pillar: "work",
            targetMinutes: 2400,
            loggedMinutes: 870,
            percentComplete: 0.3625,
            taskCount: 18,
            completedTaskCount: 7,
            recentDeltaMinutes: nil
        ),
        QuarterlyGoalRollup(
            goalID: "goal-growth",
            title: "Build Consulting Pipeline",
            pillar: "admin",
            targetMinutes: 1800,
            loggedMinutes: 540,
            percentComplete: 0.3,
            taskCount: 12,
            completedTaskCount: 4,
            recentDeltaMinutes: nil
        ),
        QuarterlyGoalRollup(
            goalID: "goal-health",
            title: "Stabilize Personal Systems",
            pillar: "personal",
            targetMinutes: 1200,
            loggedMinutes: 960,
            percentComplete: 0.8,
            taskCount: 10,
            completedTaskCount: 8,
            recentDeltaMinutes: nil
        )
    ]
}
