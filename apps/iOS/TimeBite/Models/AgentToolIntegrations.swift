import Foundation

protocol AgentToolSessionProviding {
    var toolName: String { get }
    func fetchRecentSessions() async throws -> [AgentSession]
}

protocol CodexSessionProviding: AgentToolSessionProviding {}
protocol ClaudeSessionProviding: AgentToolSessionProviding {}
protocol OpenHandsSessionProviding: AgentToolSessionProviding {}
protocol CursorSessionProviding: AgentToolSessionProviding {}
protocol GitHubActivityProviding {
    func fetchGoalLinkedActivity(repository: String) async throws -> [GoalImpact]
}

struct AgentIntegrationRegistry {
    var codex: CodexSessionProviding?
    var claude: ClaudeSessionProviding?
    var openHands: OpenHandsSessionProviding?
    var cursor: CursorSessionProviding?
    var github: GitHubActivityProviding?
}
